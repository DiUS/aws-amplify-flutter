import 'dart:async';
import 'dart:io';

import 'package:amplify/bloc/auth_bloc.dart';
import 'package:amplify/bloc/storage_bloc.dart';
import 'package:amplify/common/error_handler.dart';
import 'package:amplify/common/injector.dart';
import 'package:amplify/common/routes.dart';
import 'package:amplify/data/models/FileInfo.dart';
import 'package:amplify/features/gallery/image_tile.dart';
import 'package:amplify/features/signin/auth_event_handler.dart';
import 'package:amplify/services/analytics_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _authBloc = injector.get<AuthBloc>();
  final _storageBloc = injector.get<StorageBloc>();
  final _authEventHandler = injector.get<AuthEventHandler>();
  final _analyticsService = injector.get<AnalyticsService>();

  StreamSubscription<AuthEvent> _authSubscription;
  StreamSubscription<FileActionEvent> _actionEventSubscription;

  @override
  void initState() {
    super.initState();

    _storageBloc.listFilesAsync();
    _analyticsService.trackPage('gallery');
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _actionEventSubscription.cancel();
    _storageBloc.dispose();

    super.dispose();
  }

  void _signOut() {
    _analyticsService.trackAction('sign-out');
    _authBloc.signOutAsync();
  }

  void _uploadFile() async {
    _analyticsService.trackAction('upload-file');
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path);
      _storageBloc.uploadFileAsync(file);
    }
  }

  void _viewImage(FileInfo fileInfo) async {
    _analyticsService.trackAction('view-image');
    final action = await Navigator.pushNamed(context, Routes.imagePage, arguments: fileInfo);
    if (action == FileAction.deleted) {
      _storageBloc.listFilesAsync();
    }
  }

  Widget _buildPhotoTiles() {
    return StreamBuilder(
        stream: _storageBloc.filesStream,
        builder: (context, AsyncSnapshot<List<FileInfo>> snapshot) {
          _authSubscription ??= _authBloc.stateStream
              .listen(_authEventHandler.listener(context), onError: errorHandler(context));
          _actionEventSubscription ??=
              _storageBloc.actionEventStream.listen(null, onError: errorHandler(context));

          if (snapshot.hasData) {
            return GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (_, index) {
                  return ImageTile(
                      fileInfo: snapshot.data[index],
                      onTap: () => _viewImage(snapshot.data[index]));
                },
                itemCount: snapshot.data.length);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gallery'),
          actions: [IconButton(icon: Icon(Icons.logout), onPressed: _signOut)],
        ),
        body: _buildPhotoTiles(),
        floatingActionButton: FloatingActionButton(
          onPressed: _uploadFile,
          child: Icon(Icons.add),
        ));
  }
}

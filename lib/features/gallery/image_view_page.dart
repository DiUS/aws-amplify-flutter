import 'dart:async';

import 'package:amplify/bloc/storage_bloc.dart';
import 'package:amplify/common/error_handler.dart';
import 'package:amplify/common/injector.dart';
import 'package:amplify/data/models/FileInfo.dart';
import 'package:amplify/services/analytics_service.dart';
import 'package:flutter/material.dart';

import 'image_tile.dart';

class ImageViewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  final _storageBloc = injector.get<StorageBloc>();
  final _analyticsService = injector.get<AnalyticsService>();

  FileInfo _fileInfo;
  StreamSubscription<FileActionEvent> _eventSubscription;

  @override
  void initState() {
    super.initState();

    _analyticsService.trackPage('image-view');
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _storageBloc.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _fileInfo = ModalRoute.of(context).settings.arguments as FileInfo;
  }

  void _delete() {
    _analyticsService.trackAction('delete-image');
    _storageBloc.deleteFileAsync(_fileInfo.key);
    setState(() {
      _fileInfo = null;
    });
  }

  void _actionListener(FileActionEvent event) {
    if (event.action == FileAction.deleted) {
      Navigator.pop(context, FileAction.deleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Image View'),
          actions: [IconButton(icon: Icon(Icons.delete), onPressed: _delete)],
        ),
        body: StreamBuilder(
            stream: _storageBloc.actionEventStream,
            builder: (context, AsyncSnapshot<FileActionEvent> eventSnapshot) {
              _eventSubscription ??= _storageBloc.actionEventStream
                  .listen(_actionListener, onError: errorHandler(context));

              return Visibility(
                  visible: _fileInfo != null, child: Center(child: ImageTile(fileInfo: _fileInfo)));
            }));
  }
}

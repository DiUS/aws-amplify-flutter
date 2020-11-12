import 'dart:async';
import 'dart:io';

import 'package:amplify/common/injector.dart';
import 'package:amplify/data/models/FileInfo.dart';
import 'package:amplify/data/sources/file_repo.dart';
import 'package:amplify_core/amplify_core.dart';

class StorageBloc {
  final _fileRepo = injector.get<FileRepo>();

  final _filesController = StreamController<List<FileInfo>>();
  final _actionEventController = StreamController<FileActionEvent>();

  var _files = <FileInfo>[];

  Stream<List<FileInfo>> _filesStream;
  Stream<FileActionEvent> _actionEventStream;

  StorageBloc() {
    _filesStream = _filesController.stream.asBroadcastStream();
    _actionEventStream = _actionEventController.stream.asBroadcastStream();
  }

  Stream<List<FileInfo>> get filesStream => _filesStream;

  Stream<FileActionEvent> get actionEventStream => _actionEventStream;

  void dispose() {
    _actionEventController.close();
    _filesController.close();
  }

  void deleteFileAsync(String key) async {
    try {
      await Amplify.Storage.remove(key: key);
      _actionEventController.add(FileActionEvent(FileInfo(key: key), FileAction.deleted));
    } catch (e) {
      _actionEventController.addError(e.toString());
    }
  }

  void uploadFileAsync(File file) async {
    try {
      final placeHolder = FileInfo(key: 'place_holder');
      _filesController.add(_files..add(placeHolder));

      final fileInfo = await _fileRepo.uploadFileAsync(file);

      _filesController.add(_files
        ..remove(placeHolder)
        ..add(fileInfo));

      _actionEventController.add(FileActionEvent(fileInfo, FileAction.uploaded));
    } catch (e) {
      _filesController.addError(e.toString());
    }
  }

  void listFilesAsync() async {
    try {
      _files = await _fileRepo.listFilesAsync();
      _filesController.add(_files);
    } catch (e) {
      _filesController.addError(e.toString());
    }
  }
}

enum FileAction { deleted, uploading, uploaded }

class FileActionEvent {
  final FileInfo fileInfo;
  final FileAction action;

  FileActionEvent(this.fileInfo, this.action);
}

import 'dart:io';

import 'package:amplify/data/models/FileInfo.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:path/path.dart';

class FileRepo {
  var _files = <FileInfo>[];

  Future<String> _getUrlAsync(String fileKey) async {
    final options = S3GetUrlOptions(accessLevel: StorageAccessLevel.guest, expires: 10000);
    final result = await Amplify.Storage.getUrl(key: fileKey, options: options);
    return result.url;
  }

  Future<void> deleteFileAsync(String key) async {
    await Amplify.Storage.remove(key: key);
  }

  Future<FileInfo> uploadFileAsync(File file) async {
    final key = basename(file.path);
    final metadata = <String, String>{
      'name': basename(file.path),
      'desc': '${extension(file.path)} file'
    };
    final options = S3UploadFileOptions(accessLevel: StorageAccessLevel.guest, metadata: metadata);
    final result = await Amplify.Storage.uploadFile(key: key, local: file, options: options);
    final url = await _getUrlAsync(result.key);

    return FileInfo(key: result.key, url: url);
  }

  Future<List<FileInfo>> listFilesAsync() async {
    final options = S3ListOptions(accessLevel: StorageAccessLevel.guest);
    final result = await Amplify.Storage.list(options: options);

    final newFiles = <FileInfo>[];

    for (final item in result.items) {
      final existingUrl =
          _files.firstWhere((fileInfo) => fileInfo.key == item.key, orElse: () => null)?.url;
      final url = existingUrl ?? await _getUrlAsync(item.key);
      newFiles.add(FileInfo(key: item.key, url: url));
    }

    _files = newFiles;

    return _files;
  }
}

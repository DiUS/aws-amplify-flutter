import 'package:flutter/foundation.dart';

class FileInfo {
  final String key;
  final String url; // TODO: url can expire
  bool get isReady => url != null;

  FileInfo({@required this.key, this.url});
}

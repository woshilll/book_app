import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathUtil {
  static Future<String> getSavePath(String path) async{
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    Directory _bookDir = Directory("${dir!.path}/$path");
    if (!_bookDir.existsSync()) {
      _bookDir.createSync();
    }
    return _bookDir.path;
  }
}
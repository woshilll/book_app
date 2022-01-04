import 'dart:io';
import 'dart:math';

import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:date_format/date_format.dart';
import 'package:path_provider/path_provider.dart';

class SubtitleUtil {
  static Future<List<String>> getSubtitle(String url) async{
    final RegExp regExp = RegExp(r"^[0-9]*$");
    var dir = await getExternalStorageDirectory();
    String fileName = url.substring(url.lastIndexOf("/") + 1);
    String filePath = "${dir!.path}/subtitle/$fileName";
    File file = File(filePath);
    Log.i(file.existsSync());
    if (!file.existsSync()) {
      // 不存在就下载
      Log.i("下载");
      await DioManager.instance.download(url, filePath);
      file = File(filePath);
    }
    List<String> contents = file.readAsStringSync().split("\n");
    contents = contents.map((e) => e.replaceAll("\r", "")).toList();
    contents.removeWhere((element) => element.isEmpty);
    contents.removeWhere((element) => regExp.hasMatch(element));
    return contents;
  }

  static Future<List> getContent(seconds, List<String> contents, index) async {
    // 格式化时间
    for (int i = index; i < contents.length; i++) {
      String line = contents[i];
      if (line.contains("-->")) {
        List<String> times = line.split(" --> ");
        int start = _formatTime(times[0]);
        int end = _formatTime(times[1]);
        if (seconds >= start && seconds <= end) {
          String res = "";
          for (int j = i + 1; j < contents.length; j++) {
            if (contents[j].contains("-->")) {
              return [res, j];
            }
            res += contents[j];
          }
          return [res, contents.length];
        }
      }
    }
    return ["", index];
  }

  static int _formatTime(String time) {
    List<String> times = time.split(":");
    int seconds = 0;
    for (int i = 0; i < times.length - 1; i++) {
      seconds += int.parse(times[i]) * pow(60, times.length - 1 - i).toInt();
    }
    List<String> times2 = times[times.length - 1].split(',');
    seconds += int.parse(times2[0]);
    return seconds;
  }
}
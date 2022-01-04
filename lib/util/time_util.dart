class TimeUtil {
  static String getSystemTime() {
    var date = DateTime.now();
    return "${date.hour < 10 ? '0' + date.hour.toString() : date.hour}:${date.minute < 10 ? '0' + date.minute.toString() : date.minute}";
  }

  static String formatTime(int time) {
    String str = "";
    if (time ~/ 3600 > 0) {
      int hour = time ~/ 3600;
      str += "0$hour:";
      time = time % 3600;
    }
    if (time ~/ 60 > 0) {
      int minutes = time ~/ 60;
      str += minutes > 9 ? "$minutes:" : "0$minutes:";
      time = time % 60;
    } else {
      str += "00:";
    }
    str += time > 9 ? "$time" : "0$time";
    return str;
  }
}

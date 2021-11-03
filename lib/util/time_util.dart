class TimeUtil {
  static String getSystemTime() {
    var date = DateTime.now();
    return "${date.hour < 10 ? '0' + date.hour.toString() : date.hour}:${date.minute < 10 ? '0' + date.minute.toString() : date.minute}";
  }
}

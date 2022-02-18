import 'package:flutter/material.dart';

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

  static String getMonthStr(int index) {
    return "${index + 1}月";
  }

  static String getYearStr(int diff) {
    return "${(DateTime.now().year - diff)}年";
  }

  static String getChineseDayDiff(DateTime selectedDay) {
    DateTime now = DateTime.now();
    DateTimeRange range = DateUtils.datesOnly(DateTimeRange(start: selectedDay, end: now));
    int dayDiff = range.duration.inDays;
    if (dayDiff == 0) {
      return "今天";
    }
    if (dayDiff > 0 && dayDiff <= 3) {
      switch(dayDiff) {
        case 1:
          return "昨天";
        case 2:
          return "前天";
        case 3:
          return "大前天";
      }
    }
    if (dayDiff < 0 && dayDiff >= -3) {
      switch(dayDiff) {
        case -1:
          return "明天";
        case -2:
          return "后天";
        case -3:
          return "大后天";
      }
    }
    return "${selectedDay.day}号";
  }
}

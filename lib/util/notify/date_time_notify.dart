import 'package:flutter/material.dart';

/// 日期变化监听
class DateTimeNotify extends ChangeNotifier {
  DateTime _notifier = DateTime.now();
  DateTime get date => _notifier;




  setDate({int year = 0, int month = 0, int day = 0, bool withNotify = true, DateTime? maxDate}) {
    if (year == 0) {
      year = _notifier.year;
    }
    if (month == 0) {
      month = _notifier.month;
    }
    if (day == 0) {
      day = _notifier.day;
    }
    _notifier = DateTime(year, month, day);
    if (maxDate != null) {
      if (!maxDate.isAfter(DateTime(year, month, day))) {
        _notifier = maxDate;
      }
    }
    if (withNotify) {
      notifyListeners();
    }
  }
  setDateTime(DateTime dateTime, [DateTime? maxDate]) {
    setDate(year: dateTime.year, month: dateTime.month, day: dateTime.day, maxDate: maxDate);
  }

  resetCount() {
    _notifier = DateTime.now();
    notifyListeners();
  }
}
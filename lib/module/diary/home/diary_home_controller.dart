import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/util/notify/date_time_notify.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DiaryHomeController extends GetxController {
  List diaryList = [1, 2, 3];
  DatePickerController datePickerController = DatePickerController();
  int maxDays = 0;
  DateTimeNotify selectedDay = DateTimeNotify();
  bool isSelectMonth = true;
  @override
  void onInit() {
    super.onInit();
    dateInit();
    _selectedDayListener();
  }

  void dateInit() {
    DateTime now = DateTime.now();
    maxDays = DateUtils.getDaysInMonth(selectedDay.date.year, selectedDay.date.month);
    if (now.year == selectedDay.date.year && now.month == selectedDay.date.month) {
      maxDays = now.day;
    }
  }

  @override
  void onReady() {
    super.onReady();
    datePickerController.jumpToSelection();
  }

  void _selectedDayListener() {
    selectedDay.addListener(() {
      dateInit();
      update(["selectedDateChange"]);
      Timer(const Duration(milliseconds: 100), () {
        datePickerController.animateToDate(selectedDay.date);
      });
    });
  }
}
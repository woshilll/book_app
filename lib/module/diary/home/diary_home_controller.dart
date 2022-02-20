import 'dart:async';

import 'package:book_app/api/diary_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/diary/diary_item_vo.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/notify/date_time_notify.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryHomeController extends GetxController {
  List<DiaryItemVo> diaryItemVoList = [];
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
    _getDiaryItemVoList();
  }

  void _selectedDayListener() {
    selectedDay.addListener(() {
      dateInit();
      /// 修改了插件源码 -- 增加了setDateTime方法来修改里面的_currentDate
      datePickerController.setDateTime(selectedDay.date);
      update(["selectedDateChange"]);
      Timer(const Duration(milliseconds: 100), () {
        datePickerController.animateToDate(selectedDay.date);
      });
    });
  }

  /// 前往编辑页
  void toEdit(int index) {
    Get.toNamed(Routes.diaryEdit);
  }

  void _getDiaryItemVoList() async{
    diaryItemVoList = await DiaryApi.getDiaryItemListByDate(selectedDay.toString());
    update(["diaryItemListRefresh"]);
  }
}
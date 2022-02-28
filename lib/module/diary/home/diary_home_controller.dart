import 'dart:async';

import 'package:badges/badges.dart';
import 'package:book_app/api/diary_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/diary/diary.dart';
import 'package:book_app/model/diary/diary_item_vo.dart';
import 'package:book_app/module/diary/add/diary/diary_add_controller.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_binding.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_controller.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_screen.dart';
import 'package:book_app/module/diary/component/diary_pre.dart';
import 'package:book_app/module/diary/component/select_diary_list.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/notify/date_time_notify.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../add/diary/diary_add_binding.dart';
import '../add/diary/diary_add_screen.dart';

class DiaryHomeController extends GetxController {
  List<DiaryItemVo> diaryItemVoList = [];
  DatePickerController datePickerController = DatePickerController();
  int maxDays = 0;
  DateTimeNotify selectedDay = DateTimeNotify();
  bool isSelectMonth = true;
  BuildContext? context;
  int writeCount = 0;
  int receiveCount = 0;
  List<Diary> diaryList = [];

  @override
  void onInit() {
    super.onInit();
    dateInit();
    _selectedDayListener();
  }

  void dateInit() {
    DateTime now = DateTime.now();
    maxDays =
        DateUtils.getDaysInMonth(selectedDay.date.year, selectedDay.date.month);
    if (now.year == selectedDay.date.year &&
        now.month == selectedDay.date.month) {
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
      update(["selectedDateChange", "noDiaryMessage"]);
      _getDiaryItemVoList();
      Timer(const Duration(milliseconds: 100), () {
        datePickerController.animateToDate(selectedDay.date);
      });
    });
  }


  _getDiaryItemVoList() async {
    diaryItemVoList =
        await DiaryApi.getDiaryItemListByDate(selectedDay.toString());
    writeCount = 0;
    receiveCount = 0;
    for (var vo in diaryItemVoList) {
      if (vo.isMe!) {
        writeCount++;
      } else {
        receiveCount++;
      }
    }
    update(["diaryItemListRefresh", "countChange"]);
  }

  showDiaryList() async {
    if (diaryList.isEmpty) {
      diaryList = await DiaryApi.getDiaryList();
    }
    if (diaryList.isEmpty) {
      EasyLoading.showToast("请先添加日记本");
      await toDiaryAdd();
    } else {
      // 显示日记本列表
      showCupertinoModalBottomSheet(
          context: context!,
          builder: (context) {
            return selectDiaryList(context);
          });
    }
  }

  toDiaryAdd() async {
    await diaryPreAdd(context!);
  }

  refreshList() async{
    await _getDiaryItemVoList();
  }
}

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

  /// 前往编辑页
  void toEdit(int index) {
  }

  void _getDiaryItemVoList() async {
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
    List<Diary> diaryList = await DiaryApi.getDiaryList();
    if (diaryList.isEmpty) {
      EasyLoading.showToast("请先添加日记本");
      await toDiaryAdd();
    } else {
      // 显示日记本列表
      showCupertinoModalBottomSheet(
          context: context!,
          builder: (context) {
            return Container(
              height: 400,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      "请选择日记本",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey[350],
                  ),
                  Expanded(
                    child: GetBuilder<DiaryHomeController>(
                      id: "diaryList",
                      builder: (controller) {
                        return ListView.separated(
                          itemCount: diaryList.length,
                          itemBuilder: (context, index) {
                            String shortName = diaryList[index].diaryName!;
                            if (shortName.length > 8) {
                              shortName = shortName.substring(0, 8) + "...";
                            }
                            return Slidable(
                                key: ValueKey(index),
                                child: InkWell(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 15, top: 8),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              shortName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5,
                                            ),
                                          ),
                                          Badge(
                                            toAnimate: false,
                                            shape: BadgeShape.square,
                                            badgeColor: Colors.deepPurple,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            padding: const EdgeInsets.all(3),
                                            badgeContent: Text(
                                                diaryList[index].diaryTag!,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    height: 1)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 15, top: 4),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "送达 : ${diaryList[index].receiver!}",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 15, top: 4),
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "创于 : ${diaryList[index].createTime!}",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 4,)
                                    ],
                                  ),
                                  onTap: () async{
                                    Navigator.pop(context);
                                    Get.put<DiaryItemAddController>(DiaryItemAddController());
                                    DiaryItemAddController diaryItemAddController = Get.find<DiaryItemAddController>();
                                    diaryItemAddController.initData(true, true, {"diaryId": diaryList[index].id, "diaryName": diaryList[index].diaryName});
                                    await showCupertinoModalBottomSheet(
                                        context: this.context!,
                                        builder: (context) {
                                          return const DiaryItemAddScreen();
                                        });
                                    Timer(Duration(seconds: 1), () {
                                      Get.delete<DiaryItemAddController>();
                                    });
                                  },
                                  onLongPress: () {},
                                ),
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  // dismissible: DismissiblePane(
                                  //   onDismissed: () {},
                                  // ),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.blueAccent,
                                      onPressed: (BuildContext context) {},
                                      icon: Icons.edit,
                                      label: "编辑",
                                    ),
                                    SlidableAction(
                                      backgroundColor: Colors.greenAccent,
                                      onPressed: (BuildContext context) {},
                                      icon: Icons.remove_red_eye_rounded,
                                      label: "查看",
                                    ),
                                    SlidableAction(
                                      backgroundColor: Colors.redAccent,
                                      onPressed: (BuildContext context) {},
                                      icon: Icons.delete,
                                      label: "删除",
                                    ),
                                  ],
                                ));
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 1,
                              color: Colors.grey[350],
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          });
    }
  }

  toDiaryAdd() async {
    Get.put<DiaryAddController>(DiaryAddController());
    await showCupertinoModalBottomSheet(
        context: context!,
        builder: (context) {
          return const DiaryAddScreen();
        });
    Timer(Duration(seconds: 1), () {
      Get.delete<DiaryAddController>();
    });
  }
}

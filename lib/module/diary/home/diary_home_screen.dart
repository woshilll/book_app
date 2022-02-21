import 'package:badges/badges.dart';
import 'package:book_app/api/diary_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/module/diary/add/diary/diary_add_binding.dart';
import 'package:book_app/module/diary/add/diary/diary_add_controller.dart';
import 'package:book_app/module/diary/add/diary/diary_add_screen.dart';
import 'package:book_app/module/diary/component/quill_theme.dart';
import 'package:book_app/module/diary/home/diary_home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/time_util.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tuple/tuple.dart';
import 'package:get/get.dart';

class DiaryHomeScreen extends GetView<DiaryHomeController> {
  const DiaryHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: AppBar(),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GetBuilder<DiaryHomeController>(
            builder: (controller) {
              return Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      GestureDetector(
                        child: Text(
                          '${controller.selectedDay.date.year}  ${controller.selectedDay.date.month < 10 ? '0' + controller.selectedDay.date.month.toString() : controller.selectedDay.date.month}',
                          style: const TextStyle(color: Colors.black45, fontSize: 24),
                        ),
                        onTap: () {
                          _showMonthSelect(context);
                        },
                      ),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          Text(
                            '${TimeUtil.getChineseDayDiff(controller.selectedDay.date)}  -  ',
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Badge(
                            badgeContent: Text("3"),
                            badgeColor: Theme.of(context).primaryColor,
                            child: Text("写",style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(width: 10,),
                          Badge(
                            badgeContent: Text("4"),
                            child: Text("收",style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      SizedBox(height: 5,),
                    ],
                  )
                ],
              );
            },
          ),
          _dateBar(context),
          _diaryItemListView(context),
        ],
      ),
    );
  }

  Widget _dateBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: DatePicker(
        DateTime(controller.selectedDay.date.year, controller.selectedDay.date.month),
        controller: controller.datePickerController,
        initialSelectedDate: controller.selectedDay.date,
        onDateChange: (newDate) {
          controller.selectedDay.setDateTime(newDate);
        },
        width: 70,
        height: 100,
        selectedTextColor: Colors.white,
        selectionColor: Theme.of(context).primaryColor,
        dayTextStyle:
        const TextStyle(color: Colors.black),
        dateTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        monthTextStyle:
        const TextStyle(color: Colors.black),
        locale: "zh_CN",
        daysCount: controller.maxDays,
      ),
    );
  }

  Widget _diaryItemListView(BuildContext context) {
    return Expanded(
        child: GetBuilder<DiaryHomeController>(
          id: "diaryItemListRefresh",
          builder: (controller) {
            return _diaryItemList(context);
          },
        )
    );
  }

  Widget _diaryItemList(BuildContext context) {
    return AnimationLimiter(
      child: ListView.separated(
        scrollDirection:
        MediaQuery.of(context).orientation == Orientation.portrait
            ? Axis.vertical
            : Axis.horizontal,
        itemCount: controller.diaryItemVoList.length + 1,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _noTasksMessage(context, index);
          }
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: Duration(milliseconds: 500 + index * 20),
            child: SlideAnimation(
              horizontalOffset: 400.0,
              child: FadeInAnimation(
                child: Slidable(
                  key: ValueKey(index),
                  child: Card(
                    color: Theme.of(context).primaryColor.withOpacity(.7),
                    child: Container(
                      height: 150,
                    ),
                  ),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    // dismissible: DismissiblePane(
                    //   onDismissed: () {},
                    // ),
                    children: [
                      SlidableAction(
                        backgroundColor: Colors.blueAccent,
                        onPressed: (BuildContext context) {
                          controller.toEdit(index);
                        },
                        icon: Icons.edit,
                        label: "编辑",
                      ),
                      SlidableAction(
                        backgroundColor: Colors.greenAccent,
                        onPressed: (BuildContext context) {
                          controller.toEdit(index);
                        },
                        icon: Icons.remove_red_eye_rounded,
                        label: "查看",
                      ),
                      SlidableAction(
                        backgroundColor: Colors.redAccent,
                        onPressed: (BuildContext context) {  },
                        icon: Icons.delete,
                        label: "删除",
                      ),

                    ],
                  ),
                ),
                // child: GestureDetector(
                //   onTap: () => displayBottomSheet(context, task),
                //   child: TaskTile(task: task),
                // ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 15,);
        },
      ),
    );
  }
  // displayBottomSheet(context, Task task) {
  //   showModalBottomSheet(
  //       context: context,
  //       builder: (BuildContext bc) {
  //         return _bottomSheet(task);
  //       });
  // }

  // Widget _bottomSheet(Task task) {
  //   return Container(
  //     margin: EdgeInsets.all(20),
  //     height: MediaQuery.of(context).orientation == Orientation.portrait
  //         ? MediaQuery.of(context).size.height * 0.2
  //         : MediaQuery.of(context).size.height * 0.4,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         task.isCompleted == 0
  //             ? ElevatedButton(
  //             onPressed: () {
  //               notifyHelper.cancelNotification(task.id!);
  //               _taskController.markAsCompleted(task.id);
  //               Get.back();
  //             },
  //             child: Text("Complete Task"))
  //             : SizedBox(
  //           height: 0,
  //         ),
  //         ElevatedButton(
  //             onPressed: () {
  //               _taskController.deleteTask(task.id);
  //               notifyHelper.cancelNotification(task.id!);
  //               Get.back();
  //             },
  //             child: Text("Delete Task")),
  //         ElevatedButton(onPressed: () => Get.back(), child: Text("Cancel"))
  //       ],
  //     ),
  //   );
  // }

  Widget _noTasksMessage(BuildContext context, int index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: Duration(milliseconds: 500 + index * 20),
      child: SlideAnimation(
        horizontalOffset: 400.0,
        child: FadeInAnimation(
          child: Card(
            color: Colors.grey.withOpacity(.7),
            child: Container(
              height: 150,
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "日记+",
                      recognizer: TapGestureRecognizer()..onTap = () async{
                        await controller.showDiaryList();
                      }
                    ),
                    TextSpan(text: " "*5),
                    TextSpan(
                      text: "日记本+",
                      recognizer: TapGestureRecognizer()..onTap = () async{
                        controller.toDiaryAdd();
                        // DiaryAddController diaryAddController = Get.find();
                        // diaryAddController.dispose();
                      }
                    )
                  ],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMonthSelect(BuildContext context) {
    showBarModalBottomSheet(
      elevation: 0,
      builder: (context) {
        return GetBuilder<DiaryHomeController>(
          id: "selectMonthOrYear",
          builder: (controller) {
            return Container(
              height: 400,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text.rich(
                        TextSpan(
                            children: [
                              TextSpan(text: controller.isSelectMonth ? "月" : "年"),
                              const TextSpan(text: " -- "),
                              TextSpan(
                                  text: controller.isSelectMonth ? (controller.selectedDay.date.year.toString() + "年") : (controller.selectedDay.date.month.toString() + "月"),
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                  recognizer: TapGestureRecognizer()..onTap = () {
                                    controller.isSelectMonth = !controller.isSelectMonth;
                                    controller.update(["selectMonthOrYear"]);
                                  }
                              )
                            ],
                            style: Theme.of(context).textTheme.bodyText1
                        )
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey, indent: 15, endIndent: 15,),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(_getMonthOrYearStr(controller.isSelectMonth, index), style: TextStyle(color: _isMonthOrYearPriColor(index) ? Theme.of(context).primaryColor : (_isMonthDisable(index) && controller.isSelectMonth ? Colors.grey : Theme.of(context).textTheme.bodyText1!.color)),),
                          ),
                          onTap: () {
                            if (controller.isSelectMonth) {
                              if (_isMonthDisable(index)) {
                                return;
                              }
                              controller.selectedDay.setDate(month: index + 1, maxDate: DateTime.now());
                              Navigator.of(context).pop();
                            } else {
                              controller.selectedDay.setDate(year: DateTime.now().year - index, withNotify: false, maxDate: DateTime.now());
                              controller.isSelectMonth = !controller.isSelectMonth;
                              controller.update(["selectMonthOrYear"]);
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(height: 1, color: Colors.grey, indent: 15, endIndent: 15,);
                      },
                      itemCount: controller.isSelectMonth ? 12 : (DateTime.now().year - 1999),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
    , context: context).then((value) {
      controller.isSelectMonth = true;
      controller.dateInit();
      controller.update(["selectedDateChange"]);
    });
  }
  _getMonthOrYearStr(bool month, int index) {
    if (month) {
      return TimeUtil.getMonthStr(index);
    } else {
      return TimeUtil.getYearStr(index);
    }
  }

  bool _isMonthOrYearPriColor(int index) {
    if (controller.isSelectMonth) {
      return controller.selectedDay.date.month == index + 1;
    } else {
      return DateTime.now().year - controller.selectedDay.date.year == index;
    }
  }

  bool _isMonthDisable(int index) {
    var now = DateTime.now();
    if (controller.selectedDay.date.year == now.year) {
      return index + 1 > now.month;
    }
    return false;
  }


}
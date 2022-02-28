import 'dart:async';

import 'package:badges/badges.dart';
import 'package:book_app/model/diary/diary.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_controller.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_screen.dart';
import 'package:book_app/module/diary/component/diary_pre.dart';
import 'package:book_app/module/diary/home/diary_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'diary_item_pre.dart';

Widget selectDiaryList(BuildContext context) {
  return SizedBox(
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
              List<Diary> diaryList = controller.diaryList;
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
                          await diaryItemPreAdd(context, diaryList[index]);
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
                            onPressed: (BuildContext context) async{
                              await diaryPreEdit(controller.context!, diaryList[index].id);
                            },
                            icon: Icons.edit,
                            label: "编辑",
                          ),
                          SlidableAction(
                            backgroundColor: Colors.greenAccent,
                            onPressed: (BuildContext context) async{
                              await diaryPreView(controller.context!, diaryList[index].id);
                            },
                            icon: Icons.remove_red_eye_rounded,
                            label: "查看",
                          ),
                          SlidableAction(
                            backgroundColor: Colors.redAccent,
                            onPressed: (BuildContext context) async{
                              await diaryPreDelete(controller.context!, diaryList[index].diaryName, diaryList[index].id);
                            },
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
}
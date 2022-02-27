import 'package:book_app/api/diary_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/diary/diary_item.dart';
import 'package:book_app/model/diary/diary_item_vo.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_controller.dart';
import 'package:book_app/module/diary/add/item/diary_item_add_screen.dart';
import 'package:book_app/module/diary/home/diary_home_controller.dart';
import 'package:book_app/module/diary/view/diary_item_view_controller.dart';
import 'package:book_app/module/diary/view/diary_item_view_screen.dart';
import 'package:book_app/util/bottom_widget_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// 查看详情
diaryItemPreView(BuildContext context, DiaryItemVo diaryItemVo) async {
  diaryItemVo.diaryItemContent ??=
      await DiaryApi.diaryItemContent(diaryItemVo.diaryItemId);
  await BottomWidgetUtil.showCupertinoWidget<DiaryItemViewController,
          DiaryItemViewScreen>(
      context, DiaryItemViewController(), const DiaryItemViewScreen(),
      preFunction: (controller) {
    controller.initData(diaryItemVo);
  });
}

/// 编辑
diaryItemPreEdit(BuildContext context, DiaryItemVo diaryItemVo) async {
  diaryItemVo.diaryItemContent ??=
      await DiaryApi.diaryItemContent(diaryItemVo.diaryItemId);
  BottomWidgetUtil.showCupertinoWidget<DiaryItemAddController,
          DiaryItemAddScreen>(
      context, DiaryItemAddController(), const DiaryItemAddScreen(),
      preFunction: (controller) {
        DiaryItem diaryItem = DiaryItem();
        diaryItem.content = diaryItemVo.diaryItemContent;
        diaryItem.id = diaryItemVo.diaryItemId;
        diaryItem.diaryId = diaryItemVo.diaryId;
        diaryItem.diaryName = diaryItemVo.diaryName;
        diaryItem.name = diaryItemVo.diaryItemName;
    controller.initData(false, diaryItem);
  }).then((value) {
    if (value != null && value) {
      DiaryHomeController diaryHomeController = Get.find();
      diaryHomeController.refreshList();
    }
  });
}

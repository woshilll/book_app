
import 'package:book_app/api/diary_api.dart';
import 'package:book_app/model/diary/diary_item_vo.dart';
import 'package:book_app/module/diary/view/diary_item_view_controller.dart';
import 'package:book_app/module/diary/view/diary_item_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

diaryItemPreView(BuildContext context, DiaryItemVo diaryItemVo) async{
  diaryItemVo.diaryItemContent ??= await DiaryApi.diaryItemContent(diaryItemVo.diaryItemId);
  Get.put<DiaryItemViewController>(DiaryItemViewController());
  DiaryItemViewController controller = Get.find<DiaryItemViewController>();
  controller.initData(diaryItemVo);
  await showCupertinoModalBottomSheet(context: context, builder: (context) {
    return const DiaryItemViewScreen();
  });
  Get.delete<DiaryItemViewController>();
}
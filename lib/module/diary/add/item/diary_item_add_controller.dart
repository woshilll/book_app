import 'package:book_app/model/diary/diary_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryItemAddController extends GetxController {
  final formKey = GlobalKey<FormState>();
  DiaryItem diaryItem = DiaryItem();

  initData(bool isAdd, bool isEdit,var data) {
    if (isAdd) {
      // 新增
      diaryItem.diaryId = data["diaryId"];
      diaryItem.diaryName = data["diaryName"];
    } else {
      // 修改或查看
    }
  }
}
import 'package:book_app/api/diary_api.dart';
import 'package:book_app/model/diary/diary.dart';
import 'package:book_app/model/diary/diary_setting.dart';
import 'package:book_app/module/book/read/component/drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryAddController extends GetxController {

  final formKey = GlobalKey<FormState>();
  Diary? diary;
  bool isAdd = false;
  bool isView = false;
  initData(bool isAdd, bool isView, {Diary? diary}) {
    this.isAdd = isAdd;
    this.isView = isView;
    if (isAdd) {
      this.diary = Diary(diarySetting: DiarySetting(updateRemindCreator: "0", updateRemindReceiver: "0", receiverCanUpdate: "0"));
    } else {
      assert(diary != null);
      this.diary = diary;
    }
  }

  saveOrUpdate(context) async{
    if (isAdd) {
      await DiaryApi.addDiary(diary!);
    } else {
      await DiaryApi.updateDiary(diary!);
    }
    Navigator.pop(context, true);
  }
}
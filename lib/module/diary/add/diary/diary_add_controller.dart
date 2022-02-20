import 'package:book_app/model/diary/diary.dart';
import 'package:book_app/model/diary/diary_setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryAddController extends GetxController {

  final formKey = GlobalKey<FormState>();
  Diary diary = Diary(diarySetting: DiarySetting(updateRemindCreator: "0", updateRemindReceiver: "0", receiverCanUpdate: "0"));
}
import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/model/diary/diary_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

class DiaryItemAddController extends GetxController{
  final formKey = GlobalKey<FormState>();
  DiaryItem diaryItem = DiaryItem();
  FocusNode diaryNameFocusNode = FocusNode();
  FocusNode diaryItemNameFocusNode = FocusNode();
  FocusNode richTextFocusNode = FocusNode();
  QuillController quillController =  QuillController(document: Document(), selection: const TextSelection(extentOffset: 0, baseOffset: 0));
  ScrollController scrollController = ScrollController();
  BuildContext? context;

  initData(bool isAdd, bool isEdit,var data) {
    if (isAdd) {
      // 新增
      diaryItem.diaryId = data["diaryId"];
      diaryItem.diaryName = data["diaryName"];
    } else {
      // 修改或查看
    }
    richTextFocusNode.addListener(() {
      if (richTextFocusNode.hasFocus) {
        Log.i(111);
        Timer(Duration(milliseconds: 300), () {
          scrollController.animateTo(MediaQuery.of(context!).viewInsets.bottom, duration: Duration(milliseconds: 300), curve: Curves.ease);
        });
      }
    });
  }

  void unFocus() {
    diaryItemNameFocusNode.unfocus();
    diaryNameFocusNode.unfocus();
    richTextFocusNode.unfocus();
  }
  

}
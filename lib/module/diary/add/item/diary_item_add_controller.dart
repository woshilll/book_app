import 'dart:async';
import 'dart:convert';

import 'package:book_app/api/diary_api.dart';
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
  QuillController? quillController;
  ScrollController scrollController = ScrollController();
  BuildContext? context;
  bool isAdd = false;

  initData(bool isAdd, var data) {
    Document document;
    if (isAdd) {
      // 新增
      this.isAdd = true;
      diaryItem.diaryId = data["diaryId"];
      diaryItem.diaryName = data["diaryName"];
      document = Document();
    } else {
      // 修改
      this.isAdd = false;
      diaryItem = data;
      document = Document.fromJson(jsonDecode(jsonDecode(diaryItem.content!)));
    }
    quillController  =  QuillController(document: document, selection: const TextSelection(extentOffset: 0, baseOffset: 0));
    richTextFocusNode.addListener(() {
      if (richTextFocusNode.hasFocus) {
        Timer(const Duration(milliseconds: 300), () {
          scrollController.animateTo(MediaQuery.of(context!).viewInsets.bottom, duration: const Duration(milliseconds: 300), curve: Curves.ease);
        });
      }
    });
  }

  void unFocus() {
    diaryItemNameFocusNode.unfocus();
    diaryNameFocusNode.unfocus();
    richTextFocusNode.unfocus();
  }

  saveOrUpdate(context) async{
    diaryItem.content = jsonEncode(quillController!.document.toDelta().toJson());
    if (isAdd) {
      await DiaryApi.addDiaryItem(diaryItem);
    } else {
      await DiaryApi.updateDiaryItem(diaryItem);
    }
    Navigator.pop(context, true);
  }
  

}
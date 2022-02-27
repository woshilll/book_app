import 'dart:convert';

import 'package:book_app/model/diary/diary_item_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

class DiaryItemViewController extends GetxController{
  QuillController? quillController;
  DiaryItemVo? diaryItemVo;
  initData(DiaryItemVo diaryItemVo) {
    this.diaryItemVo = diaryItemVo;
    var json = jsonDecode(jsonDecode(diaryItemVo.diaryItemContent!));
    quillController = QuillController(document: Document.fromJson(json), selection: const TextSelection(baseOffset: 0, extentOffset: 0));
  }
}
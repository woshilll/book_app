import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DiaryEditController extends GetxController {

  QuillController? quillController;
  FocusNode focusNode = FocusNode();
  @override
  void onInit() {
    super.onInit();
    Document doc = Document();
    quillController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
  }
}
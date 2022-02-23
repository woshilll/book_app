import 'package:book_app/module/diary/component/edit/rich_text_edit_screen.dart';
import 'package:book_app/module/diary/view/diary_item_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryItemViewScreen extends GetView<DiaryItemViewController>{
  const DiaryItemViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RichTextEditScreen(FocusNode(), controller.quillController!, readonly: true,),
    );
  }

}
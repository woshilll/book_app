import 'package:book_app/module/diary/component/edit/rich_text_edit_screen.dart';
import 'package:book_app/module/diary/view/diary_item_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiaryItemViewScreen extends GetView<DiaryItemViewController>{
  const DiaryItemViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Container(
              alignment: Alignment.centerRight,
              child: Icon(Icons.timer_outlined, size: 30, color: Theme.of(context).primaryColor,),
            ),
            const SizedBox(height: 15,),
            Container(
              alignment: Alignment.center,
              child: Text("${controller.diaryItemVo!.diaryName}", style: Theme.of(context).textTheme.headline1,),
            ),
            const SizedBox(height: 15,),
            Container(
              alignment: Alignment.center,
              child: Text("${controller.diaryItemVo!.diaryItemName}", style: Theme.of(context).textTheme.headline3,),
            ),
            const SizedBox(height: 15,),
            Expanded(
              child: RichTextEditScreen(FocusNode(), controller.quillController!, readonly: true,),
            )
          ],
        ),
      ),
    );
  }

}
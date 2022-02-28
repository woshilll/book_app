import 'package:book_app/api/diary_api.dart';
import 'package:book_app/model/diary/diary.dart';
import 'package:book_app/module/diary/add/diary/diary_add_controller.dart';
import 'package:book_app/module/diary/add/diary/diary_add_screen.dart';
import 'package:book_app/module/diary/home/diary_home_controller.dart';
import 'package:book_app/util/bottom_widget_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 新增
diaryPreAdd(BuildContext context) async {
  BottomWidgetUtil.showCupertinoWidget<DiaryAddController,
      DiaryAddScreen>(
      context, DiaryAddController(), const DiaryAddScreen(),
      preFunction: (controller) {
        controller.initData(true, false);
      }
      ).then((value) {
    if (value != null && value) {
      DiaryHomeController diaryHomeController = Get.find();
      diaryHomeController.diaryList.clear();
    }
  });
}

/// 编辑
diaryPreEdit(BuildContext context, diaryId) async {
  Diary diary = await DiaryApi.getDiaryWithSetting(diaryId);
  BottomWidgetUtil.showCupertinoWidget<DiaryAddController,
      DiaryAddScreen>(
      context, DiaryAddController(), const DiaryAddScreen(),
      preFunction: (controller) {
        controller.initData(false, false, diary: diary);
      }
  ).then((value) {
    if (value != null && value) {
      // DiaryHomeController diaryHomeController = Get.find();
      // diaryHomeController.diaryList.clear();
    }
  });
}
/// 查看
diaryPreView(BuildContext context, diaryId) async {
  Diary diary = await DiaryApi.getDiaryWithSetting(diaryId);
  BottomWidgetUtil.showCupertinoWidget<DiaryAddController,
      DiaryAddScreen>(
      context, DiaryAddController(), const DiaryAddScreen(),
      preFunction: (controller) {
        controller.initData(false, true, diary: diary);
      }
  ).then((value) {
    if (value != null && value) {
      // DiaryHomeController diaryHomeController = Get.find();
      // diaryHomeController.diaryList.clear();
    }
  });
}

diaryPreDelete(BuildContext context, title, diaryId) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text("温馨提示"),
          titlePadding: const EdgeInsets.all(10),
          titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
          content: Text.rich(
            TextSpan(
                text: "你确定要删除日记本<<",
                children: [
                  TextSpan(
                      text: title,
                      style: const TextStyle(color: Colors.redAccent)
                  ),
                  const TextSpan(
                      text: ">>吗?"
                  )
                ]
            ),
          ),
          contentPadding: const EdgeInsets.all(10),
          //中间显示内容的文本样式
          contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          actions: [
            ElevatedButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("确定"),
              onPressed: () async{
                await DiaryApi.deleteDiary(diaryId);
                DiaryHomeController diaryController = Get.find();
                diaryController.diaryList.removeWhere((element) => element.id == diaryId);
                diaryController.update(["diaryList"]);
                diaryController.refreshList();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
  );
}
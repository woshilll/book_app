import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
import 'package:book_app/util/bottom_bar_build.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

pageStyleBottom(context, ReadMoreSettingController controller) {
  var list = [
    ["滑动翻页", ReadPageType.slide],
    ["上下滑动翻页", ReadPageType.slideUpDown],
    ["点击翻页", ReadPageType.point],
  ];
  ReadController readController = Get.find();
  Get.bottomSheet(BottomBarBuild(
    "选项",
    list.map((e) => BottomBarBuildItem(
      "${e.first}",
      () {
        Get.back();
        ReadPageType readPageType = e[1] as ReadPageType;
        if (readController.readPageType != readPageType) {
          readController.setPageType(readPageType);
          controller.fresh();
          Navigator.of(context).pop();
        }
      },
    )).toList()
  ));
  // showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Opacity(
  //         opacity: .7,
  //         child: SizedBox(
  //           height: 51 * list.length + 16,
  //           child:,
  //         ),
  //       );
  //     });
}

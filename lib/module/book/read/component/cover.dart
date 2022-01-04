import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/page_turn_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content.dart';
/// 覆盖
Widget cover() {
  ReadController controller = Get.find();
  return Listener(
    child: PageTurnWidget(
      amount: controller.coverController,
      child: content(controller.context, controller.pageIndex, controller),
    ),
    // PageView.builder(
    //   controller: controller.contentPageController,
    //   itemCount: controller.pages.length,
    //   itemBuilder: (context, index) {
    //     return content(context, index, controller);
    //   },
    //   onPageChanged: (index) async {
    //     controller.pageIndex = index;
    //     if (index + 10 >= controller.pages.length &&
    //         !controller.loading) {
    //       await controller.pageChangeListen(index);
    //     }
    //   },
    // ),
    onPointerDown: (e) {
      controller.autoPageCancel();
      controller.xMove = e.position.dx;
    },
    onPointerUp: (e) async {
      double move = e.position.dx - controller.xMove;
      // 滑动了五十距离, 且当前为0
      if (move > 50 && controller.pageIndex == 0) {
        await controller.prePage();
      } else if (move < -50 &&
          controller.pageIndex == controller.pages.length - 1) {
        await controller.nextPage();
      }
    },
  );
}

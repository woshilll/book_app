import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content.dart';
/// 覆盖
Widget cover() {
  return GetBuilder<ReadController>(
    id: ReadRefreshKey.content,
    builder: (controller) {
      return Listener(
        child: Container(),
        // onPointerDown: (e) {
        //   controller.autoPageCancel();
        //   controller.xMove = e.position.dx;
        // },
        // onPointerUp: (e) async {
        //   double move = e.position.dx - controller.xMove;
        //   // 滑动了五十距离, 且当前为0
        //   if (move > 50 && controller.pageIndex.count == 0) {
        //     await controller.prePage();
        //   } else if (move < -50 &&
        //       controller.pageIndex.count == controller.pages.length - 1) {
        //     await controller.nextPage();
        //   }
        // },
      );
    },
  );
}

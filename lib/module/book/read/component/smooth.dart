import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content.dart';
/// 平滑
Widget smooth({PageTransformer? transformer}) {
  return GetBuilder<ReadController>(
    id: "content",
    builder: (controller) {
      return Listener(
        child: TransformerPageView(
          transformer: transformer,
          controller: controller.contentPageController,
          itemCount: controller.pages.length,
          itemBuilder: (context, index) {
            return content(context, index, controller);
          },
          onPageChanged: (index) async {
            controller.pageIndex.setCount(index!);
          },
        ),
        onPointerDown: (e) {
          controller.autoPageCancel();
          controller.xMove = e.position.dx;
        },
        onPointerUp: (e) async {
          double move = e.position.dx - controller.xMove;
          // 滑动了五十距离, 且当前为0
          if (move > 50 && controller.pageIndex.count == 0) {
            await controller.prePage();
          } else if (move < -50 &&
              controller.pageIndex.count == controller.pages.length - 1) {
            await controller.nextPage();
          }
        },
      );
    },
  );
}

import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/custom_page_view.dart';
import 'package:book_app/util/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content.dart';
/// 滑动翻页
Widget slide({Axis scrollDirection = Axis.horizontal}) {
  return GetBuilder<ReadController>(
    id: ReadRefreshKey.content,
    builder: (controller) {
      return Listener(
        child: CustomPageView.builder(
          scrollDirection: scrollDirection,
          controller: controller.contentPageController,
          itemCount: controller.pages.length,
          itemBuilder: (context, index) {
            return KeepAliveWrapper(content(context, index, controller));
          },
          onPageChanged: (index) async {

          },
          onPageStartChanged: (_) {
            controller.isSliding.update(true);
          },
          onPageEndChanged: (index) {
            controller.isSliding.update(false);
            controller.pageIndex.setCount(index);
          },
        ),
        onPointerDown: (e) {
          controller.autoPageCancel();
          if (controller.readPageType == ReadPageType.slideUpDown) {
            // 上下滑动
            controller.xMove = e.position.dy;
          } else {
            controller.xMove = e.position.dx;
          }
        },
        onPointerUp: (e) async {
          double move = 0;
          if (controller.readPageType == ReadPageType.slideUpDown) {
            // 上下滑动
            move = e.position.dy - controller.xMove;
          } else {
            move = e.position.dx - controller.xMove;
          }
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

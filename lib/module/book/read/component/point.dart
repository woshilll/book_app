import 'package:book_app/module/book/read/component/smooth.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content.dart';

/// 点击
Widget point() {
  ReadController controller = Get.find();
  if (controller.pages.isEmpty) {
    return Container();
  }
  return GetBuilder<ReadController>(
    id: 'point',
    builder: (controller) {
      return AnimatedOpacity(
        opacity: controller.pointShow ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: content(controller.context, controller.pageIndex, controller),
      );
    },
  );
}

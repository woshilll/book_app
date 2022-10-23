import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'content.dart';

/// 点击
Widget point() {
  return GetBuilder<ReadController>(
    id: ReadRefreshKey.content,
    builder: (controller) {
      if (controller.pages.isEmpty) {
        return Container();
      }
      return content(controller.context, controller.pageIndex.count, controller);
    },
  );
}

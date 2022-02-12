import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';

import 'battery.dart';

/// 小说名和电池
Widget contentTop(context, ReadController controller) {
  return SizedBox(
    height: controller.screenTop,
    width: controller.screenWidth,
    child: Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 15),
              child: Text("${controller.book == null ? "" : controller.book!.name}", maxLines: 1, style: const TextStyle(height: 1, color: Colors.grey)),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 15),
            child: battery(),
          ),
        ],
      ),
    ),
  );
}
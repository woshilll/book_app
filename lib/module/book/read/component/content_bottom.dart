
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';

Widget contentBottom(context, index, ReadController controller) {
  return Container(
    height: controller.screenBottom,
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 25),
            child: Text(
              "${controller.pages[index].chapterName}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 25),
          child: Text(
            "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        )
      ],
    ),
  );
}
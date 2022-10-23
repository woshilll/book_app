
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';

Widget contentBottom(context, index, ReadController controller) {
  return Container(
    height: controller.pageGen.screenBottom,
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        const SizedBox(width: 25,),
        Expanded(
          child: Text(
            "${controller.pages[index].chapterName}",
            maxLines: 1,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Text(
          "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 25,),
      ],
    ),
  );
}
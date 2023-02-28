import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/dialog_build.dart';
import 'package:book_app/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'html_parse_util.dart';

parseBookByShare(String bookName, String content) async{
  Get.dialog(
      DialogBuild(
          "分享小说",
          Text.rich(
            TextSpan(
              text: "是否解析来自其它APP分享的小说",
              children: [
                TextSpan(text: bookName, style: const TextStyle(color: Colors.lightBlueAccent))
              ],
              style: TextStyle(color: textColor(), fontSize: 14)
            )
          ),
        confirmFunction: () {
          Get.back();
          Future.delayed(const Duration(milliseconds: 500), () {
            BookHomeController bookHomeController = Get.find();
            bookHomeController.parseBookText(content.split("\n"), bookName);
          });
        },
      )
  );
}

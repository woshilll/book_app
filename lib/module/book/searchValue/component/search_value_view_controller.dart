import 'package:book_app/api/book_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SearchValueViewController extends GetxController {
  BookDbProvider _bookDbProvider = BookDbProvider();
  BuildContext context = globalContext;
  String url = "";
  @override
  void onInit() async {
    super.onInit();
    var map = Get.arguments;
    Log.i(map.toString());
    url = map["url"];
  }

  @override
  void onReady() async {
    super.onReady();
  }

  void addBook() {
    if (url.endsWith("html") || url.endsWith("htm")) {
      // 是小说章节
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: const Text("温馨提示"),
              titlePadding: const EdgeInsets.all(10),
              titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
              content: const Text.rich(
                TextSpan(
                    text: "非目录章节, 是否确定尝试解析目录？ "
                ),
              ),
              contentPadding: const EdgeInsets.all(10),
              //中间显示内容的文本样式
              contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
              actions: [
                ElevatedButton(
                  child: const Text("取消"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text("确定"),
                  onPressed: () async{
                    String chapterUrl = url;
                    chapterUrl = chapterUrl.substring(0, chapterUrl.lastIndexOf("/") + 1);
                    await parseBook(chapterUrl);
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
      );
    } else {
      // 是目录
      parseBook(url);
    }
  }
  parseBook(url) async{
    dynamic count = await _bookDbProvider.getBookCount(url);
    if (count > 0) {
      EasyLoading.showToast("小说已存在书架");
      return;
    }
    Book book = await BookApi.parseBook(url);
    await _bookDbProvider.commonInsert(book);
    EasyLoading.showToast("添加书架成功");
  }
}



import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class SearchValueController extends GetxController {
  InAppWebViewController? webViewController;
  final BookDbProvider _bookDbProvider = BookDbProvider();
  final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  bool showParseButton = false;
  double loadProcess = 0;
  bool showLoadProcess = false;
  int siteIndex = 0;

  List<List<String>> sites =  [
      ["神马小说", "https://quark.sm.cn/s?q=&from=smor&safe=1"],
      ["360搜索", "https://m.so.com/s?q="],
      ["必应搜索", "https://cn.bing.com/search?q="],
    ];

  pop() async{
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        for (int i = 0; i < sites.length; i++) {
          if (sites[i][1].contains((await webViewController!.getUrl())!.origin)) {
            Get.back();
            break;
          }
        }
        webViewController!.goBack();
      } else {
        Get.back();
      }
    } else {
      Get.back();
    }
  }

  parse() async{
    try {
      String url = (await webViewController!.getUrl())!.toString();
      dynamic count = await _bookDbProvider.getBookCount(url);
      if (count > 0) {
        EasyLoading.showToast("小说已存在书架");
        return;
      }
      await EasyLoading.show(status: "解析中...", maskType: EasyLoadingMaskType.clear);
      String? img;
      var chapters = await HtmlParseUtil.parseChapter(url, img: (imgUrl) {
        img = imgUrl;
      });
      final Book book = Book(url: url, name: await webViewController!.getTitle(), indexImg: img);
      var bookId = await _bookDbProvider.commonInsert(book);
      for (var e in chapters) {
        e.bookId = bookId;
      }
      await _chapterDbProvider.commonBatchInsert(chapters);
      await EasyLoading.dismiss();
      EasyLoading.showToast("解析完成, 共 ${chapters.length} 章节");
    } catch(err) {
      Log.e(err);
      EasyLoading.dismiss();
      EasyLoading.showToast("解析失败");
    }

  }

  @override
  void onClose() {
    super.onClose();
    BookHomeController bookHomeController = Get.find();
    bookHomeController.getBookList();
  }
}

class ValueFormat {
  String content;
  bool red;

  ValueFormat(this.content, this.red);
}

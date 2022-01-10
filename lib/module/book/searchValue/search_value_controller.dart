import 'dart:async';

import 'package:book_app/api/book_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/search/search_history.dart';
import 'package:book_app/model/search/search_result.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SearchValueController extends GetxController {
  // late SearchHistory site;
  // List<SearchResult> searchResults = [];
  InAppWebViewController? webViewController;
  String? keyword;
  final BookDbProvider _bookDbProvider = BookDbProvider();
  final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  String? site;
  bool showParseButton = false;
  @override
  void onInit() async {
    super.onInit();
    var map = Get.arguments;
    keyword = map["keyword"];
    site = map["site"];
  }

  @override
  void onReady() async {
    super.onReady();
    // searchResults = await BookApi.getSearchResults(site.label, site.site);
    // update(["result"]);
  }

  Widget buildRichText(str, double fontSize, FontWeight fontWeight) {
    List<ValueFormat> lines = [];
    int index = 0;
    while (index + 7 < str.length) {
      index = str.indexOf("<strong>");
      if (index == -1) {
        lines.add(ValueFormat(str, false));
        break;
      }
      String content = str.substring(0, index);
      if (content.isNotEmpty) {
        lines.add(ValueFormat(content, false));
      }
      str = str.substring(index + 8);
      index = str.indexOf("</strong>");
      String content2 = str.substring(0, index);
      lines.add(ValueFormat(content2, true));
      str = str.substring(index + 9);
    }
    if (str.isNotEmpty) {
      lines.add(ValueFormat(str, false));
    }
    return Text.rich(TextSpan(
        children: List.generate(lines.length, (i) {
      if (lines[i].red) {
        return TextSpan(
            text: lines[i].content, style: TextStyle(color: Colors.red, fontSize: fontSize, fontWeight: fontWeight));
      }
      return TextSpan(
        text: lines[i].content,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: Theme.of(globalContext).textTheme.bodyText1!.color)
      );
    })));
  }

  pop() async{
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
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
      var chapters = await HtmlParseUtil.parseChapter(url);
      final Book book = Book(url: url, name: await webViewController!.getTitle());
      var bookId = await _bookDbProvider.commonInsert(book);
      chapters.forEach((Chapter e) {
        e.bookId = bookId;
      });
      await _chapterDbProvider.commonBatchInsert(chapters);
      EasyLoading.dismiss();
      EasyLoading.showToast("解析完成");
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

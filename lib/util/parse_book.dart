import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'html_parse_util.dart';

/// 小说解析
parseBook(String bookName, String bookUrl, {bool isShare = false}) async {
  BookDbProvider _bookDbProvider = BookDbProvider();
  ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  try {
    dynamic count = await _bookDbProvider.getBookCount(bookUrl);
    if (count > 0) {
      EasyLoading.showToast("小说已存在书架");
      return;
    }
    await EasyLoading.show(
        status: "解析中...", maskType: EasyLoadingMaskType.clear);
    String? img;
    var results = (await HtmlParseUtil.parseChapter(bookUrl, img: (imgUrl) {
      img = imgUrl;
    }, isShare: isShare));
    bookUrl = results[0];
    var chapters = results[1];
    final Book book = Book(url: bookUrl, name: bookName, indexImg: img);
    var bookId = await _bookDbProvider.commonInsert(book);
    for (var e in chapters) {
      e.bookId = bookId;
    }
    await _chapterDbProvider.commonBatchInsert(chapters);
    await EasyLoading.dismiss();
    EasyLoading.showToast("解析完成, 共 ${chapters.length} 章节");
    BookHomeController homeController = Get.find();
    homeController.getBookList();
  } catch (err) {
    Log.e(err);
    EasyLoading.dismiss();
    EasyLoading.showToast("解析失败");
  }
}

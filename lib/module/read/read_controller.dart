import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadController extends GetxController {
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  late Book book;
  List<Chapter> chapters = [];
  Chapter curChapter = Chapter(content: "");
  var drawerY = 0.0.obs;
  @override
  void onInit() async{
    super.onInit();
    var map = Get.arguments;
    book = map["book"];
    await initData();
  }

  initData() async{
    chapters = await _chapterDbProvider.getChapters(null, book.id);
    curChapter = chapters[0];
    if (book.curChapter != null) {
      int index = chapters.indexWhere((element) => element.id == book.curChapter);
      if (index >= 0) {
        curChapter = chapters[index];
      }
    }
    // 找到了当前的chapter
    // 查找内容
    Chapter? temp = await _chapterDbProvider.getChapterById(curChapter.id);
    var content = temp?.content;
    if (content == null) {
      content = await DioManager.getInstance().get<String>(url: "/parse/book/content", params: {"url": curChapter.url});
      await _chapterDbProvider.updateContent(curChapter.id, content);
    }
    // 赋值
    curChapter.content = content;
    Log.i("init");
    update(["content"]);
  }
  cal(context) {
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: "${curChapter.content}",
        style: const TextStyle(fontSize: 18, height: 1.8),
      )
    );
    painter.layout(maxWidth: MediaQuery.of(context).size.width - 20);
    Log.i(MediaQuery.of(context).size.height);
    Log.i(painter.height);
  }
}
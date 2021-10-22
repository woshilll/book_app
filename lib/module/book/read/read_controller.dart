import 'dart:async';

import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'component/content_page.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadController extends GetxController {
  /// 数据库
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  /// 主页传来的书籍信息
  late Book book;
  /// 所有章节
  List<Chapter> chapters = [];
  /// 上下文
  BuildContext context = globalContext;
  List<ContentPage> pages = [];
  final TextPainter _painter = TextPainter(textDirection: TextDirection.ltr);
  TextStyle contentStyle = const TextStyle(color: Colors.green, fontSize: 22);
  @override
  void onInit() async{
    super.onInit();
    var map = Get.arguments;
    book = map["book"];
    await initData();
  }
  initData() async{
    chapters = await _chapterDbProvider.getChapters(null, book.id);
    Chapter cur = chapters[0];
    int index = 0;
    if (book.curChapter != null) {
      index = chapters.indexWhere((element) => element.id == book.curChapter);
      if (index >= 0) {
        cur = chapters[index];
      }
    }
    cur.content = await getContent(cur.id, cur.url);
    await initPage(cur);
  }
  initPage(Chapter chapter) async {
    calWordHeightAndWidth();
    String content = alphanumericToFullLength(chapter.content);
    _painter.text = TextSpan(text: content, style: contentStyle);
    // 一页最大行数
    double screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 30;
    // 第一页最大行数
    int maxLines = screenHeight ~/ wordHeight;
    _painter.maxLines = maxLines;
    // 统计第一页字符偏移量
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    int offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    // 得到第一页偏移量
    int preOffset = 0;
    int i = 1;
    // 先加载几页，然后再一点点加载
    for (int j = 0; j < 4; j++) {
      if (offset >= content.length) {
        String subContent = content.substring(preOffset, offset);
        pages.add(
            ContentPage(subContent, contentStyle, i, chapter.id, chapter.name, wordWith));
        i++;
        return;
      }
      String subContent = content.substring(preOffset, offset);
      pages.add(
          ContentPage(subContent, contentStyle, i, chapter.id, chapter.name, wordWith));
      i++;
      preOffset = offset;
      _painter.maxLines = maxLines * i;
      _painter.layout(maxWidth: MediaQuery.of(context).size.width);
      paintWidth = _painter.width;
      paintHeight = _painter.height;
      offset =
          _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    }
    Timer(const Duration(milliseconds: 300), () {
      pageRecursion(i, maxLines, preOffset, offset, content, chapter);
      update(["content"]);
    });
  }

  Future pageRecursion(int index, int maxLines, int preOffset, int offset,
      String content, Chapter chapter) async {
    String subContent;
    if (offset >= content.length) {
      subContent = content.substring(preOffset);
      pages.add(
          ContentPage(subContent, contentStyle, index, chapter.id, chapter.name, wordWith));
      index++;
      return;
    }
    subContent = content.substring(preOffset, offset);
    pages.add(ContentPage(subContent,contentStyle, index, chapter.id, chapter.name, wordWith));
    index++;
    preOffset = offset;
    _painter.maxLines = maxLines * index;
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    pageRecursion(index, maxLines, preOffset, offset, content, chapter);
  }
  Future<String> getContent(id, url) async{
    // 查找内容
    Chapter? temp = await _chapterDbProvider.getChapterById(id);
    var content = temp?.content;
    if (content == null) {
      content = await ChapterApi.parseContent(url);
      await _chapterDbProvider.updateContent(id, content);
    }
    // 赋值
    return content;
  }

  String alphanumericToFullLength(str) {
    var temp = str.codeUnits;
    final regex = RegExp(r'^[a-zA-Z0-9!,.@#$%^&*()@￥?]+$');
    final string = temp.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune + 65248) : char;
    });
    return string.join();
  }

  String alphanumericToHalfLength(String str) {
    var runes = str.codeUnits;
    final regex = RegExp(r'^[Ａ-Ｚａ-ｚ０-９]+$');
    final string = runes.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune - 65248) : char;
    });
    return string.join();
  }

  double wordHeight = 0;
  double wordWith = 0;
  int maxLines = 0;

  calWordHeightAndWidth() {
    if (wordHeight > 0) {
      return;
    }
    _painter.text = TextSpan(text: "哈", style: contentStyle);
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    var cal = _painter.computeLineMetrics()[0];
    wordHeight = cal.height;
    wordWith = cal.width;
    maxLines = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top) ~/
        wordHeight;
  }
  calThisChapterTotalPage(index) {
    var chapterId = pages[index].chapterId;
    return pages.lastIndexWhere((element) => element.chapterId == chapterId) - pages.indexWhere((element) =>  element.chapterId == chapterId) + 1;
  }

  /// 页面变化监听
  Future pageChangeListen(int index) async{
    var chapterId = pages[index].chapterId;
    index = chapters.indexWhere((element) => element.id == chapterId);
    if (index == chapters.length - 1) {
      // 没有了
      return;
    }
    Chapter chapter = chapters[index + 1];
    chapter.content = await getContent(chapter.id, chapter.url);
    initPage(chapter);
  }
}

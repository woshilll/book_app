import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadController extends GetxController {
  /// 数据库
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  /// 主页传来的书籍信息
  late Book book;
  /// 所有章节
  List<Chapter> chapters = [];
  /// 当前章节
  Chapter curChapter = Chapter(content: "");
  /// 已经读的章节列表
  List<Chapter> readChapters = [];
  late BuildContext context;
  var drawerY = 0.0.obs;

  ScrollController contentController = ScrollController();
  bool loading = false;
  @override
  void onInit() async{
    super.onInit();
    var map = Get.arguments;
    book = map["book"];
    await initData();
    await listener();
  }
  listener() async {
    contentController.addListener(() async{
      // 3213.3636363636365
      if (contentController.position.maxScrollExtent <= contentController.offset + 1000) {
        // 到达底部， 加载更多
        if (loading) {
          return;
        }
        loading = true;
        await loadTenChapter();
      }
    });
  }

  initData() async{
    chapters = await _chapterDbProvider.getChapters(null, book.id);
    curChapter = chapters[0];
    int index = 0;
    if (book.curChapter != null) {
      index = chapters.indexWhere((element) => element.id == book.curChapter);
      if (index >= 0) {
        curChapter = chapters[index];
      }
    }
    // 默认先缓存10章
    // 找到了当前的chapter
    curChapter.content = await getContent(curChapter.id, curChapter.url);
    readChapters.add(curChapter);
    await loadTenChapter();
  }
  loadTenChapter() async {
    // 找到最后一个id
    int index = chapters.indexWhere((element) => element.id == readChapters[readChapters.length - 1].id);
    for (int i = index + 1; i <= index + 10; i++) {
      if (i >= chapters.length) {
        break;
      }
      Chapter temp = chapters[i];
      Log.i(temp.name);
      temp.content = await getContent(temp.id, temp.url);
      readChapters.add(temp);
    }
    update(["content"]);
    loading = false;
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
  cal(context) {
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: "${curChapter.content}",
        style: const TextStyle(fontSize: 18, height: 1.8),
      )
    );
    painter.layout(maxWidth: MediaQuery.of(context).size.width - 15);
    Log.i(MediaQuery.of(context).size.height);
    Log.i(painter.height);
  }

  /// 跳转到某一章节
  jumpTo(index) async {
    // 查询缓存中是否存在
    int tempIndex = readChapters.indexWhere((element) => chapters[index].id == element.id);
    if (tempIndex >= 0) {
      // 存在
      readChapters.removeRange(0, tempIndex);
    } else {
      // 不存在
      readChapters.clear();
      Chapter temp = chapters[index];
      temp.content = await getContent(temp.id, temp.url);
      readChapters.add(temp);
    }
    Navigator.of(context).pop();
    update(['content']);
    contentController.jumpTo(0);
  }

  @override
  void onClose() {
    super.onClose();
    Log.i("close");
    contentController.dispose();
  }
}

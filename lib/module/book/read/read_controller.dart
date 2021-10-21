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
  /// 上下文
  late BuildContext context;

  /// 文本滚动控制器
  ScrollController contentController = ScrollController();
  /// 目录滚动控制器
  ScrollController menuController = ScrollController();
  /// 文本是否在加载
  bool loading = false;
  /// 屏幕宽度
  double screenWidth = 0;
  /// 屏幕高度
  double screenHeight = 0;
  /// 目录高度
  double menuHeight = 50;
  bool menuJumpFlag = false;
  final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
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
      if (contentController.offset <= 0  && !loading) {
        // 向上加载
        Chapter temp = readChapters[0];
        // 找到最顶上的章节
        int index = chapters.indexWhere((element) => temp.id == element.id);
        // 找到最上面章节对应的所以
        if (index > 0) {
          // 说明前面还有章节
          temp = chapters[index - 1];
          temp.content ??= await getContent(temp.id, temp.url);
          temp.height = calChapterHeight(temp);
          readChapters.insert(0, temp);
          contentController.jumpTo(temp.height);
          // update(["content"]);
        }
        loading = false;
      }
      else if (contentController.position.maxScrollExtent <= contentController.offset + 1000 && !loading) {
        // 到达底部， 加载更多
        if (loading) {
          return;
        }
        await loadChapter(5);
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
    curChapter.height = calChapterHeight(curChapter);
    readChapters.add(curChapter);
    await loadChapter(5);
  }
  loadChapter(page) async {
    loading = true;
    // 找到最后一个id
    int index = chapters.indexWhere((element) => element.id == readChapters[readChapters.length - 1].id);
    for (int i = index + 1; i <= index + page; i++) {
      if (i >= chapters.length) {
        break;
      }
      Chapter temp = chapters[i];
      temp.content = await getContent(temp.id, temp.url);
      temp.height = calChapterHeight(temp);
      readChapters.add(temp);
      update(["content"]);
    }
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
  calChapterHeight(Chapter chapter) {
    if (screenWidth <= 0) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
    }
    painter.text = TextSpan(
        children: [
          TextSpan(
            text: "${chapter.name}",
            style: const TextStyle(fontSize: 18, height: 3, fontWeight: FontWeight.bold),
          ),
          const TextSpan(
            text: "\n",
          ),
          TextSpan(
            text: "${chapter.content}",
            style: const TextStyle(fontSize: 18, height: 1.8),
          )
        ]
    );
    painter.layout(maxWidth: screenWidth);
    return painter.height;
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
    curChapter = readChapters[0];
    // update(['content']);
    contentController.jumpTo(0);
  }

  @override
  void onClose() {
    super.onClose();
    Log.i("close");
    contentController.dispose();
    menuController.dispose();
  }

  /// 计算当滚动停止后的当前chapter
  void calWhenScrollEndCurChapter(double pixels) {
    double preHeight = 0;
    for (int i = 0; i < readChapters.length; i++) {
      Chapter value = readChapters[i];
      double height = preHeight + value.height;
      if (pixels >= preHeight && pixels < height) {
        // 找到当前章节
        curChapter = value;
        break;
      } else {
          preHeight += value.height;
      }
    }
  }

  /// 目录滚动
  void menuJump() {
    if (menuJumpFlag) {
      return;
    }
    int index = chapters.indexWhere((element) => element.id == curChapter.id);
    menuController = ScrollController(initialScrollOffset: index * menuHeight);
    menuJumpFlag = true;
  }
}

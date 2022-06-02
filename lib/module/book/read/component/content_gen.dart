import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/html_parse_util.dart';


final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();

contentGen(Chapter chapter, Book book) async{
  await _getContent(chapter, book);
}

/// 获取章节内容
_getContent(Chapter chapter, Book book) async{
  // 查找内容
  Chapter? temp = await _chapterDbProvider.getChapterById(chapter.id);
  var content = temp?.content;
  if ((content == null || content.isEmpty) && book.type == 1) {
    Chapter? nextChapter = await _chapterDbProvider.getNextChapter(chapter.id, book.id);
    content = await HtmlParseUtil.parseContent(chapter.name!, chapter.url!, nextChapter?.url);
    // 格式化文本
    content = FontUtil.formatContent(content);
    await _chapterDbProvider.updateContent(chapter.id, content);
  }
  // 赋值
  chapter.content = content;
}
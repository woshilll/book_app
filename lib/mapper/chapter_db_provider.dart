import 'package:book_app/db/base_db_provider.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:sqflite/sqflite.dart';

/// 章节
class ChapterDbProvider extends BaseDbProvider {
  /// 表名
  final String name = "chapter";

  /// 表字段
  /// 主键
  final String columnId = "id";
  final String columnBookId = "bookId";
  /// 书名
  final String columnName = "name";
  /// 书的介绍
  final String columnContent = "content";
  final String columnUrl = "url";
  @override
  createTableString() {
    return '''
      create table $name 
      (
        $columnId integer primary key AUTOINCREMENT, 
        $columnName text not null, 
        $columnBookId integer not null, 
        $columnContent text, 
        $columnUrl text not null
      )
    ''';
  }

  @override
  tableName() {
    return name;
  }

  /// 获取章节详情
  Future<Chapter?> getChapterById(id) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $name where $columnId = $id");
    if (maps.isEmpty) {
      return null;
    }
    return Chapter.fromJson(maps[0]);
  }

  /// 获取章节列表详情
  Future<List<Chapter>> getChapters(startId, bookId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select $columnId, $columnName, $columnUrl from $name where $columnBookId = ? ${startId == null ? '' : 'and id >= $startId' } order by $columnId asc", [bookId]);
    List<Chapter> list = [];
    for (var element in maps) {
      list.add(Chapter.fromJson(element));
    }
    return list;
  }

  Future<Chapter?> getNextChapter(startId, bookId) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select $columnId, $columnName, $columnUrl from $name where $columnBookId = ? and id > ? order by $columnId asc limit 1", [bookId, startId]);
    List<Chapter> list = [];
    for (var element in maps) {
      list.add(Chapter.fromJson(element));
    }
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  /// 获取章节列表详情
  Future<int?> getChapterCount(bookId) async {
    Database db = await getDataBase();
    return Sqflite.firstIntValue(await db.rawQuery("select count(*) from $name where $columnBookId = ?", [bookId]));
  }

  /// 获取当前章节位置
  Future<int?> getCurChapterCount(bookId, chapterId) async {
    if (chapterId == null) {
      return 0;
    }
    Database db = await getDataBase();
    return Sqflite.firstIntValue(await db.rawQuery("select count(*) from $name where $columnBookId = ? and $columnId <= ?", [bookId, chapterId]));
  }

  Future<void> updateContent(id, content) async{
    Database db = await getDataBase();
    await db.rawUpdate(
      '''
      update $name
      set $columnContent = ?
      where $columnId = ?
      ''',
      [content, id]
    );
  }

  Future<void> deleteByBookId(bookId) async{
    Database db = await getDataBase();
    await db.rawDelete(
      '''
      delete from $name
      where $columnBookId = ?
      ''',
      [bookId]
    );
  }

  Future<Chapter?> getNext(bookId, curChapterId) async{
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $name where $columnBookId = $bookId and $columnId > $curChapterId limit 1");
    if (maps.isEmpty) {
      return null;
    }
    return Chapter.fromJson(maps[0]);
  }

  Future<int?> getUnCacheCount(int id) async{
    Database db = await getDataBase();
    return Sqflite.firstIntValue(await db.rawQuery("select count(*) from $name where $columnBookId = ? and ($columnContent is null or trim($columnContent) = '')", [id]));
  }

  Future<List<Chapter>> getChaptersWithContent(int bookId) async{
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select $columnId, $columnName, $columnContent, $columnUrl from $name where $columnBookId = ? order by $columnId asc", [bookId]);
    List<Chapter> list = [];
    for (var element in maps) {
      list.add(Chapter.fromJson(element));
    }
    return list;
  }
}

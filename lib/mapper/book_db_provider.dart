import 'package:book_app/db/base_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:sqflite/sqflite.dart';

class BookDbProvider extends BaseDbProvider {
  /// 表名
  final String name = "book";

  /// 表字段
  /// 主键
  final String columnId = "id";
  /// 书名
  final String columnName = "name";
  /// 书的介绍
  final String columnDescription = "description";
  /// 书的作者
  final String columnAuthor = "author";
  /// 书的封面
  final String columnIndex = "indexImg";
  /// 当前阅读的章节
  final String columnCurChapter = "curChapter";
  /// 当前阅读的章节里的页数
  final String columnCurPage = "curPage";
  final String columnUrl = "url";
  final String columnType = "type";
  @override
  createTableString() {
    return '''
      create table $name 
      (
        $columnId integer primary key AUTOINCREMENT, 
        $columnName text not null, 
        $columnDescription text, 
        $columnAuthor text, 
        $columnIndex text, 
        $columnCurChapter integer, 
        $columnCurPage integer,
        $columnUrl text not null,
        $columnType integer not null
      )
    ''';
  }

  @override
  tableName() {
    return name;
  }

  /// 获取书籍详情
  Future<Book?> getBookById(id) async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $name where $columnId = $id");
    if (maps.isEmpty) {
      return null;
    }
    return Book.fromJson(maps[0]);
  }

  /// 获取书籍列表详情
  Future<List<Book>> getBooks() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.rawQuery("select * from $name order by $columnId asc");
    List<Book> list = [];
    for (var element in maps) {
      list.add(Book.fromJson(element));
    }
    return list;
  }
  /// 获取书籍数量
  Future<int?> getBookCount(url) async {
    Database db = await getDataBase();
    return Sqflite.firstIntValue(await db.rawQuery("select count(*) from $name where $columnUrl = ?", [url]));
  }

  /// 更新阅读章节
  updateCurChapter(id, chapterId, page) async{
    Database db = await getDataBase();
    await db.rawUpdate("update $name set $columnCurChapter = ?, $columnCurPage = ? where $columnId = ?", [chapterId, page, id]);
  }

}

import 'package:book_app/db/sql_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/base.dart';
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';


abstract class BaseDbProvider {
  bool isTableExits = false;

  createTableString();

  tableName();

  ///创建表sql语句
  tableBaseString(String sql) {
    return sql;
  }

  Future<Database> getDataBase() async {
    return await open();
  }

  ///super 函数对父类进行初始化
  @mustCallSuper
  prepare(name, String createSql) async {
    isTableExits = await SqlManager.isTableExits(name);
    if (!isTableExits) {
      Database db = await SqlManager.getCurrentDatabase();
      return await db.execute(createSql);
    }
  }

  @mustCallSuper
  open() async {
    if (!isTableExits) {
      await prepare(tableName(), createTableString());
    }
    return await SqlManager.getCurrentDatabase();
  }

  Future<void> commonDelete(id) async {
    Database db = await getDataBase();
    await db.delete(tableName(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> commonInsert(Base base) async {
    Database db = await getDataBase();
    await db.insert(tableName(), base.toJson());
  }

  Future<void> commonUpdate(Base base) async {
    Database db = await getDataBase();
    await db.update(tableName(), base.toJson(), where: "id = ?", whereArgs: [base.id]);
  }

  Future<void> commonBatchInsert(List<Base> list) async {
    Database db = await getDataBase();
    var batch = db.batch();
    for (var element in list) {
      batch.insert(tableName(), element.toJson());
    }
    batch.commit();
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlManager {
  static const _version = 1;
  static const _dataBaseName = "book";
  static late Database _database;


  static init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dataBaseName);
    _database = await openDatabase(path, version: _version, onCreate: (Database db, int version) async{});
  }

  static Future<Database> getCurrentDatabase() async {
    return _database;
  }
  
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery("select * from Sqlite_master where type = 'table' and name = '$tableName'");

    return res.isNotEmpty;
  }

  static close() {
    _database.close();
  }
}
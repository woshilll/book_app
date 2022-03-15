import 'package:book_app/api/http_manager.dart';
import 'package:book_app/db/sql_manager.dart';
import 'package:book_app/util/save_util.dart';
class DependencyInjection {
  static Future<void> init() async {
    await SqlManager.init();
    await SaveUtil.init();
    HttpManager.getInstance();
  }
}

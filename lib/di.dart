import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/db/sql_manager.dart';
class DependencyInjection {
  static Future<void> init() async {
    await SqlManager.init();
    DioManager.getInstance();
  }
}

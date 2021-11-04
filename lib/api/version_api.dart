import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/search/search_history.dart';
import 'package:book_app/model/search/search_result.dart';
import 'package:book_app/model/versionUpdate/version.dart';

class VersionApi {
  /// 获取版本
  static Future<Version> getVersion() async{
    return Version.fromJson(await DioManager.instance.get<dynamic>(url: "/version"));
  }


}

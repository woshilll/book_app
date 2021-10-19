import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/book/book.dart';

class ChapterApi {
  static Future<String> parseContent(url) async{
    return await DioManager.instance.get<dynamic>(url: "/parse/book/content", params: {"url": url}, showLoading: false);
  }
}

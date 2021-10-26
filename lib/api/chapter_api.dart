import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';

class ChapterApi {
  static Future<String> parseContent(url, showDialog) async{
    return await DioManager.instance.get<dynamic>(url: "/parse/book/content", params: {"url": url}, showLoading: showDialog);
  }

  static Future<List<Chapter>> parseChapters(url) async{
    dynamic list = await DioManager.instance.get<dynamic>(url: "/parse/book/chapters", params: {"url": url});
    List<Chapter> res = [];
    for (var data in list) {
      res.add(Chapter.fromJson(data));
    }
    return res;
  }
}

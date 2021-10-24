import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/search/search_history.dart';
import 'package:book_app/model/search/search_result.dart';

class BookApi {
  /// 解析小说章节接口
  static Future<Book> parseBook(url) async{
    return Book.fromJson(await DioManager.instance.get<dynamic>(url: "/parse/book", params: {"url": url}));
  }

  /// 获取站点列表
  static Future<List<SearchHistory>> getSites() async {
    var data = await DioManager.instance.get<dynamic>(url: "/parse/book/sites");
    List<SearchHistory> res = [];
    for (var item in data) {
      res.add(SearchHistory.fromJson(item));
    }
    return res;
  }

  /// 获取搜索结果
  static Future<List<SearchResult>> getSearchResults(search, site) async {
    var data = await DioManager.instance.get<dynamic>(url: "/parse/book/search", params: {"search": search, "site": site});
    List<SearchResult> res = [];
    for (var item in data) {
      res.add(SearchResult.fromJson(item));
    }
    return res;
  }
}

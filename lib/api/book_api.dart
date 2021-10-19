import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/book/book.dart';

class BookApi {
  static Future<Book> parseBook(url) async{
    return Book.fromJson(await DioManager.instance.get<dynamic>(url: "/parse/book", params: {"url": url}));
  }
}

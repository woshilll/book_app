import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/model/book/book.dart';

class BookApi {
  static Future<Book> parseBook(url) async{
    return await DioManager.instance.get<Book>(url: "/parse/book", params: {"url": url});
  }
}
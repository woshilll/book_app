import 'package:book_app/api/book_api.dart';
import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/result/result.dart';
import 'package:book_app/route/routes.dart';
import 'package:get/get.dart';

class BookHomeController extends GetxController {
  static final BookDbProvider _bookDbProvider = BookDbProvider();
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  List<Book> books = [];
  @override
  void onInit() async{
    super.onInit();
    await getBookList();
  }

  getBookList() async{
    books = await _bookDbProvider.getBooks();
    update(['bookList']);
    Log.i(books);
  }
  insertBook() async {
    await _bookDbProvider.commonInsert(Book(name: '伏天氏', author: '净无痕', indexImg: 'https://www.biqooge.com/files/article/image/0/1/1s.jpg', url: 'https://www.biqooge.com/0_1/',));
    await getBookList();
  }
  deleteBook(index) async {
    Book book = books[index];
    // 数据库删除
    await _bookDbProvider.commonDelete(book.id);
    // 删除对应的章节信息
    await _chapterDbProvider.deleteByBookId(book.id);
    Log.i("删除 --> $book");
    books.removeWhere((element) => element.id == book.id);
    update(['bookList']);
  }

  getBookInfo(index) async{
    Book selected = books[index];
    dynamic count = await _chapterDbProvider.getChapterCount(selected.id);
    if (count <= 0) {
      // 没有内容
      // 发起请求获取
      List<Chapter> chapters = await ChapterApi.parseChapters(selected.url);
      // 添加章节
      if (chapters.isNotEmpty) {
        for (var element in chapters) {
          element.bookId = selected.id;
        }
        _chapterDbProvider.commonBatchInsert(chapters);
      }
      selected.chapters = [];
    }
    Get.toNamed(Routes.read, arguments: {"book": selected})!.then((value) async{
      Log.i(value);
      // 重新更新页面数据
      Book? book = await _bookDbProvider.getBookById(selected.id);
      if (book != null) {
        books[index] = book;
        update(['bookList']);
      }
    });
  }
}

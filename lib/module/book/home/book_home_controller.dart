import 'dart:io';

import 'package:book_app/api/book_api.dart';
import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/result/result.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/font_util.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
      if (selected.type != 1) {
        EasyLoading.showToast("本地小说无章节,请删除");
        return;
      }
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

      // 重新更新页面数据
      Book? book = await _bookDbProvider.getBookById(selected.id);
      if (book != null) {
        books[index] = book;
        update(['bookList']);
      }
      // 设置亮度
      await DeviceDisplayBrightness.setBrightness(value["brightness"]);
    });
  }

  void toSearch() {
    Get.toNamed(Routes.search)!.then((value) {
      getBookList();
    });
  }

  manageChoose(String value) async{
    switch(value) {
      case "1":
        await _selectTextFile();
        break;
    }
  }

  _selectTextFile() async{
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ["txt"]
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        if (file.size < 10 * 1024) {
          throw "文件过小";
        }
        String fileName = file.name;
        String? filePath = file.path;
        File bookFile = File(filePath!);
        List<String> lines = await bookFile.readAsLines();
        List<Chapter> chapters = [];
        String content = "";
        Chapter chapter = Chapter();
        RegExp chapterMatch = RegExp(r"^第.*章|^\d+$");
        for (var line in lines) {
          if (chapterMatch.hasMatch(line)) {
            if (chapter.name == null) {
              chapter.name = line;
              content = "";
            } else {
              chapter.content = FontUtil.formatContent(content);
              chapters.add(chapter);
              chapter = Chapter(name: line);
              content = "";
            }
          } else {
            content = content + line + "\n";
          }
        }
        chapter.content = FontUtil.formatContent(content);
        chapters.add(chapter);
        Book book = Book(type: 2);
        book.name = fileName;
        book.url = "";
        int bookId = await _bookDbProvider.commonInsert(book);
        for (Chapter item in chapters) {
          item.bookId = bookId;
          item.url = "";
        }
        await _chapterDbProvider.commonBatchInsert(chapters);
        EasyLoading.showToast("添加成功");
        getBookList();
      }
    } catch(err) {
      EasyLoading.showToast("解析失败");
    }
  }
}

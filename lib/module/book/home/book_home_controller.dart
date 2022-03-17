import 'dart:io';

import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/parse_book.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:woshilll_flutter_plugin/woshilll_flutter_plugin.dart';

class BookHomeController extends GetxController with WidgetsBindingObserver{
  static final BookDbProvider _bookDbProvider = BookDbProvider();
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  List<Book> books = [];
  List<Book> localBooks = [];

  @override
  void onReady() async{
    super.onReady();
    WidgetsBinding.instance!.addObserver(this);
    await getBookList();
  }

  getBookList() async{
    localBooks.clear();
    books = await _bookDbProvider.getBooks();
    for (var book in books) {
      if (book.type == 2) {
        localBooks.add(book);
      }
    }
    books.removeWhere((element) => element.type == 2);
    update(['bookList']);
  }
  deleteBook(Book book) async {
    // 数据库删除
    await _bookDbProvider.commonDelete(book.id);
    // 删除对应的章节信息
    await _chapterDbProvider.deleteByBookId(book.id);
    Log.i("删除 --> $book");
    books.removeWhere((element) => element.id == book.id);
    localBooks.removeWhere((element) => element.id == book.id);
    update(['bookList']);
  }

  getBookInfo(Book selected) async{
    dynamic count = await _chapterDbProvider.getChapterCount(selected.id);
    if (count <= 0) {
      // 没有内容
      // 发起请求获取
      if (selected.type != 1) {
        EasyLoading.showToast("本地小说无章节,请删除");
        return;
      }
    }
    selected.chapters = [];
    await Get.toNamed(Routes.read, arguments: {"book": selected})!;
    await getBookList();
    await WoshilllFlutterPlugin.setBrightnessDefault();
  }

  void toSearch() async{
    Get.toNamed(Routes.search);
  }

  manageChoose(String value) async{
    switch(value) {
      case "1":
        _selectTextFile();
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
        book.url = filePath;
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        _appActive();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// app前台状态
  _appActive() async{
    _pasteDo();
  }

  _pasteDo() async{
    ClipboardData? _pasteData = await Clipboard.getData(Clipboard.kTextPlain);
    if (_pasteData != null) {
      String? _pasteText = _pasteData.text;
      if (_pasteText != null && _pasteText.isNotEmpty) {
        var _pastes = _pasteText.split("*#*");
        if (_pastes.length != 3) {
          return;
        }
        if (!_pastes.first.startsWith("woshilll")) {
          return;
        }
        if (_pastes[1].isEmpty) {
          return;
        }
        if (!_pastes.last.isURL) {
          return;
        }
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.dialog(
              AlertDialog(
                title: const Text("小说解析"),
                titlePadding: const EdgeInsets.all(10),
                titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                content: Text.rich(
                  TextSpan(
                      text: "是否解析分享的小说 ",
                      children: [
                        TextSpan(
                            text: _pastes[1],
                            style: const TextStyle(color: Colors.lightBlue)
                        ),
                      ]
                  ),
                ),
                contentPadding: const EdgeInsets.all(10),
                //中间显示内容的文本样式
                contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                actions: [
                  ElevatedButton(
                    child: const Text("取消"),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  ElevatedButton(
                    child: const Text("确定"),
                    onPressed: () async{
                      Get.back();
                      await parseBook(_pastes[1], _pastes.last, isShare: true);
                    },
                  )
                ],
              ),
              transitionDuration: const Duration(milliseconds: 200)
          ).then((value) {
            Clipboard.setData(const ClipboardData(text: ""));
          });
        });
      }
    }
  }
}

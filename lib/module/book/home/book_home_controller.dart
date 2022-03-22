import 'dart:io';

import 'package:book_app/app_controller.dart';
import 'package:book_app/di.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/book_with_chapters.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/channel_utils.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/parse_book.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:woshilll_flutter_plugin/woshilll_flutter_plugin.dart';

class BookHomeController extends GetxController with WidgetsBindingObserver{
  static final BookDbProvider _bookDbProvider = BookDbProvider();
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  List<Book> books = [];
  List<Book> localBooks = [];
  final List<BookWithChapters> _bookDownloads = [];
  final RegExp chapterMatch = RegExp(r"^第.*章|^\d+$");
  @override
  void onInit() {
    super.onInit();
    _listen();
  }

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
      if (book.type != 1) {
        localBooks.add(book);
      }
    }
    books.removeWhere((element) => element.type != 1);
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
      var permission = Permission.storage;

      if (!await permission.status.isGranted) {
        var status = await permission.request();
        if (!status.isGranted) {
          return;
        }
      }
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
        parseBookText(lines, fileName, filePath: filePath).then((value) => {
          getBookList()
        });
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

  downloadBook(int bookId, int chapterId) async {
    int index = _bookDownloads.indexWhere((element) => element.book.id == bookId);
    if (index >= 0) {
      EasyLoading.showToast("已在下载队列中");
      return;
    }
    Book? book = await _bookDbProvider.getBookById(bookId);
    List<Chapter> chapters = await _chapterDbProvider.getChapters(chapterId, bookId);
    if (book == null) {
      EasyLoading.showToast("小说不存在");
      return;
    }
    if (chapters.isEmpty) {
      EasyLoading.showToast("无章节可缓存");
      return;
    }
    BookWithChapters bookWithChapters = BookWithChapters(book, chapters);
    _bookDownloads.add(bookWithChapters);
    _downloadBook(bookWithChapters);
  }

  _downloadBook(BookWithChapters bookWithChapters) async{
    for (var chapter in bookWithChapters.chapters) {
      if (bookWithChapters.interruptDownload) {
        /// 中断下载
        bookWithChapters.dispose();
        _bookDownloads.removeWhere((element) => element.book.id == bookWithChapters.book.id);
        break;
      }
      var _chapter = await _chapterDbProvider.getChapterById(chapter.id);
      if (_chapter != null && _chapter.content != null &&_chapter.content!.isNotEmpty) {
        bookWithChapters.downloadChaptersAdd(chapter);
        continue;
      }
      String content = await HtmlParseUtil.parseContent(chapter.url!);
      if (content.isEmpty) {
        // 下载失败
        continue;
      }
      Log.i("小说 -${bookWithChapters.book.id}- 章节 -${chapter.id}- 下载完成");
      _chapterDbProvider.updateContent(chapter.id, content);
      bookWithChapters.downloadChaptersAdd(chapter);
      await Future.delayed(const Duration(milliseconds: 1000), (){});
    }
    bookWithChapters.downloadComplete(true);
  }

  BookWithChapters? getBookWithChapters(int bookId) {
    var index = _bookDownloads.indexWhere((element) => element.book.id == bookId);
    if (index == -1) {
      return null;
    }
    return _bookDownloads[index];
  }

  Future parseBookText(List<String> lines, String fileName, {String? filePath}) async{

    List<Chapter> chapters = [];
    String content = "";
    Chapter chapter = Chapter();
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
    Book book = Book(type: filePath == null ? 3 : 2);
    book.name = fileName;
    book.url = filePath ?? "";
    int bookId = await _bookDbProvider.commonInsert(book);
    for (Chapter item in chapters) {
      item.bookId = bookId;
      item.url = "";
    }
    await _chapterDbProvider.commonBatchInsert(chapters);
    EasyLoading.showToast("添加成功");
  }

  _listen() {
    ChannelUtils.methodChannel.setMethodCallHandler((call) async{
      switch (call.method) {
        case 'bookPath':
          parseBookWithShare(call);
      }
    });
  }

  parseBookWithShare(MethodCall call) {
    Future.delayed(const Duration(milliseconds: 500), () async{
      var path = call.arguments;
      if (path != null) {
        String? name = path["name"];
        String? content = path["content"];
        if (name != null && content != null) {
          parseBookByShare(name, content);
        }
      }
    });
  }
}

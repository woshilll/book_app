import 'dart:io';
import 'dart:isolate';

import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/book_with_chapters.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/channel_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/dialog_build.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/parse_book.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  static final RegExp chapterMatch = RegExp(r"^第.*章|^\d+$");
  late final ReceivePort mainIsolateReceivePort;
  bool parseNow = false;
  double parseProcess = 0;
  double defaultBrightness = 0;
  double onBrightness = -1;
  bool _pasting = false;
  @override
  void onInit() {
    super.onInit();
    mainIsolateReceivePort = ReceivePort();
    _listen();
  }

  @override
  void onReady() async{
    super.onReady();
    WidgetsBinding.instance!.addObserver(this);
    defaultBrightness = await WoshilllFlutterPlugin.getBrightness();
    await getBookList();

    _showPrivate();
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
        Toast.toast(toast: "本地小说无章节,请删除");
        return;
      }
    }
    selected.chapters = [];
    await Get.toNamed(Routes.read, arguments: {"book": selected})!;
    await getBookList();
    _iosBrightnessChange(true);
    onBrightness = -1;
  }

  manageChoose(String value) async{
    switch(value) {
      case "1":
        _selectTextFile();
        break;
      case "2":
        LimitUtil.throttle(() {
          _pasting = true;
          _pasteDo();
          _pasting = false;
        }, durationTime: 3000, throttleId: "paste");
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
        parseBookText(lines, fileName, filePath: filePath);
      }
    } catch(err) {
      Toast.toast(toast: "解析失败");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    switch(state) {
      case AppLifecycleState.inactive:
        _iosBrightnessChange(true);
        break;
      case AppLifecycleState.resumed:
        LimitUtil.throttle(() {
          _appActive();
        }, durationTime: 3000, throttleId: "paste");
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// app前台状态
  _appActive() async{
    _iosBrightnessChange(false);
    _pasting = true;
    await _pasteDo();
    _pasting = false;
  }

  _pasteDo() async{
    if (EasyLoading.isShow || Get.isDialogOpen!) {
      return;
    }
    ClipboardData? _pasteData = await Clipboard.getData(Clipboard.kTextPlain);
    if (_pasteData != null) {
      String? _pasteText = _pasteData.text;
      if (_pasteText != null && _pasteText.isNotEmpty) {
        _pasteText = _pasteText.trim();
        if (_pasteText.isURL) {
          _parse(_pasteText);
          return;
        }
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
        _parse(_pastes.last, bookName: _pastes[1]);
      } else {
        Toast.toast(toast: "链接不正确");
      }
    } else {
      Toast.toast(toast: "链接不正确");
    }
  }

  _parse(String url, {String? bookName}) async{
    await Future.delayed(const Duration(milliseconds: 500));
    Get.dialog(
        DialogBuild(
          "小说解析",
          Text.rich(
            TextSpan(
                text: "是否解析${bookName == null ? '复制的链接' : '分享的小说'} ",
                children: [
                  TextSpan(
                      text: bookName ?? url,
                      style: const TextStyle(color: Colors.lightBlue)
                  ),
                ],
                style: TextStyle(color: textColor())
            ),
          ),
          confirmFunction: () async{
            Get.back();
            await parseBook(bookName, url);
            _pasting = false;
          },
          cancelFunction: () {
            Get.back();
            _pasting = false;
          },
        ),
        transitionDuration: const Duration(milliseconds: 200)
    ).then((value) {
      Clipboard.setData(const ClipboardData(text: ""));
      _pasting = false;
    });
  }

  downloadBook(int bookId, int chapterId) async {
    int index = _bookDownloads.indexWhere((element) => element.book.id == bookId);
    if (index >= 0) {
      Toast.toast(toast: "已在下载队列中");
      return;
    }
    Book? book = await _bookDbProvider.getBookById(bookId);
    List<Chapter> chapters = await _chapterDbProvider.getChapters(chapterId, bookId);
    if (book == null) {
      Toast.toast(toast: "小说不存在");
      return;
    }
    if (chapters.isEmpty) {
      Toast.toast(toast: "无章节可缓存");
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
      Chapter? nextChapter = await _chapterDbProvider.getNextChapter(chapter.id, bookWithChapters.book.id);
      String content = await HtmlParseUtil.parseContent(chapter.name!, chapter.url!, nextChapter?.url);
      if (content.isEmpty) {
        // 下载失败
        continue;
      }
      Log.i("小说 -${bookWithChapters.book.id}- 章节 -${chapter.id}- 下载完成");
      content = FontUtil.formatContent(content);
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
    if (parseNow) {
      Toast.toast(toast: "正在解析书籍，请稍后");
      return;
    }
    parseNow = true;
    update(["parseProcess"]);
    compute(_parseBookText, {"lines": lines, "fileName": fileName, "filePath": filePath, "sendPort": mainIsolateReceivePort.sendPort}).then((value) async{
      if (value != null) {
        var book = value[0];
        var chapters = value[1];
        var bookId = await _bookDbProvider.commonInsert(book);
        for (Chapter item in chapters) {
          item.url = "";
          item.bookId = bookId;
        }
        await _chapterDbProvider.commonBatchInsert(chapters);
        Toast.toast(toast: "添加成功");
        getBookList();
      } else {
        Toast.toast(toast: "解析失败");
      }
      parseNow = false;
      parseProcess = 0;
      update(["parseProcess"]);
    });
  }

  static _parseBookText(data) async{
    try {
      List<String> lines = data["lines"];
      String fileName = data["fileName"];
      String? filePath = data["filePath"];
      SendPort sendPort = data["sendPort"];
      List<Chapter> chapters = [];
      String content = "";
      Chapter chapter = Chapter();
      for (int i = 0; i < lines.length; i++) {
        if (i % 100 == 0) {
          sendPort.send(i * 100 / lines.length);
        }
        var line = lines[i].trim();
        if (line == "") {
          continue;
        }
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
      return [book, chapters];
    } catch(e) {
      Log.i(e);
      return null;
    }
  }

  _listen() {
    ChannelUtils.methodChannel.setMethodCallHandler((call) async{
      switch (call.method) {
        case 'bookPath':
          parseBookWithShare(call);
      }
    });
    mainIsolateReceivePort.listen((message) {
      if (message is double) {
        parseProcess = message;
        update(["parseProcess"]);
      }
    });
  }

  parseBookWithShare(MethodCall call) {
    Future.delayed(const Duration(milliseconds: 500), () async{
      var path = call.arguments;
      if (path != null) {
        String? name;
        String? content;
        if (Platform.isIOS) {
          // path是地址
          String _path = (path["name"] as String);
          name = Uri.decodeComponent(_path.substring(_path.lastIndexOf("/") + 1));
          name = name.substring(0, name.lastIndexOf("."));
        } else {
          name = path["name"];
        }
        content = path["content"];
        if (name != null && content != null) {
          parseBookByShare(name, content);
        }
      }
    });
  }

  updateBookName(int id, String nweName) async{
    await _bookDbProvider.updateName(id, nweName);
    Toast.toast(toast: "更新成功");
    getBookList();
  }

  void _iosBrightnessChange(bool toDefault) async{
    if (!Platform.isIOS) {
      await WoshilllFlutterPlugin.setBrightnessDefault();
      return;
    }
    if (toDefault) {
      WoshilllFlutterPlugin.setBrightness(defaultBrightness);
    } else {
      if (onBrightness >= 0 && Get.currentRoute != Routes.bookHome) {
        WoshilllFlutterPlugin.setBrightness(onBrightness);
      }
    }
  }

  void _showPrivate() {
    var privateRead = SaveUtil.getTrue(Constant.privateRead);
    if (privateRead == null || !privateRead) {
      Get.dialog(DialogBuild(
        "隐私协议",
        Text.rich(TextSpan(
            text: "为了更好的体验完整功能，请您仔细阅读并同意",
            children: [
              TextSpan(
                  text: "隐私协议",
                style: const TextStyle(color: Colors.lightBlue),
                recognizer: TapGestureRecognizer()..onTap = () async{
                  String url = "http://book.private.woshilll.top/book_private.html";
                  launchUrl(Uri.parse(url));
                }
              )
            ],
          style: TextStyle(color: textColor())
        )),
        cancelText: "取消并退出",
        confirmText: "同意协议",
        confirmFunction: () {
          SaveUtil.setTrue(Constant.privateRead);
          Get.back();
        },
        cancelFunction: () {
          exit(0);
        },
      ),
        barrierDismissible: false
      );
    }
  }
}

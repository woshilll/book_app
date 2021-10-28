import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/module/book/readSetting/component/read_setting_config.dart';
import 'package:book_app/module/home/home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/audio/text_player_handler.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/save_util.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'component/content_page.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadController extends GetxController {
  /// 数据库
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  static final BookDbProvider _bookDbProvider = BookDbProvider();
  /// 主页传来的书籍信息
  late Book book;
  /// 所有章节
  List<Chapter> chapters = [];
  /// 上下文
  BuildContext context = globalContext;
  /// 阅读的页
  List<ContentPage> pages = [];
  /// 当前阅读页索引
  int pageIndex = 0;
  /// 页面监听
  PageController contentPageController = PageController();
  /// 画笔
  final TextPainter _painter = TextPainter(textDirection: TextDirection.ltr);
  /// 是否正在加载
  bool loading = false;
  /// 屏幕宽度
  double screenWidth = 0;
  /// 阅读进度
  int readChapterIndex = 0;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  /// 目录控制器
  ScrollController menuController = ScrollController();
  /// 目录展开标识
  bool drawerFlag = false;
  /// 底部类型 1-正常 2-亮度 3-设置
  String bottomType = "1";
  /// 屏幕亮度
  double brightness = 0;
  /// 最初屏幕亮度变量
  double brightnessTemp = 0;
  /// 背景色
  List<String> backgroundColors = ReadSettingConfig.getCommonBackgroundColors();
  /// 默认背景色
  ReadSettingConfig readSettingConfig = ReadSettingConfig.defaultConfig();
  /// 字体样式
  late TextStyle contentStyle;
  late AudioHandler audioHandler;
  @override
  void onInit() async{
    super.onInit();
    var map = Get.arguments;
    book = map["book"];
    await initData();
    initAudio();
  }
  initData() async{
    /// 背景色
    String? config = SaveUtil.getString(Constant.readSettingConfig);
    if (config != null) {
      readSettingConfig = ReadSettingConfig.fromJson(json.decode(config));
    }
    contentStyle = TextStyle(color: hexToColor(readSettingConfig.fontColor), fontSize: readSettingConfig.fontSize);
    /// 加载章节
    chapters = await _chapterDbProvider.getChapters(null, book.id);
    Chapter cur = chapters[0];
    int index = 0;
    if (book.curChapter != null) {
      index = chapters.indexWhere((element) => element.id == book.curChapter);
      if (index >= 0) {
        cur = chapters[index];
      }
    }
    cur.content = await getContent(cur.id, cur.url, true);
    await initPage(cur);

    /// 亮度
    double sysBrightness = await DeviceDisplayBrightness.getBrightness();
    if (sysBrightness > 1) {
      brightness = sysBrightness / 10;
    } else {
      brightness = sysBrightness;
    }
    brightnessTemp = brightness;
  }
  /// 将文本转文字页面
  initPage(Chapter chapter) async {
    calWordHeightAndWidth();
    String content = alphanumericToFullLength(chapter.content);
    _painter.text = TextSpan(text: content, style: contentStyle);
    // 一页最大行数 context获取的是主页的context， 带appBar所以高度会减少56
    double screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + 26;
    // 第一页最大行数
    int maxLines = screenHeight ~/ wordHeight;
    _painter.maxLines = maxLines;
    // 统计第一页字符偏移量
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    int offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    // 得到第一页偏移量
    int preOffset = 0;
    int i = 1;
    // 先加载几页，然后再一点点加载
    for (int j = 0; j < 4; j++) {
      if (offset >= content.length) {
        String subContent = content.substring(preOffset, offset);
        pages.add(
            ContentPage(subContent, contentStyle, i, chapter.id, chapter.name, wordWith));
        i++;
        update(["content"]);
        return;
      }
      String subContent = content.substring(preOffset, offset);
      pages.add(
          ContentPage(subContent, contentStyle, i, chapter.id, chapter.name, wordWith));
      i++;
      preOffset = offset;
      _painter.maxLines = maxLines * i;
      _painter.layout(maxWidth: MediaQuery.of(context).size.width);
      paintWidth = _painter.width;
      paintHeight = _painter.height;
      offset =
          _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    }
    Timer(const Duration(milliseconds: 300), () {
      pageRecursion(i, maxLines, preOffset, offset, content, chapter);
      update(["content"]);
      loading = false;
    });
  }

  Future pageRecursion(int index, int maxLines, int preOffset, int offset,
      String content, Chapter chapter) async {
    String subContent;
    if (offset >= content.length) {
      subContent = content.substring(preOffset);
      pages.add(
          ContentPage(subContent, contentStyle, index, chapter.id, chapter.name, wordWith));
      index++;
      return;
    }
    subContent = content.substring(preOffset, offset);
    pages.add(ContentPage(subContent,contentStyle, index, chapter.id, chapter.name, wordWith));
    index++;
    preOffset = offset;
    _painter.maxLines = maxLines * index;
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    await pageRecursion(index, maxLines, preOffset, offset, content, chapter);
  }
  /// 获取章节内容
  Future<String> getContent(id, url, showDialog) async{
    // 查找内容
    Chapter? temp = await _chapterDbProvider.getChapterById(id);
    var content = temp?.content;
    if (content == null) {
      content = await ChapterApi.parseContent(url, showDialog);
      await _chapterDbProvider.updateContent(id, content.trim());
    }
    // 赋值
    return content;
  }

  /// 字符转全角
  String alphanumericToFullLength(str) {
    var temp = str.codeUnits;
    final regex = RegExp(r'^[a-zA-Z0-9!,.@#$%^&*()@￥?]+$');
    final string = temp.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune + 65248) : char;
    });
    return string.join();
  }

  /// 字符转半角
  String alphanumericToHalfLength(String str) {
    var runes = str.codeUnits;
    final regex = RegExp(r'^[Ａ-Ｚａ-ｚ０-９]+$');
    final string = runes.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune - 65248) : char;
    });
    return string.join();
  }

  double wordHeight = 0;
  double wordWith = 0;
  int maxLines = 0;

  /// 计算词宽和词高
  calWordHeightAndWidth() {
    _painter.text = TextSpan(text: "哈", style: contentStyle);
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    var cal = _painter.computeLineMetrics()[0];
    wordHeight = cal.height;
    wordWith = cal.width;
    maxLines = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top) ~/
        wordHeight;
  }
  /// 计算当前章节一共多少页
  calThisChapterTotalPage(index) {
    var chapterId = pages[index].chapterId;
    return pages.lastIndexWhere((element) => element.chapterId == chapterId) - pages.indexWhere((element) =>  element.chapterId == chapterId) + 1;
  }

  /// 页面变化监听
  Future pageChangeListen(int index) async{
    if (loading) {
      return;
    }
    loading = true;
    var chapterId = pages[pages.length - 1].chapterId;
    index = chapters.indexWhere((element) => element.id == chapterId);
    if (index == chapters.length - 1) {
      // 没有了
      return;
    }
    Chapter chapter = chapters[index + 1];
    chapter.content = await getContent(chapter.id, chapter.url, false);
    initPage(chapter);
  }

  /// 页面返回监听
  pop() async{
    // 更新当前的章节和页数
    var chapterId = pages[pageIndex].chapterId;
    await _bookDbProvider.updateCurChapter(book.id, chapterId);
    Get.back(result: {"brightness": brightnessTemp});
  }

  /// 跳转章节
  jumpChapter(index, {bool pop = true}) async{
    Chapter chapter = chapters[index];
    index = pages.indexWhere((element) => chapter.id == element.chapterId);
    if (index >= 0) {
      // 已存在
      contentPageController.jumpToPage(index);
    } else {
      chapter.content = await getContent(chapter.id, chapter.url, true);
      pages.clear();
      await initPage(chapter);
      contentPageController.jumpToPage(0);
    }
    if (pop) {
      Navigator.of(context).pop();
    }
  }

  /// 下一页
  nextPage() async {
    int index = pageIndex;
    if (index < pages.length - 2) {
      // 有下一页
      contentPageController.animateToPage(index + 1, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
    } else {
      // 到底了， 加载 获取当前章节
      var chapterId = pages[index].chapterId;
      var chapterIndex = chapters.indexWhere((element) => element.id == chapterId);
      if (chapterIndex >= 0 && chapterIndex != chapters.length - 1) {
        // 找到下一章
        Chapter next = chapters[chapterIndex + 1];
        next.content = await getContent(next.id, next.url, false);
        await initPage(next);
        // 跳转
        contentPageController.animateToPage(index + 1, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
      } else {
        EasyLoading.showToast("没有更多了");
      }
    }
  }

  prePage() async {
    int index = pageIndex;
    if (index > 0) {
      // 有上一页
      contentPageController.animateToPage(index - 1, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
    } else {
      // 无上一页
      var chapterId = pages[index].chapterId;
      var chapterIndex = chapters.indexWhere((element) => element.id == chapterId);
      if (chapterIndex > 0) {
        // 加载上一页
        EasyLoading.show(maskType: EasyLoadingMaskType.clear);
        Chapter pre = chapters[chapterIndex - 1];
        pre.content = await getContent(pre.id, pre.url, false);
        List<ContentPage> returnPages = await initPageWithReturn(pre);
        pages.insertAll(0, returnPages);
        pageIndex = returnPages.length - 1;
        contentPageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
        EasyLoading.dismiss();
      } else {
        EasyLoading.showToast("没有更多了");
      }
    }
  }

  Future<List<ContentPage>> initPageWithReturn(Chapter chapter) async {
    List<ContentPage> pages = [];
    calWordHeightAndWidth();
    String content = alphanumericToFullLength(chapter.content);
    _painter.text = TextSpan(text: content, style: contentStyle);
    // 一页最大行数 context获取的是主页的context， 带appBar所以高度会减少56
    double screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top + 26;
    // 第一页最大行数
    int maxLines = screenHeight ~/ wordHeight;
    _painter.maxLines = maxLines;
    // 统计第一页字符偏移量
    _painter.layout(maxWidth: MediaQuery.of(context).size.width);
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    int offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    // 得到第一页偏移量
    int preOffset = 0;
    int i = 1;
    while (preOffset < content.length) {
      if (offset >= content.length) {
        String subContent = content.substring(preOffset);
        pages.add(
            ContentPage(subContent, contentStyle, i, chapter.id, chapter.name, wordWith));
        break;
      }
      String subContent = content.substring(preOffset, offset);
      pages.add(
          ContentPage(subContent, contentStyle, i, chapter.id, chapter.name, wordWith));
      i++;
      preOffset = offset;
      _painter.maxLines = maxLines * i;
      _painter.layout(maxWidth: MediaQuery.of(context).size.width);
      paintWidth = _painter.width;
      paintHeight = _painter.height;
      offset =
          _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    }
    return pages;
  }

  Widget keyboardListen() {
    return KeyboardListener(
      focusNode: FocusNode(),
      child: Container(),
      onKeyEvent: _keyEvent,
    );
  }

  _keyEvent(KeyEvent event) async {
    Log.i(event);
    // if (event.physicalKey == PhysicalKeyboardKey.audioVolumeDown) {
    //   // 音量-
    //   await nextPage();
    // } else if (event.physicalKey == PhysicalKeyboardKey.audioVolumeUp) {
    //   // 音量＋
    //   await prePage();
    // }
  }

  // 计算进度
  void calReadProgress() {
    var chapterId = pages[pageIndex].chapterId;
    readChapterIndex =  chapters.indexWhere((element) => chapterId == element.id);
  }

  void chapterChange(double value) {
    readChapterIndex = value.toInt();
    update(["chapterChange"]);
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
    drawerFlag = true;
    Timer(const Duration(milliseconds: 300), () => menuController.jumpTo(readChapterIndex * 41));
  }

  /// 上一章
  preChapter() async{
    if (readChapterIndex <= 0) {
      EasyLoading.showToast("没有更多了");
      return;
    }
    Chapter pre = chapters[readChapterIndex - 1];
    int index = pages.indexWhere((element) => element.chapterId == pre.id);
    if (index >= 0) {
      // 已缓存
      contentPageController.jumpToPage(index);
    } else {
      await jumpChapter(readChapterIndex - 1, pop: false);
    }
    readChapterIndex -= 1;
  }

  /// 下一章
  nextChapter() async{
    if (readChapterIndex >= chapters.length - 1) {
      EasyLoading.showToast("没有更多了");
      return;
    }
    Chapter next = chapters[readChapterIndex + 1];
    int index = pages.indexWhere((element) => element.chapterId == next.id);
    if (index >= 0) {
      // 已缓存
      contentPageController.jumpToPage(index);
    } else {
      await jumpChapter(readChapterIndex + 1, pop: false);
    }
    readChapterIndex += 1;
  }

  void changeBottomType(String type) {
    if (bottomType == type) {
      bottomType = "1";
    } else {
      bottomType = type;
    }
    update(["bottomType"]);
  }

  setBrightness(double value) async{
    brightness = value;
    await DeviceDisplayBrightness.setBrightness(value);
    update(["brightness"]);
  }

  void setBackGroundColor(String backgroundColor) {
    if (readSettingConfig.backgroundColor != backgroundColor) {
      readSettingConfig.backgroundColor = backgroundColor;
      update(["backgroundColor", "bottomType"]);
    }
  }

  toSetting() async{
    ReadSettingConfig temp = ReadSettingConfig(readSettingConfig.backgroundColor, readSettingConfig.fontSize, readSettingConfig.fontColor);
    var value = await Get.toNamed(Routes.readSetting, arguments: {"config": temp});
    if (value != null && value["config"] != null) {
      ReadSettingConfig config = value["config"];
      if (config.fontSize != readSettingConfig.fontSize || config.fontColor != readSettingConfig.fontColor) {
        // 需要重新加载
        await EasyLoading.show();
        contentStyle = TextStyle(color: hexToColor(config.fontColor), fontSize: config.fontSize);
        int chapterIndex = chapters.indexWhere((element) => pages[pageIndex].chapterId == element.id);
        pages.clear();
        await jumpChapter(chapterIndex, pop: false);
        await EasyLoading.dismiss();
      }
      readSettingConfig = value["config"];
      update(["backgroundColor", "content"]);
    }
  }

  @override
  void onClose() async{
    super.onClose();
    String data = json.encode(readSettingConfig);
    SaveUtil.setString(Constant.readSettingConfig, data);
    // await audioHandler.stop();
    // await audioHandler.updateQueue([]);
  }

  void initAudio() {
    HomeController homeController = Get.find();
    audioHandler = homeController.audioHandler;
  }

  play() async{
    // Log.i(pageIndex);
    HomeController homeController = Get.find();
    await audioHandler.pause();
    await audioHandler.updateQueue([]);
    // 直接加载一整章的小说
    int lastIndex = pages.lastIndexWhere((element) => element.chapterId == pages[pageIndex].chapterId);
    for (int i = pageIndex; i <= lastIndex; i++) {
      await audioHandler.addQueueItem(MediaItem(
          id: pages[pageIndex].chapterId.toString(),
          album: "content",
          title: pages[pageIndex].chapterName.toString(),
          extras: <String, String>{"content": pages[i].content, "type": "1"}
      ));
    }
    await audioHandler.play();
    await audioHandler.setSpeed(10);
    homeController.audioProcessingState = AudioProcessingState.error;
  }

}

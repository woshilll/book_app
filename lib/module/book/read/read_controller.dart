import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:book_app/app_controller.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/component/drawer.dart';
import 'package:book_app/module/book/readSetting/component/read_setting_config.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/channel_utils.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/notify/counter_notify.dart';
import 'package:book_app/util/save_util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:woshilll_flutter_plugin/woshilll_flutter_plugin.dart';
import 'component/content_page.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadController extends GetxController with SingleGetTickerProviderMixin {
  /// 数据库
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  static final BookDbProvider _bookDbProvider = BookDbProvider();
  /// 主页传来的书籍信息
  Book? book;
  /// 所有章节
  List<Chapter> chapters = [];
  /// 上下文
  BuildContext context = globalContext;
  /// 阅读的页
  List<ContentPage> pages = [];
  /// 当前阅读页索引
  CounterNotify pageIndex = CounterNotify();
  /// 页面监听
  PageController contentPageController = PageController();
  /// 画笔 https://www.jianshu.com/p/f713e5a36da5
  final TextPainter _painter = TextPainter(textDirection: TextDirection.ltr, locale: WidgetsBinding.instance!.window.locale, textScaleFactor: MediaQuery.of(globalContext).textScaleFactor);
  /// 是否正在加载
  bool loading = false;
  /// 阅读进度
  int readChapterIndex = 0;
  /// 目录控制器
  ItemScrollController menuController = ItemScrollController();
  ItemPositionsListener menuPositionsListener = ItemPositionsListener.create();
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
  /// 是否旋转屏幕
  bool rotateScreen = false;
  /// x轴移动距离
  double xMove = 0;
  /// 是否为暗色模式
  bool isDark = Get.isDarkMode;
  /// 自动翻页
  Timer? autoPage;
  /// 是否展示顶部状态栏
  bool showStatusBar = false;
  /// 电池
  final Battery _battery = Battery();
  /// 电池容量
  int batteryLevel = 0;
  /// 电池状态
  BatteryState batteryState = BatteryState.unknown;
  /// 阅读方式
  ReadPageType readPageType = ReadPageType.smooth;
  /// 点击翻页淡入淡出
  bool pointShow = true;
  double screenHeight = 0;
  double screenWidth = 0;
  double screenLeft = 0;
  double screenBottom = 0;
  double screenTop = 0;
  double screenRight = 0;
  double titleHeight = 0;
  AnimationController? coverController;
  final double paddingWidth = 40;
  @override
  void onInit() async{
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.onInit();
    // 覆盖翻页
    coverController = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    batteryLevel = await _battery.batteryLevel;
    var map = Get.arguments;
    book = map["book"];
    _batteryListen();
    await _batteryCap();
    _menuListen();
    _pageIndexChangeListen();
    ChannelUtils.setConfig(Constant.pluginVolumeFlag, true);
    _volumeChangeListen();
  }

  @override
  onReady() async{
    super.onReady();
    initData();
  }

  initData() async{
    /// 初始化宽度
    _initSize();
    /// 亮度 放在前面
    brightness = await WoshilllFlutterPlugin.getBrightness();
    brightnessTemp = brightness;
    /// 背景色
    readSettingConfig = _getReadSettingConfig();
    if (isDark) {
      readSettingConfig = ReadSettingConfig.defaultDarkConfig(readSettingConfig.fontSize, readSettingConfig.fontHeight);
    }
    contentStyle = TextStyle(color: hexToColor(readSettingConfig.fontColor), fontSize: readSettingConfig.fontSize, height: readSettingConfig.fontHeight);
    /// 加载章节
    chapters = await _chapterDbProvider.getChapters(null, book!.id);
    Chapter cur = chapters[0];
    int index = 0;
    if (book!.curChapter != null) {
      index = chapters.indexWhere((element) => element.id == book!.curChapter);
      if (index >= 0) {
        cur = chapters[index];
      }
    }
    initPage(cur, dialog: true, firstInit: true);
  }

  ReadSettingConfig _getReadSettingConfig() {
    String? config = SaveUtil.getString(Constant.readSettingConfig);
    if (config != null) {
      return ReadSettingConfig.fromJson(json.decode(config));
    }
    return ReadSettingConfig.defaultConfig();
  }
  /// 将文本转文字页面
  initPage(Chapter chapter, {bool firstInit = false, bool dialog = false, Function? finishFunc, bool canJumpPage = true}) async {
    if (loading) {
      return;
    }
    loading = true;
    if (dialog) {
      await EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    }
    getContent(chapter, dialog).then((value) {
      initPageWithReturn(chapter).then((list) async{
        if (list.isNotEmpty && pages.isNotEmpty) {
          int exist = pages.indexWhere((element) => element.chapterId == list[0].chapterId);
          if (exist == -1) {
            pages.addAll(list);
          }
        } else {
          pages.addAll(list);
        }
        if (finishFunc != null) {
          finishFunc;
        }
        await EasyLoading.dismiss();
        loading = false;
        if (canJumpPage){
          if (firstInit && book!.curPage != null) {
            _jumpPageIndex(book!.curPage! - 1);
          } else if (pageIndex.count >= pages.length) {
            _jumpPageIndex(pages.length - 1);
          } else {
            _jumpPageIndex(pageIndex.count);
          }
        } else {
          update(["content"]);
        }
      });
    }).catchError((err) {
      EasyLoading.dismiss();
    });


  }


  /// 获取章节内容
  Future<String?> getContent(Chapter chapter, showDialog) async{
    // 查找内容
    Chapter? temp = await _chapterDbProvider.getChapterById(chapter.id);
    var content = temp?.content;
    if ((content == null || content.isEmpty) && book!.type == 1) {
      // content = await ChapterApi.parseContent(url, showDialog);
      content = await HtmlParseUtil.parseContent(chapter.url!);
      // 格式化文本
      if (content != null) {
        content = FontUtil.formatContent(content);
        await _chapterDbProvider.updateContent(chapter.id, content);
      }
    }
    // 赋值
    chapter.content = content;
    return content;
  }



  double wordHeight = 0;
  double wordWith = 0;
  int maxLines = 0;

  /// 计算词宽和词高
  _calWordHeightAndWidth() {
    _painter.text = TextSpan(text: "哈", style: contentStyle);
    _painter.layout(maxWidth: screenWidth);
    var cal = _painter.computeLineMetrics()[0];
    wordHeight = cal.height;
    wordWith = cal.width;
  }

  /// 计算标题高度
  _calTitleHeight() {
    _painter.text = const TextSpan(text: "哈", style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold));
    _painter.layout(maxWidth: screenWidth);
    var cal = _painter.computeLineMetrics()[0];
    titleHeight = cal.height;
  }

  /// 计算当前章节一共多少页
  calThisChapterTotalPage(index) {
    var chapterId = pages[index].chapterId;
    return pages.lastIndexWhere((element) => element.chapterId == chapterId) - pages.indexWhere((element) =>  element.chapterId == chapterId) + 1;
  }

  /// 页面变化监听
  Future pageChangeListen() async{
    var chapterId = pages[pages.length - 1].chapterId;
    int index = chapters.indexWhere((element) => element.id == chapterId);
    if (index == chapters.length - 1) {
      // 没有了
      return;
    }
    Chapter chapter = chapters[index + 1];
    initPage(chapter, canJumpPage: false);
  }

  /// 页面返回监听
  popRead() async{
    ReadController controller = Get.find();
    Get.back(result: {"brightness": brightnessTemp});
    if (controller.rotateScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  /// 跳转章节
  jumpChapter(index, {bool pop = true}) async{
    Chapter chapter = chapters[index];
    index = pages.indexWhere((element) => chapter.id == element.chapterId);
    if (index >= 0) {
      // 已存在
      _jumpPageIndex(index);
    } else {
      pages.clear();
      bool dialog = (chapter.content == null || chapter.content!.isEmpty);
      await initPage(chapter, dialog: dialog);
    }
    if (pop) {
      Navigator.of(context).pop();
    }
  }

  /// 下一页
  nextPage() async {
    if (loading) {
      return;
    }
    int index = pageIndex.count;
    if (index < pages.length - 2) {
      _pageStartStyle();
      // 有下一页
      _jumpPageIndex(index + 1);
    } else {
      // 到底了， 加载 获取当前章节
      var chapterId = pages[index].chapterId;
      var chapterIndex = chapters.indexWhere((element) => element.id == chapterId);
      if (chapterIndex >= 0 && chapterIndex != chapters.length - 1) {
        // 找到下一章
        _pageStartStyle();
        Chapter next = chapters[chapterIndex + 1];
        initPage(next);
        // 跳转
        // _nextPageStyle(index);
      }
    }
  }
  _pageStartStyle() {
    if (readPageType == ReadPageType.point) {
      pointShow = false;
      update(["point"]);
    }
  }

  prePage() async {
    if (loading) {
      return;
    }
    int index = pageIndex.count;
    if (index > 0) {
      // 有上一页
      _pageStartStyle();
      pageIndex.setCount(index - 1);
      _prePageStyle();
    } else {
      // 无上一页
      var chapterId = pages[index].chapterId;
      var chapterIndex = chapters.indexWhere((element) => element.id == chapterId);
      if (chapterIndex > 0) {
        // 加载上一页
        _pageStartStyle();
        EasyLoading.show(maskType: EasyLoadingMaskType.clear);
        Chapter pre = chapters[chapterIndex - 1];
        getContent(pre, false).then((value) async{
          initPageWithReturn(pre).then((returnPages) {
            pages.insertAll(0, returnPages);
            update(["content"]);
            pageIndex.setCount(returnPages.length - 1);
            _prePageStyle();
            EasyLoading.dismiss();
          });
        });

      }
    }
  }

  _prePageStyle() {
    if (readPageType == ReadPageType.smooth) {
      contentPageController.jumpToPage(pageIndex.count);

    } else if (readPageType == ReadPageType.point) {
      pointShow = true;
      update(["point"]);
    }
  }

  Future<List<ContentPage>> initPageWithReturn(Chapter chapter) async {
    // chapter.content = await getContent(chapter.id, chapter.url, false);
    List<ContentPage> list = [];
    _calWordHeightAndWidth();
    _calMaxLines(firstPage: true);
    // String content = FontUtil.alphanumericToFullLength(chapter.content);
    String content = chapter.content??"";
    if (content.isEmpty) {
      list.add(
          ContentPage("", 1, chapter.id, chapter.name, _contentWidth(), noContent: true));
      return list;
    }
    _painter.text = TextSpan(text: content, style: contentStyle);
    _painter.maxLines = maxLines;
    // 统计第一页字符偏移量
    _painter.layout(maxWidth: _contentWidth());
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    int offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    // 得到第一页偏移量
    int i = 1;
    do {
      String subContent = content.substring(0, offset);
      list.add(
          ContentPage(subContent, i, chapter.id, chapter.name, _contentWidth()));
      i++;
      if (i == 2) {
        _calMaxLines();
      }
      content = content.substring(offset);
      if (content.startsWith("\n")) {
        content = content.substring(1);
      }
      _painter.text = TextSpan(text: content, style: contentStyle);
      _painter.maxLines = maxLines;
      _painter.layout(maxWidth: _contentWidth());
      paintWidth = _painter.width;
      paintHeight = _painter.height;
      offset =
          _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    } while (offset < content.characters.length);
    if (offset > 0) {
      list.add(
          ContentPage(content, i, chapter.id, chapter.name, _contentWidth()));
    }
    return list;
  }

  Widget keyboardListen() {
    return KeyboardListener(
      focusNode: FocusNode(),
      child: Container(),
      onKeyEvent: _keyEvent,
    );
  }

  _keyEvent(KeyEvent event) async {
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
    if (pages.isEmpty) {
      return;
    }
    var chapterId = pages[pageIndex.count].chapterId;
    readChapterIndex =  chapters.indexWhere((element) => chapterId == element.id);
  }

  void chapterChange(double value) {
    readChapterIndex = value.toInt();
    update(["chapterChange"]);
  }

  openDrawer() async{
    Timer(const Duration(milliseconds: 400), () {
      drawer(context);
    });
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
    update(["chapterChange"]);
  }

  /// 下一章
  nextChapter() async{
    if (readChapterIndex >= chapters.length - 1) {
      EasyLoading.showToast("没有更多了");
      return;
    }
    await jumpChapter(readChapterIndex + 1, pop: false);
    // Chapter next = chapters[readChapterIndex + 1];
    // int index = pages.indexWhere((element) => element.chapterId == next.id);
    // if (index >= 0) {
    //   // 已缓存
    //   contentPageController.jumpToPage(index);
    // } else {
    //   await jumpChapter(readChapterIndex + 1, pop: false);
    // }
    readChapterIndex += 1;
    update(["chapterChange"]);
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
    WoshilllFlutterPlugin.setBrightness(value);
    update(["brightness"]);
  }

  void setBackGroundColor(String backgroundColor) {
    if (isDark) {
      return;
    }
    if (readSettingConfig.backgroundColor != backgroundColor) {
      readSettingConfig.backgroundColor = backgroundColor;
      update(["backgroundColor", "bottomType"]);
    }
  }

  toSetting() async{
    if (isDark) {
      return;
    }
    ReadSettingConfig temp = ReadSettingConfig(readSettingConfig.backgroundColor, readSettingConfig.fontSize, readSettingConfig.fontColor, readSettingConfig.fontHeight);
    var value = await Get.toNamed(Routes.readSetting, arguments: {"config": temp});
    if (value != null && value["config"] != null) {
      ReadSettingConfig config = value["config"];
      if (config.fontSize != readSettingConfig.fontSize) {
        // 需要重新加载
        await _reload(config);
      }
      double fontHeight = readSettingConfig.fontHeight;
      readSettingConfig = value["config"];
      readSettingConfig.fontHeight = fontHeight;
      update(["backgroundColor", "content"]);
    }
  }

  _reload(ReadSettingConfig config) async{
    await EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    contentStyle = TextStyle(color: hexToColor(config.fontColor), fontSize: config.fontSize, height: config.fontHeight);
    int chapterIndex = chapters.indexWhere((element) => pages[pageIndex.count].chapterId == element.id);
    pageIndex.setCount(pages[pageIndex.count].index - 1);
    pages.clear();
    await jumpChapter(chapterIndex, pop: false);
    await EasyLoading.dismiss();
  }

  @override
  void onClose() async{
    super.onClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (isDark) {
      var config = _getReadSettingConfig();
      readSettingConfig.backgroundColor = config.backgroundColor;
      readSettingConfig.fontColor = config.fontColor;
    }
    String data = json.encode(readSettingConfig);
    SaveUtil.setString(Constant.readSettingConfig, data);
    autoPage?.cancel();
    _batteryTimer?.cancel();
    if (Platform.isAndroid) {
      // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle =
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent, systemNavigationBarDividerColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    ChannelUtils.setConfig(Constant.pluginVolumeFlag, false);
  }


  double _contentWidth() {
  return screenWidth - paddingWidth - screenLeft - screenRight;
  }


  void _calMaxLines({bool firstPage = false}) {
    double extend = 0;
    if (firstPage) {
      extend = titleHeight;
    }
    maxLines = (screenHeight -
        screenTop - screenBottom - extend) ~/
        wordHeight;
  }

  /// 行高减0.1
  fontHeightSub() async{
    if (readSettingConfig.fontHeight > 1) {
      readSettingConfig.fontHeight = readSettingConfig.fontHeight - 0.1;
      await _reload(readSettingConfig);
      update(["content"]);
    }
  }
  /// 行高加0.1
  fontHeightAdd() async{
    if (readSettingConfig.fontHeight < 3) {
      readSettingConfig.fontHeight = readSettingConfig.fontHeight + 0.1;
      await _reload(readSettingConfig);
      update(["content"]);
    }
  }

  /// 屏幕旋转
  rotateScreenChange() async{
    if (!rotateScreen) {
      rotateScreen = true;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
      ]);
      _swap(true);
      await _reload(readSettingConfig);
    } else {
      rotateScreen = false;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      _swap();
      await _reload(readSettingConfig);
    }
    update(["preContent"]);
  }
  _swap([bool flag = false]) {
    double temp = screenHeight;
    screenHeight = screenWidth;
    screenWidth = temp;
    if (flag) {
      screenLeft = screenTop;
      screenRight = screenTop;
    } else {
      screenLeft = 0;
      screenRight = 0;
    }
  }

  /// 暗色主题
  Future changeDark() async{
    if (isDark) {
      var config = _getReadSettingConfig();
      readSettingConfig.backgroundColor = config.backgroundColor;
      readSettingConfig.fontColor = config.fontColor;
      update(["backgroundColor"]);
      // await _reload(readSettingConfig);
      isDark = false;
      update(["content", "bottomType"]);
    } else {
      readSettingConfig = ReadSettingConfig.defaultDarkConfig(readSettingConfig.fontSize, readSettingConfig.fontHeight);
      update(["backgroundColor"]);
      // await _reload(readSettingConfig);
      isDark = true;
      update(["content", "bottomType"]);
    }
  }

  /// 前往更多设置
  toMoreSetting() {
    autoPage?.cancel();
    Get.toNamed(Routes.readMoreSetting)!.then((value) {
      if (value != null && value["autoPage"]) {
        // 设置自动翻页
        if (autoPage != null) {
          autoPage!.cancel();
        }
        autoPage = Timer.periodic(Duration(seconds: value["autoPageRate"]), (timer) async {
          await nextPage();
        });
        update(["autoPage"]);
      }
    });
  }

  /// 自动翻页取消
  void autoPageCancel() {
    autoPage?.cancel();
    update(["autoPage"]);
  }

  /// 电池监听
  void _batteryListen() {
    _battery.onBatteryStateChanged.listen((BatteryState state) {
      batteryState = state;
      update(["battery"]);
    });
  }

  Timer? _batteryTimer;
  /// 获取电池容量
  _batteryCap() async{
    var second = DateTime.now().second;
    second = 60 - second;
    const Duration _oneMinute = Duration(minutes: 1);
    Timer(Duration(seconds: second), () {
      update(["battery"]);
      _batteryTimer = Timer.periodic(_oneMinute, (timer) async {
        batteryLevel = await _battery.batteryLevel;
        update(["battery"]);
      });
    });
  }

  void setPageType(ReadPageType pageType) {
    readPageType = pageType;
    update(["content"]);
  }

  /// 重新加载章节
  reloadPage() async{
    var chapterId = pages[pageIndex.count].chapterId;
    int firstIndex = pages.indexWhere((element) => chapterId == element.chapterId);
    pages.removeWhere((element) => element.chapterId == chapterId);
    Chapter chapter = chapters.firstWhere((element) => element.id == chapterId);
    getContent(chapter, true).then((value) async{
      List<ContentPage> list = await initPageWithReturn(chapter);
      pages.insertAll(firstIndex, list);
      update(["content"]);
    });

  }

  double calPaddingLeft(index) {
    return 0;
  }

  void _initSize() {
    _calTitleHeight();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    screenLeft = MediaQuery.of(context).padding.left;
    screenRight = MediaQuery.of(context).padding.right;
    screenBottom = 16;
    double top = MediaQuery.of(globalContext).padding.top;
    if (top < 33) {
      top = 33;
    }
    screenTop = top;
  }

  void _menuListen() {
    menuPositionsListener.itemPositions.addListener(() {
    });
  }

  void _pageIndexChangeListen() {
    pageIndex.addListener(() {
      final index = pageIndex.count;
      if (index < pages.length) {
        _bookDbProvider.updateCurChapter(book!.id, pages[index].chapterId, pages[index].index);
      }
    });
  }

  void _jumpPageIndex(int index) {
    if (readPageType == ReadPageType.smooth) {
      contentPageController.jumpToPage(index);
      pageIndex.setCount(index);
    }
    update(["content"]);
  }

  /// 音量物理键变化
  void _volumeChangeListen() {
    ChannelUtils.methodChannel.setMethodCallHandler((call) async{
      switch (call.method) {
        case 'bookVolumeChange':
          var res = call.arguments;
          if (res) {
            nextPage();
          } else {
            prePage();
          }
      }
    });
  }

}





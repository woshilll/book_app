import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/book_db_provider.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/book_with_chapters.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/home/book_home_controller.dart';
import 'package:book_app/module/book/read/component/page_gen.dart';
import 'package:book_app/module/book/readSetting/component/read_setting_config.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/bar_util.dart';
import 'package:book_app/util/channel_utils.dart';
import 'package:book_app/util/chapter_compare.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/dialog_build.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/future_do.dart';
import 'package:book_app/util/html_parse_util.dart';
import 'package:book_app/util/notify/counter_notify.dart';
import 'package:book_app/util/notify/object_notify.dart';
import 'package:book_app/util/path_util.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:woshilll_flutter_plugin/woshilll_flutter_plugin.dart';
import 'component/content_page.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ReadRefreshKey {
  content,
  page,
  background
}

class ReadController extends GetxController {
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
  /// 阅读进度
  int readChapterIndex = 0;
  /// 底部类型 1-正常 2-亮度 3-设置
  String bottomType = "1";
  /// 屏幕亮度
  double brightness = 0;
  /// 背景色
  List<String> backgroundColors = ReadSettingConfig.getCommonBackgroundColors();
  /// 默认背景色
  ReadSettingConfig readSettingConfig = ReadSettingConfig.defaultConfig();
  /// 是否旋转屏幕
  bool rotateScreen = false;
  /// x轴移动距离
  double xMove = 0;
  /// 是否为暗色模式
  bool isDark = Get.isPlatformDarkMode;
  /// 自动翻页
  Timer? autoPage;
  /// 阅读方式
  ReadPageType readPageType = ReadPageType.slide;
  /// 小说页面生成
  late PageGen pageGen;
  ZoomDrawerController zoomDrawerController = ZoomDrawerController();
  bool loading = false;
  BookWithChapters? bookWithChapters;
  /// 页面是否在滑动中
  ObjectNotify<bool> isSliding = ObjectNotify(false);
  /// 是否需要更新文本
  bool _needUpdateContent = false;
  @override
  void onInit() async{
    readPageType = getReadPageTypeByStr(SaveUtil.getString(Constant.readType));
    readSettingConfig = _getReadSettingConfig();
    if (isDark) {
      readSettingConfig = ReadSettingConfig.defaultDarkConfig(readSettingConfig.fontSize, readSettingConfig.fontHeight);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.onInit();
    var map = Get.arguments;
    book = map["book"];
    _pageIndexChangeListen();
    ChannelUtils.setConfig(Constant.pluginVolumeFlag, true);
    _volumeChangeListen();
    _isSlidingListener();
  }

  @override
  onReady() async{
    super.onReady();
    FutureDo.doAfterExecutor300(() {
      initData()?.then(
              (_) {
                _refreshBookChapter(book!);
              }
      );
    });
  }

  initData() async{
    /// 亮度 放在前面
    brightness = await WoshilllFlutterPlugin.getBrightness();
    pageGen = PageGen(readSettingConfig);
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
    loading = true;
    if (dialog) {
      Toast.toastL();
    }
    pageGen.genPages(chapter, book!, (List<ContentPage> list) async{
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
      Toast.cancel();
      if (canJumpPage){
        if (firstInit && book!.curPage != null) {
          _jumpPageIndex(book!.curPage! - 1);
        } else if (pageIndex.count >= pages.length) {
          _jumpPageIndex(pages.length - 1);
        } else {
          _jumpPageIndex(pageIndex.count);
        }
      } else {
        _needUpdateContent = true;
      }
      if (firstInit) {
        update(["drawer"]);
      }
      loading = false;
    }).catchError((onError) {
      loading = false;
    });
  }





  /// 计算当前章节一共多少页
  calThisChapterTotalPage(index) {
    var chapterId = pages[index].chapterId;
    return pages.lastIndexWhere((element) => element.chapterId == chapterId) - pages.indexWhere((element) =>  element.chapterId == chapterId) + 1;
  }

  /// 页面变化监听
  _pageChangeListen() async{
    if (loading) {
      return;
    }
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
    Get.back();
    if (rotateScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  /// 跳转章节
  jumpChapter(index, {bool pop = true, bool clearCount = false}) async{
    loading = true;
    Chapter chapter = chapters[index];
    index = pages.indexWhere((element) => chapter.id == element.chapterId);
    if (index >= 0) {
      // 已存在
      _jumpPageIndex(index);
    } else {
      pages.clear();
      if (clearCount) {
        pageIndex.resetCount();
      }
      bool dialog = (chapter.content == null || chapter.content!.isEmpty);
      await initPage(chapter, dialog: dialog);
    }
    if (pop) {
      Navigator.of(context).pop();
    }
    loading = false;
  }

  /// 下一页
  nextPage() async {
    int index = pageIndex.count;
    if (index < pages.length - 2) {
      // 有下一页
      _jumpPageIndex(index + 1);
    } else {
      // 到底了， 加载 获取当前章节
      var chapterId = pages[index].chapterId;
      var chapterIndex = chapters.indexWhere((element) => element.id == chapterId);
      if (chapterIndex >= 0 && chapterIndex != chapters.length - 1) {
        // 找到下一章
        Chapter next = chapters[chapterIndex + 1];
        initPage(next);
      }
    }
  }

  prePage() async {
    int index = pageIndex.count;
    if (index > 0) {
      // 有上一页
      pageIndex.setCount(index - 1);
      _prePageStyle();
    } else {
      // 无上一页
      var chapterId = pages[index].chapterId;
      var chapterIndex = chapters.indexWhere((element) => element.id == chapterId);
      if (chapterIndex > 0) {
        // 加载上一页
        Toast.toastL();
        Chapter pre = chapters[chapterIndex - 1];
        pageGen.genPages(pre, book!, (returnPages) {
          pages.insertAll(0, returnPages);
          update([ReadRefreshKey.content]);
          pageIndex.setCount(returnPages.length - 1);
          _prePageStyle();
          Toast.cancel();
        });

      }
    }
  }

  _prePageStyle() {
    if (readPageType.toString().contains(ReadPageType.slide.toString())) {
      contentPageController.jumpToPage(pageIndex.count);
    }
    update([ReadRefreshKey.content]);
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
    zoomDrawerController.toggle?.call();
    Future.delayed(const Duration(milliseconds: 400), () {update(["drawer"]);});
  }
  /// 上一章
  preChapter() async{
    if (readChapterIndex <= 0) {
      Toast.toast(toast: "没有更多了");
      return;
    }
    await jumpChapter(readChapterIndex - 1, pop: false, clearCount: true);
    readChapterIndex -= 1;
    update(["chapterChange"]);
  }

  /// 下一章
  nextChapter() async{
    if (readChapterIndex >= chapters.length - 1) {
      Toast.toast(toast: "没有更多了");
      return;
    }
    await jumpChapter(readChapterIndex + 1, pop: false, clearCount: true);
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
    BookHomeController homeController = Get.find();
    homeController.onBrightness = brightness;
    WoshilllFlutterPlugin.setBrightness(value);
    update(["brightness"]);
  }

  void setBackGroundColor(String backgroundColor) {
    if (isDark) {
      return;
    }
    if (readSettingConfig.backgroundColor != backgroundColor) {
      readSettingConfig.backgroundColor = backgroundColor;
      update([ReadRefreshKey.background, "bottomType"]);
    }
  }

  toSetting() async{
    ReadSettingConfig temp = ReadSettingConfig(readSettingConfig.backgroundColor, readSettingConfig.fontSize, readSettingConfig.fontColor, readSettingConfig.fontHeight, readSettingConfig.fontWeight);
    var value = await Get.toNamed(Routes.readSetting, arguments: {"config": temp});
    if (value != null && value["config"] != null) {
      ReadSettingConfig config = value["config"];
      if (config.fontSize != readSettingConfig.fontSize || config.fontWeight != readSettingConfig.fontWeight) {
        // 需要重新加载
        readSettingConfig.fontSize = config.fontSize;
        readSettingConfig.fontWeight = config.fontWeight;
        await _reload();
      }
      readSettingConfig = value["config"];
      update([ReadRefreshKey.background]);
    }
  }

  _reload() async{
    loading = true;
    Toast.toastL();
    pageGen.changeContentStyle(readSettingConfig);
    int chapterIndex = chapters.indexWhere((element) => pages[pageIndex.count].chapterId == element.id);
    pageIndex.setCount(pages[pageIndex.count].index - 1);
    pages.clear();
    await jumpChapter(chapterIndex, pop: false);
    Toast.cancel();
    loading = false;
  }

  @override
  void onClose() async{
    super.onClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    var config = _getReadSettingConfig();
    if (!isDark) {
      config.backgroundColor = readSettingConfig.backgroundColor;
      config.fontColor = readSettingConfig.fontColor;
    }
    config.fontSize = readSettingConfig.fontSize;
    config.fontHeight = readSettingConfig.fontHeight;
    String data = json.encode(config);
    SaveUtil.setString(Constant.readSettingConfig, data);
    autoPage?.cancel();
    transparentBar();
    ChannelUtils.setConfig(Constant.pluginVolumeFlag, false);
    SaveUtil.setString(Constant.readType, readPageType.name);
    bookWithChapters?.dispose();
    isSliding.dispose();
  }


  /// 行高减0.1
  fontHeightSub() async{
    if (readSettingConfig.fontHeight > 1) {
      readSettingConfig.fontHeight = readSettingConfig.fontHeight - 0.1;
      await _reload();
      update([ReadRefreshKey.content]);
    }
  }
  /// 行高加0.1
  fontHeightAdd() async{
    if (readSettingConfig.fontHeight < 3.5) {
      readSettingConfig.fontHeight = readSettingConfig.fontHeight + 0.1;
      await _reload();
      update([ReadRefreshKey.content]);
    }
  }

  /// 屏幕旋转
  rotateScreenChange() async{
    if (!rotateScreen) {
      rotateScreen = true;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
      ]);
      pageGen.heightWidthSwap(true);
      await _reload();
    } else {
      rotateScreen = false;
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      pageGen.heightWidthSwap();
      await _reload();
    }
    update([ReadRefreshKey.page]);
  }


  /// 暗色主题
  Future changeDark() async{
    if (isDark) {
      var config = _getReadSettingConfig();
      readSettingConfig.backgroundColor = config.backgroundColor;
      readSettingConfig.fontColor = config.fontColor;
      update([ReadRefreshKey.background]);
      // await _reload(readSettingConfig);
      isDark = false;
      update([ReadRefreshKey.content, "bottomType"]);
    } else {
      readSettingConfig = ReadSettingConfig.defaultDarkConfig(readSettingConfig.fontSize, readSettingConfig.fontHeight);
      update([ReadRefreshKey.background]);
      // await _reload(readSettingConfig);
      isDark = true;
      update([ReadRefreshKey.content, "bottomType"]);
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

  void setPageType(ReadPageType pageType) {
    readPageType = pageType;
    update([ReadRefreshKey.page]);
  }

  /// 重新加载章节
  reloadPage() async{
    Toast.toastL();
    var chapterId = pages[pageIndex.count].chapterId;
    int firstIndex = pages.indexWhere((element) => chapterId == element.chapterId);
    pages.removeWhere((element) => element.chapterId == chapterId);
    Chapter chapter = chapters.firstWhere((element) => element.id == chapterId);
    pageGen.genPages(chapter, book!, (list) {
      pages.insertAll(firstIndex, list);
      update([ReadRefreshKey.content]);
      Toast.cancel();
    });
    Toast.cancel();
  }


  void _pageIndexChangeListen() {
    pageIndex.addListener(() {
      final index = pageIndex.count;
      if (index < pages.length) {
        _bookDbProvider.updateCurChapter(book!.id, pages[index].chapterId, pages[index].index);
      }
      if (index + 30 >= pages.length && pages.isNotEmpty) {
        _pageChangeListen();
      }
    });
  }

  void _jumpPageIndex(int index) {
    pageIndex.setCount(index);
    if (readPageType.toString().contains(ReadPageType.slide.toString())) {
      contentPageController.jumpToPage(index);
    }
    update([ReadRefreshKey.content]);
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
          break;
        case 'bookPath':
          BookHomeController homeController = Get.find();
          homeController.parseBookWithShare(call);
      }
    });
  }

  /// 重置设置
  resetReadSetting() async{
    if (isDark) {
      return;
    }
    readSettingConfig = ReadSettingConfig.defaultConfig();
    await _reload();
  }

  /// 重新载入章节
  reDownload() async {
    if (book!.type != 1) {
      Toast.toast(toast: "本地章节无法重载");
      return;
    }
    Get.dialog(
      DialogBuild("重载章节", Text("该操作会重新从网络上下载该资源, 请确认", style: TextStyle(color: textColor()),), confirmFunction: () async{
        Get.back();
        Toast.toastL(toast: "重载中...");
        var chapterId = pages[pageIndex.count].chapterId;
        var chapter = chapters.firstWhere((element) => element.id == chapterId);
        Chapter? nextChapter = await _chapterDbProvider.getNextChapter(chapter.id, book!.id);
        chapter.content = FontUtil.formatContent(await HtmlParseUtil.parseContent(chapter.name!, chapter.url!, nextChapter?.url));
        await _chapterDbProvider.updateContent(chapter.id, chapter.content);
        reloadPage();
      },)
    );

  }

  /// 下载数据
  downloadBook(bool fromHead) async{
    if (book!.type != 1) {
      Toast.toast(toast: "本地章节无法缓存");
      return;
    }
    // 是否已全部缓存
    int? count = await _chapterDbProvider.getUnCacheCount(book!.id!);
    if (count == null || count == 0) {
      Toast.toast(toast: "已全部缓存");
      return;
    }
    BookHomeController homeController = Get.find();
    if (fromHead) {
      homeController.downloadBook(book!.id!, chapters[0].id!);
    } else {
      homeController.downloadBook(book!.id!, pages[pageIndex.count].chapterId!);
    }
  }

  getBookWithChapters() {
    BookHomeController homeController = Get.find();
    bookWithChapters = homeController.getBookWithChapters(book!.id!);
  }

  /// 导出为本地书籍
  exportBook() async{
    String path = await PathUtil.getSavePath("books");
    Log.i("$path/${book!.name}.txt");
    File file = File("$path/${book!.name}.txt");
    if (file.existsSync()) {
      /// 已存在
      Get.dialog(
        DialogBuild("文件已存在", const Text("文件已存在, 是否覆盖?"), confirmFunction: () async{
          Get.back();
          file.writeAsStringSync(await _createBookText());
          Toast.toast(toast: "已保存");
        },)
      );
      return;
    }
    file.createSync();
    file.writeAsStringSync(await _createBookText());
    Toast.toast(toast: "已保存");
  }
  Future<String> _createBookText() async{
    List<Chapter> chaptersWithContent = await _chapterDbProvider.getChaptersWithContent(book!.id!);
    List<String?> chapterStrList = [];
    for (var chapter in chaptersWithContent) {
      chapterStrList.add(chapter.name);
      chapterStrList.add(chapter.content);
    }
    return chapterStrList.join("\n");
  }

  _refreshBookChapter(Book book) async{
    if (book.type != 1) {
      return;
    }
    var today = DateTime.now();
    if (book.updateTime != null) {
      var date = book.updateTime!.split("-");
      if (date[0] == today.year.toString()
          && date[1] == today.month.toString()
          && date[2] == today.day.toString()
      ) {
        // 已经刷新
        return;
      }
    }
    _bookDbProvider.updateTime(book.id, "${today.year}-${today.month}-${today.day}");
    var oldList = await _chapterDbProvider.getChapters(null, book.id);
    var result = await HtmlParseUtil.parseChapter(book.url!);
    var newList = result[1];
    var needAdd = chapterCompare(oldList, newList);
    if (needAdd.isEmpty) {
      return;
    }
    for (var element in needAdd) {
      element.bookId = book.id;
    }
    _chapterDbProvider.commonBatchInsert(needAdd);
    Toast.toast(toast: "更新${needAdd.length}章节");
    chapters = await _chapterDbProvider.getChapters(null, book.id);
  }

  void _isSlidingListener() {
    isSliding.addListener(() {
      if (!isSliding.data && _needUpdateContent) {
        _needUpdateContent = false;
        update([ReadRefreshKey.content]);
      }
    });
  }
}





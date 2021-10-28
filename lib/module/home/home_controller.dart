import 'package:audio_service/audio_service.dart';
import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/menu.dart';
import 'package:book_app/module/book/read/component/content_page.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/audio/text_player_handler.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'component/drag_overlay.dart';

class HomeController extends GetxController {
  /// 数据库
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  List<Menu> menu = [];
  bool oldMan = false;
  List<Widget> tiles = [];
  /// 听小说
  late AudioHandler audioHandler;
  MediaItem? curMediaItem;
  bool _mediaLoadFlag = false;
  CrossFadeState dragFade = CrossFadeState.showFirst;
  @override
  void onInit() {
    super.onInit();
    var flag = SaveUtil.getTrue(Constant.oldManTrue);
    if (flag != null) {
      oldMan = flag;
    }
    oldMan ? oldManVersion() : normal();
    initAudio();
  }

  void initAudio() async{
    audioHandler = await AudioService.init(
      builder: () => TextPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
    await audioListen();
  }

  void normal() {
    tiles = [
      item(Colors.green, Icons.my_library_books, toast: "小说", route: Routes.bookHome,),
      item(Colors.lightBlue, Icons.send),
      item(Colors.amber, Icons.library_music, toast: "音乐"),
      item(Colors.brown, Icons.map),
      item(Colors.deepOrange, Icons.video_library, toast: "电影",),
      item(Colors.indigo, Icons.airline_seat_flat),
      item(Colors.red, Icons.bluetooth),
      item(Colors.pink, Icons.battery_alert),
      item(Colors.purple, Icons.desktop_windows),
      item(Colors.blue, Icons.radio),
    ];
  }
  void oldManVersion() {
    tiles = [
      item(Colors.green, Icons.my_library_books, toast: "小说", route: Routes.bookHome,),
      item(Colors.lightBlue, Icons.send),
      item(Colors.amber, Icons.library_music, toast: "音乐"),
      item(Colors.brown, Icons.map),
      item(Colors.deepOrange, Icons.video_library, toast: "电影",),
      item(Colors.indigo, Icons.airline_seat_flat),
      item(Colors.red, Icons.bluetooth),
      item(Colors.pink, Icons.battery_alert),
      item(Colors.purple, Icons.desktop_windows),
      item(Colors.blue, Icons.radio),
    ];
  }

  void changeOldMan() {
    oldMan = !oldMan;
    SaveUtil.setTrue(Constant.oldManTrue, isTrue: oldMan);
    oldMan ? oldManVersion() : normal();
    update(["oldMan"]);
  }


  Widget item(Color backgroundColor, IconData iconData, {String? toast, String? route}) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          if (route != null) {
            Get.toNamed(route);
          } else {
            EasyLoading.showToast("敬请期待");
          }

        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: oldMan ? Text(toast ?? '未命名', style: const TextStyle(color: Colors.white, fontSize: 25),)
            : Icon(
              iconData,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        onLongPress: () {
          if (toast != null) {
            EasyLoading.showToast(toast);
          }
        },
      ),
    );
  }

  /// 监听
  audioListen() async{
    audioHandler.mediaItem.listen((event) {
      if (event != null) {
        Log.i("监听到播放项变化  ${event.title}");
        curMediaItem = event;
      }
    });
    audioHandler.playbackState.listen((state) async{
      if (state.playing) {
        DragOverlay.show(globalContext, Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          child: GetBuilder<HomeController>(
            id: 'drag',
            builder: (controller) {
              return AnimatedCrossFade(
                firstChild: GestureDetector(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: CircleAvatar(
                      backgroundColor: Colors.pink,
                    ),
                  ),
                  onTap: () {
                    dragFade = CrossFadeState.showSecond;
                    update(["drag"]);
                  },
                ),
                secondChild: GestureDetector(
                  child: Opacity(
                    opacity: .7,
                    child: Container(
                      height: 50,
                      width: 100,
                      color: Colors.black,
                      child: Text(curMediaItem!.title, style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  onTap: () {
                    dragFade = CrossFadeState.showFirst;
                    update(["drag"]);
                  },
                ),
                crossFadeState: dragFade,
                duration: const Duration(milliseconds: 600),
              );
            },
          ),
        ));
      }
      if (state.processingState == AudioProcessingState.idle && !_mediaLoadFlag) {
        // 加载下一个章节
        if (curMediaItem != null) {
          Log.i("加载下个章节");
          var type = curMediaItem!.extras?["type"];
          if (type == "1") {
            // 是小说
            _mediaLoadFlag = true;
            int curChapterId = int.parse(curMediaItem!.id);
            Chapter? curChapter = await _chapterDbProvider.getChapterById(curChapterId);
            // 找到下一章的chapter
            Chapter? nextChapter = await _chapterDbProvider.getNext(curChapter!.bookId, curChapterId);
            if (nextChapter == null) {
              audioHandler.updateQueue([]);
              audioHandler.stop();
              return;
            }
            List<ContentPage> nextPages;
            try {
              ReadController readController = Get.find();
              nextPages = await readController.initPageWithReturn(nextChapter);
              for (var page in nextPages) {
                Log.i("页面未退出，加载  ${page.chapterName}");
                await audioHandler.addQueueItem(MediaItem(
                    id: page.chapterId.toString(),
                    album: "content",
                    title: page.chapterName.toString(),
                    extras: <String, String>{"content": page.content, "type": "1"}
                ));
              }
            } catch(err) {
              // 说明没找到
              if (nextChapter.content != null) {
                await audioHandler.addQueueItem(MediaItem(
                    id: nextChapter.id.toString(),
                    album: "content",
                    title: nextChapter.name!,
                    extras: <String, String>{"content": nextChapter.content!, "type": "1"}
                ));
              } else {
                // 发起网络请求解析
                String content = await ChapterApi.parseContent(nextChapter.url, false);
                await audioHandler.addQueueItem(MediaItem(
                    id: nextChapter.id.toString(),
                    album: "content",
                    title: nextChapter.name!,
                    extras: <String, String>{"content": content, "type": "1"}
                ));
                _chapterDbProvider.updateContent(nextChapter.id, content);
              }
            }
            audioHandler.skipToNext();
            audioHandler.play();
            _mediaLoadFlag = false;
          }
        }
      }
    });
  }
}

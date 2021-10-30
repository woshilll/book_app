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
  CrossFadeState dragFade = CrossFadeState.showFirst;
  AudioProcessingState audioProcessingState = AudioProcessingState.error;
  PlaybackState? _playbackState;
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
      item(Colors.purple, Icons.settings, toast: "设置", route: Routes.settingHome),
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
        curMediaItem = event;
      }
    });
    audioHandler.queue.listen((event) {
      Log.i("队列长度  ${event.length}");
    });
    audioHandler.playbackState.listen((state) async{
      _playbackState = state;
      update(["drag"]);
      if (state.playing && DragOverlay.view == null) {
        DragOverlay.show(globalContext, GetBuilder<HomeController>(
          id: 'drag',
          builder: (controller) {
            return AnimatedCrossFade(
              firstChild: GestureDetector(
                child: Card(
                  color: Colors.black,
                  child: Container(
                    width: 30,
                    height: 50,
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 25,),
                  ),
                  elevation: 5,
                ),
                onTap: () {
                  dragFade = CrossFadeState.showSecond;
                  update(["drag"]);
                },
              ),
              secondChild: GestureDetector(
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: MediaQuery.of(globalContext).size.width * 0.7,
                    color: Colors.black,
                    child: Row(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Icon(Icons.skip_previous, color: Colors.white, size: 25),
                              ),
                              onTap: () async{
                                if (_playbackState!.queueIndex != null && _playbackState!.queueIndex! > 0) {
                                  await audioHandler.skipToPrevious();
                                }
                              },
                            ),
                            GestureDetector(
                              child: Icon(_playbackState!.playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 25),
                              onTap: () async {
                                if (_playbackState!.playing) {
                                  await audioHandler.pause();
                                } else {
                                  await audioHandler.play();
                                }
                                update(["drag"]);
                              },
                            ),
                            GestureDetector(
                              child: Icon(Icons.skip_next, color: Colors.white, size: 25),
                              onTap: () async{
                                if (_playbackState!.queueIndex != null && _playbackState!.queueIndex! < audioHandler.queue.value.length - 1) {
                                  await audioHandler.skipToNext();
                                }
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text("${curMediaItem!.title}", style: TextStyle(fontSize: 14, color: Colors.white),),
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Icon(Icons.clear, color: Colors.white, size: 25),
                          ),
                          onTap: () async{
                            audioHandler.queue.value.clear();
                            await audioHandler.stop();
                            DragOverlay.remove();
                          },
                        )
                      ],
                  ),
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
        ));
      }
      if (state.processingState == AudioProcessingState.idle && audioProcessingState == AudioProcessingState.idle) {
        // 加载下一个章节
        if (curMediaItem != null) {
          Log.i("加载下个章节");
          var type = curMediaItem!.extras?["type"];
          if (type == "1") {
            // 是小说
            if (state.queueIndex! >= audioHandler.queue.value.length) {
              return;
            }
            int curChapterId = int.parse(audioHandler.queue.value[state.queueIndex!].id);
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
          }
        }
        audioProcessingState = AudioProcessingState.error;
      } else {
        audioProcessingState = state.processingState;
      }
    });
  }
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:book_app/util/audio/text_player_handler.dart';
import 'package:book_app/util/rsa_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'api/chapter_api.dart';
import 'log/log.dart';
import 'mapper/chapter_db_provider.dart';
import 'model/chapter/chapter.dart';
import 'module/book/read/component/content_page.dart';
import 'module/book/read/read_controller.dart';
import 'module/home/component/drag_overlay.dart';

class AppController extends GetxController {
  var screenColor = Colors.white;
  var screenColorModel = BlendMode.darken;
  /// 数据库
  static final ChapterDbProvider _chapterDbProvider = ChapterDbProvider();
  /// 听小说
  late AudioHandler audioHandler;
  MediaItem? curMediaItem;
  CrossFadeState dragFade = CrossFadeState.showFirst;
  AudioProcessingState audioProcessingState = AudioProcessingState.error;
  PlaybackState? _playbackState;
  setScreenStyle(Color color, {BlendMode mode = BlendMode.darken}) {
    screenColor = color;
    screenColorModel = mode;
    update(["fullScreen"]);
  }
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(milliseconds: 50), () {
      RsaUtil.gen();
    });
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
  /// 监听
  audioListen() async{
    audioHandler.mediaItem.listen((event) {
      if (event != null) {
        curMediaItem = event;
      }
    });
    audioHandler.queue.listen((event) {
    });
    audioHandler.playbackState.listen((state) async{
      _playbackState = state;
      update(["drag"]);
      if (state.playing && DragOverlay.view == null) {
        DragOverlay.show(globalContext, GetBuilder<AppController>(
          id: 'drag',
          builder: (controller) {
            return AnimatedCrossFade(
              firstChild: GestureDetector(
                child: Card(
                  color: Theme.of(globalContext).textTheme.bodyText1!.color,
                  child: Container(
                    width: 30,
                    height: 50,
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward_ios, color: Theme.of(globalContext).textTheme.bodyText2!.color, size: 25,),
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
                    color: Theme.of(globalContext).textTheme.bodyText1!.color,
                    child: Row(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Icon(Icons.skip_previous, color: Theme.of(globalContext).textTheme.bodyText2!.color, size: 25),
                              ),
                              onTap: () async{
                                if (_playbackState!.queueIndex != null && _playbackState!.queueIndex! > 0) {
                                  await audioHandler.skipToPrevious();
                                }
                              },
                            ),
                            GestureDetector(
                              child: Icon(_playbackState!.playing ? Icons.pause : Icons.play_arrow, color: Theme.of(globalContext).textTheme.bodyText2!.color, size: 25),
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
                              child: Icon(Icons.skip_next, color: Theme.of(globalContext).textTheme.bodyText2!.color, size: 25),
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
                              child: Text("${curMediaItem!.title}", style: TextStyle(fontSize: 14, color: Theme.of(globalContext).textTheme.bodyText2!.color),),
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Icon(Icons.clear, color: Theme.of(globalContext).textTheme.bodyText2!.color, size: 25),
                          ),
                          onTap: () async{
                            // audioHandler.queue.value.clear();
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
      if (state.processingState == AudioProcessingState.idle && audioProcessingState == AudioProcessingState.idle && state.playing) {
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
            String? bookName = audioHandler.queue.value[state.queueIndex!].album;
            try {
              ReadController readController = Get.find();
              nextPages = await readController.initPageWithReturn(nextChapter);
              for (var page in nextPages) {
                await audioHandler.addQueueItem(MediaItem(
                    id: page.chapterId.toString(),
                    album: bookName,
                    title: page.chapterName.toString(),
                    extras: <String, String>{"content": page.content, "type": "1"}
                ));
              }
            } catch(err) {
              // 说明没找到
              if (nextChapter.content != null) {
                await audioHandler.addQueueItem(MediaItem(
                    id: nextChapter.id.toString(),
                    album: bookName,
                    title: nextChapter.name!,
                    extras: <String, String>{"content": nextChapter.content!, "type": "1"}
                ));
              } else {
                // 发起网络请求解析
                String? content = await ChapterApi.parseContent(nextChapter.url, false);
                if (content == null) {
                  return;
                }
                await audioHandler.addQueueItem(MediaItem(
                    id: nextChapter.id.toString(),
                    album: bookName,
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

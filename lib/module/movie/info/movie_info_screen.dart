import 'package:book_app/log/log.dart';
import 'package:book_app/module/movie/info/movie_info_controller.dart';
import 'package:book_app/util/subtitle_util.dart';
import 'package:book_app/util/time_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_alilistplayer.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class MovieInfoScreen extends GetView<MovieInfoController> {
  const MovieInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(child: Scaffold(
      body: _body(context),
    ), value: SystemUiOverlayStyle.light);
  }

  Widget _body(context) {
    return GetBuilder<MovieInfoController>(
      id: "videoInfoBody",
      builder: (controller) {
        if (controller.isShimmer) {
          return Container();
        }
        return Column(
          children: [
            Container(height: MediaQuery.of(context).padding.top, color: Colors.black,),
            AspectRatio(
              aspectRatio: 5.5 / 3,
              child: _cover(context),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 14),
                  children: [
                    TextSpan(
                        text: "上映时间：${controller.videoInfo!.video!.releaseDay}\n\n"
                    ),
                    TextSpan(
                        text: "状态：${controller.videoInfo!.video!.serial == "1" ? "已完结" : "连载中"}\n\n"
                    ),
                    TextSpan(
                      text: "国家：${controller.videoInfo!.video!.tagName}\n\n"
                    ),
                    TextSpan(
                        text: "演员列表：${controller.videoInfo!.video!.actors}\n\n"
                    ),
                    (controller.videoInfo!.video!.description == null || controller.videoInfo!.video!.description!.isEmpty) ?
                        const TextSpan(text: "介绍：暂无介绍")
                        :
                        TextSpan(text: "介绍：${controller.videoInfo!.video!.description}")
                  ]
                )
              )
            ),
            _videoItems(context),
            // TextButton(child: Text("测试"), onPressed: () async{
            //   var contents = await SubtitleUtil.getSubtitle("https://app-woshilll.oss-cn-shenzhen.aliyuncs.com/video/subtitle/test.srt");
            //   Log.i(contents);
            //   Log.i(await SubtitleUtil.getContent(51, contents, 0));
            // },)
          ],
        );
      },
    );
  }

  Widget _cover(context) {
    return Hero(
      tag: "player",
      child: GestureDetector(
        child: Stack(
          children: [
            Container(
              color: Colors.black,
            ),
            _videoBackground(context),
            Container(color: Colors.transparent,),
            if (controller.showControl)
              Positioned(
                child: TextButton(
                  child: const Icon(Icons.chevron_left_outlined, size: 30, color: Colors.white,),
                  onPressed: () {
                    controller.fullScreenPop(context);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(1, 1)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    // backgroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                ),
              ),
            if (controller.showControl)
              Positioned(
                child: Center(
                  child: GestureDetector(
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.4),
                          borderRadius: BorderRadius.circular(64)
                      ),
                      child: AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        size: 30,
                        progress: controller.playPauseStatusChangeController!,
                      ),
                    ),
                    onTap: () async{
                      await controller.getPlayInfo();
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                child: SizedBox(width: MediaQuery.of(context).size.width, child: _timeProgress(context),),
              ),
              Positioned(
                right: 35,
                bottom: 40,
                child: _rate(context),
              ),
          ],
        ),
        onTap: () {
          controller.tapShowControl();
        },
        onDoubleTap: () async{
          await controller.movieDoubleClick();
        },
        onVerticalDragStart: (e) {
          controller.moveX = e.globalPosition.dx;
          controller.moveY = e.globalPosition.dy;
          controller.fullScreenWidth = MediaQuery.of(context).size.width;
        },
        onVerticalDragUpdate: (e) async{
          if (controller.isPlayerInitialize && controller.playing) {
            await controller.verticalUpdate(e.globalPosition.dx, e.globalPosition.dy);
          }
        },
      ),
    );
  }

  Widget _videoBackground(context) {
    if (controller.isPlayerInitialize) {
      return AliPlayerView(
        onCreated: onViewPlayerCreated,
      );
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: CachedNetworkImage(imageUrl: controller.videoInfo!.video!.coverImgBig ?? controller.videoInfo!.video!.coverImg!,),
    );
  }


  Widget _videoItems(context) {
    return SizedBox(
      height: 40,
      child: GetBuilder<MovieInfoController>(
        id: "videoItems",
        builder: (controller) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(10),
                child: TextButton(
                  child: Text(controller.videoInfo!.itemList![index].name!, style: TextStyle(fontSize: 14, color: controller.videoItemIndex == index ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyText1!.color),),
                  onPressed: () {
                    if (controller.videoItemIndex != index) {
                      controller.changeVideoItem(index);
                    }
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(const Size(1, 1)),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      overlayColor: MaterialStateProperty.all(Colors.transparent)
                    // backgroundColor: MaterialStateProperty.all(Colors.grey),
                  ),
                ),
              );
            },
            itemCount: controller.videoInfo!.itemList!.length,
          );
        },
      ),
    );
  }

  Widget _timeProgress(context) {
    return GetBuilder<MovieInfoController>(
      id: "timeProgress",
      builder: (controller) {
        if (controller.isPlayerInitialize && controller.showControl) {
          return Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15),
                child: Text(TimeUtil.formatTime(controller.playSeconds)),
              ),
              Expanded(
                child: Slider(
                  onChanged: (e) {
                    controller.playSeconds = e.toInt();
                    controller.update(["timeProgress"]);
                  },
                  label: TimeUtil.formatTime(controller.playSeconds),
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Colors.grey,
                  min: 0,
                  max: controller.totalSeconds.ceilToDouble(),
                  value: controller.playSeconds.ceilToDouble(),
                  onChangeEnd: (value) {
                    controller.processEnd(value);
                  },
                  onChangeStart: (value) {
                    controller.processStart();
                  },
                ),
              ),
              Container(
                child: Text(TimeUtil.formatTime(controller.totalSeconds)),
                margin: const EdgeInsets.only(left: 15, right: 15),
              ),
              if (controller.fullScreen)
                GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: const Text("倍数", style: TextStyle(height: 1),),
                  ),
                  onTap: () {
                    controller.showRate();
                  },
                ),
              GestureDetector(
                child: Container(
                  width: 25,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: controller.fullScreen ? 25 : 15),
                  child: Icon(controller.fullScreen ? Icons.fullscreen_exit : Icons.fullscreen, size: 30,),
                ),
                onTap: () async {
                  if (!controller.fullScreen) {
                    await fullScreen(context);
                  } else {
                    controller.fullScreenPop(context);
                  }
                },
              )
            ],
          );
        }
        return Container();
      },
    );
  }

  fullScreen(context) async{
    controller.fullScreen = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, //全屏时旋转方向，左边
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return WillPopScope(
        child: GetBuilder<MovieInfoController>(
          id: "videoInfoBody",
          builder: (controller) {
            return Column(
              children: [
                Container(height: MediaQuery.of(context).padding.top, color: Colors.black,),
                Expanded(
                  child: _cover(context),
                )
              ],
            );
          },
        ),
        onWillPop: () async {
          controller.fullScreenPop(context);
          return false;
        },
      );
    })).then((value) {
      if (value != null && value["fullScreen"]) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp
        ]);
      }
    });
  }
  void onViewPlayerCreated(viewId) async {
    // ///将渲染的View设置给播放器
    controller.fAliplayer!.setPlayerView(viewId);
    // //设置播放源
    //
  }

  Widget _rate(context) {
    return GetBuilder<MovieInfoController>(
      id: "rate",
      builder: (controller) {
        if (controller.showRateWidget) {
          return Card(
            color: Colors.white.withOpacity(.3),
            child: Container(
              height: 123,
              width: 70,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Container(
                      height: 30,
                      alignment: Alignment.center,
                      child: Text("${0.5 * (index + 1)}x", style: TextStyle(color: controller.rateIndex == index ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyText2!.color),),
                    ),
                    onTap: () {
                      controller.setRate(index);
                    },
                  );
                },
                itemCount: 4,
                separatorBuilder: (context, index) {
                  return Container(height: 1, color: Colors.grey,);
                },
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}

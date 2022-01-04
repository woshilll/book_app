import 'dart:async';
import 'dart:io';

import 'package:book_app/api/video_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/video/aliyun_play_info.dart';
import 'package:book_app/model/video/video_info.dart';
import 'package:book_app/util/channel_utils.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/encrypt_util.dart';
import 'package:book_app/util/save_util.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_aliplayer/flutter_aliplayer.dart';
import 'package:flutter_aliplayer/flutter_aliplayer_factory.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class MovieInfoController extends GetxController
    with SingleGetTickerProviderMixin {
  /// 上个页面传的视频id
  int? videoId;

  /// 接口获取的视频详情
  VideoInfo? videoInfo;

  /// 是否展示未加载
  bool isShimmer = true;

  /// 阿里云视频详情
  AliyunPlayInfo? aliyunPlayInfo;

  /// 播放视频索引
  int videoItemIndex = 0;

  /// 视频播放和暂停icon动画控制
  AnimationController? playPauseStatusChangeController;

  /// 播放器是否序列化完成
  bool isPlayerInitialize = false;

  /// 是否显示控件
  bool showControl = true;

  /// 播放时间
  int playSeconds = 0;

  /// 视频时长
  int totalSeconds = -1;

  /// 进度条，暂停开始控件展示
  Timer? _showControlTimer;

  /// 是否全屏
  bool fullScreen = false;

  /// 阿里云播放器
  FlutterAliplayer? fAliplayer;

  /// 是否正在播放
  bool playing = false;

  /// 是否播放完成
  bool complete = false;

  /// 是否现在播放倍数组件
  bool showRateWidget = false;

  /// 播放倍数索引 [0.5, 1, 1.5, 2]
  int rateIndex = 1;

  /// 移动开始x轴位置
  double moveX = 0;

  /// 移动开始y轴位置
  double moveY = 0;

  /// 横屏宽度
  double fullScreenWidth = 0;

  /// 音量
  double volume = 0;

  /// 默认亮度为0.5
  double defaultBrightness = .5;

  bool isProcessMove = false;

  @override
  void onInit() {
    super.onInit();
    videoId = Get.arguments["id"];
    playPauseStatusChangeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void onReady() async {
    super.onReady();
    videoInfo = await VideoApi.getInfo(videoId);
    isShimmer = false;
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    update(["videoInfoBody"]);
  }

  getPlayInfo() async {
    if (isPlayerInitialize) {
      await _pauseOrPlay();
    } else {
      await initVideo();
    }
  }

  _pauseOrPlay() async {
    if (complete) {
      fAliplayer!.prepare();
      playing = true;
      complete = false;
      await playPauseStatusChangeController!.reverse();
      await playPauseStatusChangeController!.forward();
      showControl = false;
      update(["videoInfoBody"]);
      return;
    }
    if (playing) {
      // 要暂停
      playPauseStatusChangeController!.reverse();
      fAliplayer!.pause();
      _showControlTimer?.cancel();
      playing = false;
      showControl = true;
      update(["videoInfoBody"]);
      return;
    } else {
      // 要播放
      await playPauseStatusChangeController!.reverse();
      await playPauseStatusChangeController!.forward();
      fAliplayer!.play();
      playing = true;
      _showControlTimer = Timer(const Duration(milliseconds: 2000), () {
        showControl = false;
        update(["videoInfoBody"]);
      });
      return;
    }
  }

  @override
  void onClose() async {
    super.onClose();
    fAliplayer?.destroy();
    Wakelock.disable();
    ChannelUtils.setBrightness(.5);
    if (Platform.isAndroid) {
      // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
      SystemUiOverlayStyle systemUiOverlayStyle =
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.transparent, systemNavigationBarDividerColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
  }

  /// 播放器监听
  void _addListener() {
    fAliplayer!.setOnCompletion((playerId) {
      _showControlTimer?.cancel();
      showControl = true;
      playing = false;
      playPauseStatusChangeController!.reset();
      update(["videoInfoBody"]);
      complete = true;
    });
    fAliplayer!.setOnInfo((infoCode, extraValue, extraMsg, playerId) {
      if (infoCode == 2) {
        // 当前秒数
        if (!isProcessMove) {
          playSeconds = extraValue ~/ 1000;
          update(["timeProgress"]);
        }
      }
      if (infoCode == 1) {
        // 总共秒数
      }
    });
  }

  /// 展示控制控件
  tapShowControl() {
    if (isPlayerInitialize && !showControl) {
      showControl = true;
      update(["videoInfoBody"]);
      _showControlTimer?.cancel();
      _showControlTimer = Timer(const Duration(seconds: 3), () {
        showControl = false;
        if (fullScreen) {
          showRateWidget = false;
        }
        update(["videoInfoBody"]);
      });
      return;
    }
    if (isPlayerInitialize && showControl && playing) {
      _showControlTimer?.cancel();
      showControl = false;
      if (fullScreen) {
        showRateWidget = false;
      }
      update(["videoInfoBody"]);
      return;
    }
  }

  /// 全屏结束
  void fullScreenPop(context) {
    Navigator.of(context).pop({"fullScreen": fullScreen});
    fullScreen = false;
    showRateWidget = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    update(["videoInfoBody"]);
  }

  /// 初始化视频
  initVideo() async {
    if (playPauseStatusChangeController!.status == AnimationStatus.completed) {
      playPauseStatusChangeController!.reverse();
    } else if (playPauseStatusChangeController!.status ==
        AnimationStatus.dismissed) {
      playPauseStatusChangeController!.forward();
    }
    fAliplayer = FlutterAliPlayerFactory.createAliPlayer();
    var vid = videoInfo!.itemList![videoItemIndex].vid;
    var itemId = videoInfo!.itemList![videoItemIndex].id;
    aliyunPlayInfo = await VideoApi.getPlayInfo(vid, itemId);
    totalSeconds = double.parse(aliyunPlayInfo!.videoBase!.duration!).toInt();
    var encryptToken = await EncryptUtil.encryptToken(
        SaveUtil.getString(Constant.token)!.replaceAll("\"", ""));
    encryptToken = encryptToken.replaceAll("%2B", "+");
    String url = aliyunPlayInfo!.playInfoList![0].playURL! +
        "&MtsHlsUriToken=$encryptToken";
    isPlayerInitialize = true;
    showControl = false;
    update(["videoInfoBody"]);
    fAliplayer!.setUrl(url);
    fAliplayer!.setAutoPlay(true);
    fAliplayer!.prepare();
    volume = await fAliplayer!.getVolume();
    playing = true;
    _addListener();
  }

  /// 展示倍数
  showRate() {
    showRateWidget = !showRateWidget;
    if (showRateWidget) {
      _showControlTimer?.cancel();
    } else {
      if (showControl) {
        showControl = !showControl;
        update(["videoInfoBody"]);
        return;
      }
    }
    update(["rate"]);
  }

  /// 设置倍数
  void setRate(int index) {
    fAliplayer!.setRate(0.5 * (index + 1));
    rateIndex = index;
    showRate();
  }

  /// 双击
  movieDoubleClick() async {
    if (isPlayerInitialize) {
      await _pauseOrPlay();
    }
  }

  verticalUpdate(double dx, double dy) async{
    if (moveX > fullScreenWidth / 2) {
      // 加减音量
      double move = dy - moveY;
      if (move >= 40) {
        // 减音量
        moveY = dy;
        int down = move ~/ 40;
        double nowVolume = volume - (down / 10);
        if (nowVolume < 0) {
          nowVolume = 0;
        }
        if (volume != nowVolume) {
          volume = nowVolume;
          await fAliplayer!.setVolume(volume);
        }
      }
      if (move <= -40) {
        moveY = dy;
        move = 0 - move;
        // 加音量
        int up = move ~/ 40;
        double nowVolume = volume + (up / 10);
        if (nowVolume > 1) {
          nowVolume = 1;
        }
        if (nowVolume != volume) {
          volume = nowVolume;
          await fAliplayer!.setVolume(volume);
        }
      }
    } else {
      // 加减亮度
      double move = dy - moveY;
      if (move >= 40) {
        // 减亮度
        moveY = dy;
        int down = move ~/ 40;
        double now = defaultBrightness - (down / 10);
        if (now < 0) {
          now = 0;
        }
        if (defaultBrightness != now) {
          defaultBrightness = now;
          await ChannelUtils.setBrightness(defaultBrightness);
        }
      }
      if (move <= -40) {
        moveY = dy;
        move = 0 - move;
        // 加音量
        int up = move ~/ 40;
        double now = defaultBrightness + (up / 10);
        if (now > 1) {
          now = 1;
        }
        if (now != defaultBrightness) {
          defaultBrightness = now;
          await ChannelUtils.setBrightness(defaultBrightness);
        }
      }
    }
  }

  processStart() {
    isProcessMove = true;
    _showControlTimer?.cancel();
  }

  void processEnd(double value) {
    Log.i(value.toInt());
    isProcessMove = false;
    _showControlTimer = Timer(const Duration(milliseconds: 2000), () {
      showControl = false;
      update(["videoInfoBody"]);
    });
    fAliplayer!.seekTo(value.toInt() * 1000, FlutterAvpdef.ACCURATE);
  }

  void changeVideoItem(int index) {
    _showControlTimer?.cancel();
    videoItemIndex = index;
    isPlayerInitialize = false;
    fAliplayer?.destroy();
    showControl = true;
    playPauseStatusChangeController!.reset();
    update(["videoInfoBody"]);
  }
}

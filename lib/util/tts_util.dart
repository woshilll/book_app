import 'package:flutter_tts/flutter_tts.dart';

class TTSUtil {

  factory TTSUtil() => getInstance();

  static TTSUtil get instance => getInstance();
  static TTSUtil? _instance;

  static TTSUtil getInstance() {
    _instance ??= TTSUtil._init();
    return _instance!;
  }

  TTSUtil._init() {
    flutterTts ??= FlutterTts();
  }
  FlutterTts? flutterTts;


  Future speak(String text) async {
    /// 设置语言
    await flutterTts!.setLanguage("zh-CN");

    /// 设置音量
    await flutterTts!.setVolume(0.8);

    /// 设置语速
    await flutterTts!.setSpeechRate(0.5);

    /// 音调
    await flutterTts!.setPitch(1.0);

    // text = "你好，我的名字是李磊，你是不是韩梅梅？";
    if (text.isNotEmpty) {
      await flutterTts!.speak(text);
    }
  }

  /// 暂停
  Future _pause() async {
    await flutterTts!.pause();
  }

  /// 结束
  Future _stop() async {
    await flutterTts!.stop();
  }
}


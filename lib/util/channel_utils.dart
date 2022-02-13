import 'package:book_app/log/log.dart';
import 'package:flutter/services.dart';

class ChannelUtils {
  static const methodChannel = MethodChannel('woshill/plugin');


  /// 设置屏幕亮度
  static setBrightness(double brightness) async {
    await methodChannel.invokeMethod("setBrightness", brightness);
  }

  /// 获取屏幕亮度
  static getBrightness() async {
    return await methodChannel.invokeMethod("getBrightness");
  }

  static setConfig(String key, Object value) async {
    await methodChannel.invokeMethod("setConfig", {"key": key, "value": value});
  }
}
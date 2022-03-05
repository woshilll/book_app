import 'package:book_app/log/log.dart';
import 'package:flutter/services.dart';

class ChannelUtils {
  static const methodChannel = MethodChannel('woshill/plugin');

  static setConfig(String key, Object value) async {
    await methodChannel.invokeMethod("setConfig", {"key": key, "value": value});
  }
}
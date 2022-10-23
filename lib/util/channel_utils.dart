import 'dart:io';

import 'package:flutter/services.dart';

class ChannelUtils {
  static const methodChannel = MethodChannel('woshill/plugin');

  static setConfig(String key, Object value) async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod("setConfig", {"key": key, "value": value});
    }
  }
}
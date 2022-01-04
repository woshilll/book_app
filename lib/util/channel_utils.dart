import 'package:book_app/log/log.dart';
import 'package:flutter/services.dart';

class ChannelUtils {
  static const _methodChannel = MethodChannel('woshill/plugin');


  static setBrightness(double brightness) async {
    await _methodChannel.invokeMethod("setBrightness", brightness);
  }
}
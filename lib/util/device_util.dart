import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtil {
  static getId() async{
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      var info = await deviceInfo.androidInfo;
      device = info.androidId;
    } else {
      var info = await deviceInfo.iosInfo;
      device = info.identifierForVendor;
    }
    return device;
  }
}

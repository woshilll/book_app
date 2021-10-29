import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/save_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SplashController extends GetxController {
  final String title = '启动页';
  late BuildContext context;


  @override
  void onInit() {
    super.onInit();

    // 陀螺仪监控
    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   // Log.i(event);
    // });
  }





  toHome() {
    SaveUtil.setTrue(Constant.splashTrue);
    Get.offAndToNamed(Routes.home);
  }


}

import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/save_util.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SplashController extends GetxController {
  final String title = '启动页';
  List<String> defaultInitPage = ["默认启动页", "asdsa", "trtete"];
  int pageIndex = 0;
  int timeCountdown = 5;
  late final Timer timeCountdownTimer;


  @override
  void onInit() {
    super.onInit();
    getSplashPages();
    timeCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeCountdown < 1) {
        timeCountdownTimer.cancel();
      } else {
        timeCountDown();
      }
    });
    // 陀螺仪监控
    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   // Log.i(event);
    // });
  }

  /// 获取启动页图片
  getSplashPages() {
    defaultInitPage =  ["第一页", "第二页"];
  }

  /// 设置当前第几页
  setPageIndex(int index) {
    pageIndex = index;
    update(['pageIndexChange', 'lastPageButton']);
  }

  /// 倒计时
  timeCountDown() {
    timeCountdown--;
    update(['timeCountdown', 'lastPageButton']);
  }

  toHome() {
    if (timeCountdown <= 0) {
      SaveUtil.setTrue(Constant.splashTrue);
      Get.offAndToNamed(Routes.home);
    }
  }


}

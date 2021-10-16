import 'dart:async';

import 'package:book_app/route/routes.dart';
import 'package:get/get.dart';

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
      Get.offAndToNamed(Routes.home);
    }
  }
}

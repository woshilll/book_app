import 'package:book_app/app_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

class ReadMoreSettingController  extends GetxController{
  bool autoPage = false;
  int autoPageRate = 5;
  bool goodEyes = false;
  AppController appController = Get.find();
  String goodEyesHex = "#FFF9DE";

  @override
  void onInit() {
    super.onInit();
    var nowScreenColor = colorToHex(appController.screenColor, includeHashSign: true, enableAlpha: false);
    goodEyes = goodEyesHex == nowScreenColor;
  }
  void setAutoPage(bool value) {
    autoPage = value;
    update(["moreSetting"]);
  }

  void setAutoPageRate(int value) {
    autoPageRate = value;
    update(["moreSetting"]);
  }

  void setGoodEyes(bool value) {
    if (value) {
      appController.setScreenStyle(hexToColor(goodEyesHex));
    } else {
      appController.setScreenStyle(Colors.white);
    }
    goodEyes = value;
    update(["moreSetting"]);
  }

  void pop() {
    Get.back(result: {'autoPage': autoPage, 'autoPageRate': autoPageRate});
  }

  void fresh() {
    update(["moreSetting"]);
  }

}

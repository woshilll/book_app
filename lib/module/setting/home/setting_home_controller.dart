import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingHomeController extends GetxController {
  bool isDarkModel = false;
  BuildContext context = globalContext;
  Color? backgroundColor;
  Color? textColor;
  setDarkMode(bool value) {
    if (value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    isDarkModel = value;
    update(["setting"]);
  }

  @override
  void onInit() {
    super.onInit();
    backgroundColor = Theme.of(context).textTheme.bodyText2!.color;
    textColor = Theme.of(context).textTheme.bodyText1!.color;
    isDarkModel = Get.isDarkMode;
  }
}

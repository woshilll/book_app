import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingHomeController extends GetxController {
  setDarkMode(bool value) {
    if (value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    update(["setting"]);
  }

}
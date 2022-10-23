import 'package:flutter/material.dart';
import 'package:get/get.dart';

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
  'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

Color? backgroundColor() {
  return Get.isPlatformDarkMode ? Colors.black : null;
}

Color? backgroundColorL2() {
  return Get.isPlatformDarkMode ? hexToColor("#2F2E2E") : null;
}

Color? textColor() {
  return Get.isPlatformDarkMode ? hexToColor("#a9a9a9") : null;
}

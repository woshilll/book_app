import 'dart:async';

import 'package:book_app/util/rsa_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  var screenColor = Colors.white;
  var screenColorModel = BlendMode.darken;


  setScreenStyle(Color color, {BlendMode mode = BlendMode.darken}) {
    screenColor = color;
    screenColorModel = mode;
    update(["fullScreen"]);
  }
  @override
  void onInit() {
    super.onInit();
    Timer(const Duration(milliseconds: 50), () {
      RsaUtil.gen();
    });
  }
}

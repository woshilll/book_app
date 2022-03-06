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
}

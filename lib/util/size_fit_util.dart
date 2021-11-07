import 'package:book_app/log/log.dart';
import 'package:flutter/material.dart';

class SizeFitUtil {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? rpx;
  static double? px;
  static void initialize(BuildContext context, {double standardWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    rpx = screenWidth! / standardWidth;
    px = screenWidth! / standardWidth * 2;
  }

  // 按照像素来设置
  static double setPx(double size) {

    return SizeFitUtil.rpx! * size * 2;
  }

  // 按照rxp来设置
  static double setRpx(double size) {
    return SizeFitUtil.rpx! * size;
  }

}

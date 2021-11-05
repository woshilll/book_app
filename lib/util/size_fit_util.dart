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
    Log.i(SizeFitUtil.rpx! * size);
    Log.i(_mediaQueryData!.size.width);
    Log.i(_mediaQueryData!.size.height);
    Log.i(_mediaQueryData!.padding.top);
    Log.i(_mediaQueryData!.padding.bottom);
    return SizeFitUtil.rpx! * size;
  }

}

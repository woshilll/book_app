import 'package:flutter/material.dart';
getAppBarTop() {

}
/// 获取状态栏高度
double getStatusBarHeight(BuildContext context) {
  return MediaQuery.of(context).padding.top;
}
late BuildContext globalContext;

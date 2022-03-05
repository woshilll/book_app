import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BottomWidgetUtil {
  static Future showCupertinoWidget<C extends GetxController, V extends GetView>(BuildContext context, C c, V v, {Function(C c)? preFunction, Function(C c)? finishFunction}) async{
    Get.put<C>(c);
    if (preFunction != null) {
      preFunction(c);
    }
    var value = await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) {
          return v;
        }
    );
    if (finishFunction != null) {
      finishFunction(c);
    }
    Get.delete<C>();
    return value;
  }
}
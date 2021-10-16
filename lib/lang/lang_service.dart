import 'package:book_app/lang/zh_cn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en_us.dart';

class LangService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocale = Locale('zh', 'CN');
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'zh_CN': zh_CN
  };

}

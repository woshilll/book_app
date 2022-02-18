import 'package:get/get.dart';

import 'diary_edit_controller.dart';

class DiaryEditBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiaryEditController>(() => DiaryEditController());
  }

}
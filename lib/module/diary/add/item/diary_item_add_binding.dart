import 'package:get/get.dart';

import 'diary_item_add_controller.dart';

class DiaryItemAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiaryItemAddController>(() => DiaryItemAddController());
  }

}
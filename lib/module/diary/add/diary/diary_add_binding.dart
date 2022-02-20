import 'package:book_app/module/diary/add/diary/diary_add_controller.dart';
import 'package:get/get.dart';

class DiaryAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiaryAddController>(() => DiaryAddController());
  }

}
import 'package:book_app/module/diary/home/diary_home_controller.dart';
import 'package:get/get.dart';

class DiaryHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiaryHomeController>(() => DiaryHomeController());
  }

}
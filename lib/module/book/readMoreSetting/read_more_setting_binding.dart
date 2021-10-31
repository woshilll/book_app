import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
import 'package:get/get.dart';

class ReadMoreSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ReadMoreSettingController>(ReadMoreSettingController());
  }
}
import 'package:book_app/module/book/readSetting/read_setting_controller.dart';
import 'package:get/get.dart';

class ReadSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ReadSettingController>(ReadSettingController());
  }

}

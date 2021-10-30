import 'package:book_app/module/setting/home/setting_home_controller.dart';
import 'package:get/get.dart';

class SettingHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SettingHomeController>(SettingHomeController());
  }

}
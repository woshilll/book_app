import 'package:book_app/module/book/readSetting/component/read_setting_config.dart';
import 'package:get/get.dart';

class ReadSettingController extends GetxController {

  late ReadSettingConfig config;
  @override
  void onInit() {
    super.onInit();
    config = Get.arguments["config"];
  }

  fontSizeAdd() {
    if (config.fontSize >= 30) {
      return;
    }
    config.fontSize = config.fontSize + 1;
    update(["setting"]);
  }

  fontSizeSub() {
    if (config.fontSize <= 10) {
      return;
    }
    config.fontSize = config.fontSize - 1;
    update(["setting"]);
  }

  void setColor(String selectColorHex, flag) {
    if (flag) {
      config.backgroundColor = selectColorHex;
    } else {
      config.fontColor = selectColorHex;
    }
    update(["setting"]);
  }

  void setDefault() {
    config = ReadSettingConfig.defaultConfig();
    update(["setting"]);
  }
}

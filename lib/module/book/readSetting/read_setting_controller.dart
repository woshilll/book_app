import 'package:book_app/module/book/read/read_controller.dart';
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
    if (config.fontSize >= 40) {
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

  fontWeightAdd() {
    if (config.fontWeight >= 8) {
      return;
    }
    config.fontWeight = config.fontWeight + 1;
    update(["setting"]);
  }

  fontWeightSub() {
    if (config.fontWeight <= 0) {
      return;
    }
    config.fontWeight = config.fontWeight - 1;
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
    ReadController readController = Get.find();
    var defaultConfig = ReadSettingConfig.defaultConfig();
    config = readController.isDark ? ReadSettingConfig.defaultDarkConfig(defaultConfig.fontSize, defaultConfig.fontHeight) : defaultConfig;
    update(["setting"]);
  }
}

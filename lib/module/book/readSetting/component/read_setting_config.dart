import 'package:book_app/model/base.dart';
import 'package:book_app/theme/theme.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ReadSettingConfig extends Base{
  String backgroundColor;
  double fontSize;
  String fontColor;
  double fontHeight;

  ReadSettingConfig(this.backgroundColor, this.fontSize, this.fontColor, this.fontHeight);

  static ReadSettingConfig defaultConfig() {
    return ReadSettingConfig("#FFF2E2", 20, "#000000", 2.5);
  }

  static ReadSettingConfig defaultDarkConfig(fontSize, fontHeight) {
    return ReadSettingConfig("#2F2E2E", fontSize, "#a9a9a9", fontHeight);
  }

  factory ReadSettingConfig.fromJson(Map<String, dynamic> json) => ReadSettingConfig(json["backgroundColor"], json["fontSize"], json["fontColor"], json["fontHeight"]??=1.8);
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'backgroundColor': backgroundColor,
    'fontSize': fontSize,
    'fontColor': fontColor,
    'fontHeight': fontHeight,
  };

  static List<String> getCommonBackgroundColors() {
    return ["#FAF9DE", "#FFF2E2", "#FDE6E0", "#E3EDCD", "#DCE2F1", "#E9EBFE"];
  }

}

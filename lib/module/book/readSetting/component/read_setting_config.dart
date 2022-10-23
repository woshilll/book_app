import 'package:book_app/model/base.dart';

class ReadSettingConfig extends Base{
  String backgroundColor;
  double fontSize;
  String fontColor;
  double fontHeight;
  int fontWeight;

  ReadSettingConfig(this.backgroundColor, this.fontSize, this.fontColor, this.fontHeight, this.fontWeight);

  static ReadSettingConfig defaultConfig() {
    return ReadSettingConfig("#FFF2E2", 20, "#000000", 2.5, 3);
  }

  static ReadSettingConfig defaultDarkConfig(fontSize, fontHeight) {
    return ReadSettingConfig("#2F2E2E", fontSize, "#a9a9a9", fontHeight, 3);
  }

  factory ReadSettingConfig.fromJson(Map<String, dynamic> json) => ReadSettingConfig(json["backgroundColor"], json["fontSize"], json["fontColor"], json["fontHeight"]??=1.8, json["fontWeight"]??=3);
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'backgroundColor': backgroundColor,
    'fontSize': fontSize,
    'fontColor': fontColor,
    'fontHeight': fontHeight,
    'fontWeight': fontWeight,
  };

  static List<String> getCommonBackgroundColors() {
    return ["#FAF9DE", "#FFF2E2", "#FDE6E0", "#E3EDCD", "#DCE2F1", "#E9EBFE"];
  }

}

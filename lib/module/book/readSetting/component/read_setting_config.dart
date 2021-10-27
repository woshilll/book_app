import 'package:book_app/model/base.dart';

class ReadSettingConfig extends Base{
  String backgroundColor;
  double fontSize;
  String fontColor;

  ReadSettingConfig(this.backgroundColor, this.fontSize, this.fontColor);

  static ReadSettingConfig defaultConfig() {
    return ReadSettingConfig("#FFF2E2", 20, "#000000");
  }

  factory ReadSettingConfig.fromJson(Map<String, dynamic> json) => ReadSettingConfig(json["backgroundColor"], json["fontSize"], json["fontColor"]);
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'backgroundColor': backgroundColor,
    'fontSize': fontSize,
    'fontColor': fontColor,
  };

  static List<String> getCommonBackgroundColors() {
    return ["#FAF9DE", "#FFF2E2", "#FDE6E0", "#E3EDCD", "#DCE2F1", "#E9EBFE"];
  }

  @override
  String toString() {
    return 'ReadSettingConfig{backgroundColor: $backgroundColor, fontSize: $fontSize, fontColor: $fontColor}';
  }
}

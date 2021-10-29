/// 字体工具
class FontUtil {
  /// 字符转全角
  static String alphanumericToFullLength(str) {
    var temp = str.codeUnits;
    final regex = RegExp(r'^[a-zA-Z0-9!,.@#$%^&*()@￥?]+$');
    final string = temp.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune + 65248) : char;
    });
    return string.join();
  }

  /// 字符转半角
  static String alphanumericToHalfLength(String str) {
    var runes = str.codeUnits;
    final regex = RegExp(r'^[Ａ-Ｚａ-ｚ０-９！，。￥？]+$');
    final string = runes.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune - 65248) : char;
    });
    return string.join();
  }
}

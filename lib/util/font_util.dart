import 'package:book_app/log/log.dart';

/// 字体工具
class FontUtil {
  /// 字符转全角
  static String alphanumericToFullLength(str) {
    var temp = str.codeUnits;
    //a-zA-Z0-9!,.@#$%^&*()@?;\u0022\u0027}{
    final regex = RegExp(r"^[\u0021-\u007E]+$");
    final string = temp.map<String>((rune) {
      final char = String.fromCharCode(rune);
      if (char == " ") {
        return "\u3000";
      }
      return regex.hasMatch(char) ? String.fromCharCode(rune + 65248) : char;
    });
    return string.join();
  }

  /// 字符转半角
  static String alphanumericToHalfLength(String str) {
    var runes = str.codeUnits;
    final regex = RegExp(r'^[\uFF01-\uFF5E]+$');
    final string = runes.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char) ? String.fromCharCode(rune - 65248) : char;
    });
    return string.join();
  }
}

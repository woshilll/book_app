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

  static String formatContent(String content) {
    if (content.isEmpty) {
      return content;
    }
    content = content.replaceAll(" ", "").replaceAll("\u3000", "").replaceAll("“", "\"").replaceAll("”", "\"");
    List<String> list = [];
    List<int> codes = content.codeUnits;
    for (int i = 0; i < codes.length; i++) {
      final char = String.fromCharCode(codes[i]);
      if (char != "\n") {
        list.add(char);
      } else {
        if (list.isNotEmpty) {
          if (list[list.length - 1].contains(" ")) {
            continue;
          }
        }
        list.add("\n  ");
      }
    }
    return list.join();
  }
}

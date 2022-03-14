import 'dart:io';
final RegExp chinese = RegExp(r"[\u4E00-\u9FA5]");
void main() {

  String text = File("F:\\workspace\\flutter\\book_app\\test\\compare.txt").readAsStringSync();
  print(_beautifulFormat(_beautyUnknownTag(_beautyNotes(_beautyScript(_beautyBr(_trim(text)))))));
} 
_formatContent(String content) {
  final String preFormat = content.replaceAll("&nbsp;", "").replaceAll("<br>", "\n").replaceAll(RegExp(r"<.*>.*|.*</.*>|.*<!.*>"), "").replaceAll(RegExp(r".*(www|http)+.*\n"), "");
  return _beautifulFormat(preFormat);
}
String _trim(String text) {
  return text.replaceAll("&nbsp;", "").replaceAll(" ", "");
}
String _beautyBr(String text) {
  return text.replaceAll("<br>", "\n");
}
String _beautyScript(String text) {
  return text.replaceAll(RegExp(r"<[a-zA-Z]+.*?>([\s\S]*?)</[a-zA-Z]+.*?>"), "");
}
String _beautyNotes(String text) {
  return text.replaceAll(RegExp(r"<!.*>"), "");
}
String _beautyUnknownTag(String text) {
  return text.replaceAll(RegExp(r"<\.*>|<.*>"), "");
}
_beautifulFormat(String str) {
  var strList = str.split('\n');
  List<String> newStr = [];
  for (var element in strList) {
    if (element.isEmpty) {
      continue;
    }
    if (chinese.allMatches(element).isEmpty) {
      continue;
    }
    if (element.contains("笔趣阁")) {
      continue;
    }
    newStr.add(element);
  }
  return newStr.join('\n').trim();
}
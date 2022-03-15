import 'dart:io';

import 'package:book_app/api/http_manager.dart';
import 'package:book_app/util/html_parse_util.dart';
final RegExp chinese = RegExp(r"[\u4E00-\u9FA5]");
void main() async{
  HttpManager.getInstance();
  print(await HtmlParseUtil.parseContent("https://m.biquluo.com/wapbook/66266_28977518.html"));
} 

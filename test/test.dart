import 'dart:io';

import 'package:book_app/log/log.dart';
import 'package:book_app/util/html_parse_util.dart';

void main() async{
  final RegExp nextPageReg = RegExp(r"下[1一]?页");
  Log.i("页".contains(nextPageReg));
}

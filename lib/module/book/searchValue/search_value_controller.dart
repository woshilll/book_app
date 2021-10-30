import 'package:book_app/api/book_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/search/search_history.dart';
import 'package:book_app/model/search/search_result.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchValueController extends GetxController {
  late SearchHistory site;
  List<SearchResult> searchResults = [];

  @override
  void onInit() async {
    super.onInit();
    var map = Get.arguments;
    site = map["site"];
  }

  @override
  void onReady() async {
    super.onReady();
    searchResults = await BookApi.getSearchResults(site.label, site.site);
    update(["result"]);
  }

  Widget buildRichText(str, double fontSize, FontWeight fontWeight) {
    List<ValueFormat> lines = [];
    int index = 0;
    while (index + 7 < str.length) {
      index = str.indexOf("<strong>");
      if (index == -1) {
        lines.add(ValueFormat(str, false));
        break;
      }
      String content = str.substring(0, index);
      if (content.isNotEmpty) {
        lines.add(ValueFormat(content, false));
      }
      str = str.substring(index + 8);
      index = str.indexOf("</strong>");
      String content2 = str.substring(0, index);
      lines.add(ValueFormat(content2, true));
      str = str.substring(index + 9);
    }
    if (str.isNotEmpty) {
      lines.add(ValueFormat(str, false));
    }
    return Text.rich(TextSpan(
        children: List.generate(lines.length, (i) {
      if (lines[i].red) {
        return TextSpan(
            text: lines[i].content, style: TextStyle(color: Colors.red, fontSize: fontSize, fontWeight: fontWeight));
      }
      return TextSpan(
        text: lines[i].content,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: Theme.of(globalContext).textTheme.bodyText1!.color)
      );
    })));
  }
}

class ValueFormat {
  String content;
  bool red;

  ValueFormat(this.content, this.red);
}

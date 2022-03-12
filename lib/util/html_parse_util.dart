import 'dart:io';

import 'package:book_app/model/chapter/chapter.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fast_gbk/fast_gbk.dart';

class HtmlParseUtil {
  static final List<String> ignoreContentHtmlTag = ["a", "option", "h1", "h2", "strong", "font", "button", "script"];
  static final RegExp chinese = RegExp(r"[\u4E00-\u9FA5]");
  static Future<List<Chapter>> parseChapter(String url) async{
    String originUrl = url;
    if (url.contains("m.")) {
      url = url.replaceFirst("m.", "www.");
    }
    if (url.contains("all.html")) {
      url = url.replaceAll("all.html", "");
    }
    Document document = parse(await getFileString(url, originUrl: originUrl));
    var body = document.body;
    var aTags = body?.getElementsByTagName("a");
    Map<String, List<Map<String, dynamic>>> parseMap = {};
    int index = 0;
    for (int i = 0; i < aTags!.length; i++) {
      var aTag = aTags[i];
      Map<String, dynamic> chapter = {};
      if (!aTag.attributes.containsKey("href")) {
        continue;
      }
      String src = aTag.attributes["href"]!;
      if (skip(src)) {
        continue;
      }
      String title = aTag.text;
      chapter["url"] = src;
      chapter["name"] = title;
      String prefix = parseSrcPrefix(src);
      if (prefix == "") {
        continue;
      }
      chapter["index"] = index;
      index = index + 1;
      if (parseMap.containsKey(prefix)) {
        List<Map<String, dynamic>> chapters = parseMap[prefix]!;
        chapters.removeWhere((element) => element["name"] == chapter["name"]);
        chapters.add(chapter);
        parseMap[prefix] = chapters;
      } else {
        List<Map<String, dynamic>> chapters = [];
        chapters.add(chapter);
        parseMap[prefix] = chapters;
      }
    }
    String maxKey = "";
    int maxValue = 0;
    parseMap.forEach((key, value) {
      if (value.length > maxValue) {
        maxValue = value.length;
        maxKey = key;
      }
    });
    List<Map<String, dynamic>> trueChapters = parseMap[maxKey]!;
    return format(trueChapters, url);
  }
  static bool skip(String url) {
    return url.endsWith("/") || url.endsWith(".php") || url.endsWith(".js") || url.endsWith(".css");
  }

  static String parseSrcPrefix(String src) {
    // 以 '/' 或者不带 '/'开头如 xxxx/xxx.htm这种大概率是的
    if (src.startsWith("/")) {
      if (!src.contains("/", 1)) {
        if (src.endsWith(".html") || src.endsWith(".htm")) {
          return "/" + src.substring(src.lastIndexOf("."));
        } else {
          return "";
        }
      }
      return src.substring(0, src.indexOf("/", 1));
    } else if (src.startsWith("https")) {
      if (!src.contains("/", 8)) {
        return "";
      }
      return src.substring(0, src.indexOf("/", 8));
    } else if (src.startsWith("http")) {
      if (!src.contains("/", 7)) {
        return "";
      }
      return src.substring(0, src.indexOf("/", 7));
    } else {
      // 大概率是xxx.? 或xxx/xxx.?开头
      if (src.indexOf("/") > 0) {
        // xxx/xxx.?开头
        return src.substring(0, src.indexOf("/"));
      } else {
        // xxx.?开头 通常是.html结尾
        if (src.endsWith(".html") || src.endsWith(".htm")) {
          return src.substring(src.lastIndexOf("."));
        }
      }
    }
    return "";
  }
  static Map<String, String> headers() {
    return {
      "Accept": "text/html;charset=UTF-8",
      "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
      "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/96.0.4664.110",
    };
  }

  static List<Chapter> format(List<Map<String, dynamic>> chapters, String url) {
    String childUrl = chapters[0]["url"];
    if (childUrl.startsWith("/")) {
      Uri uri = Uri.parse(url);
      url = uri.origin;
    }
    if (childUrl.startsWith("http") || childUrl.startsWith("www")) {
      url = "";
    }
    List<Chapter> returnChapters = [];
    for (var element in chapters) {
      returnChapters.add(Chapter(name: element["name"], url: url + element["url"]));
    }
    return returnChapters;
  }


  static parseContent(String url) async{
    try {
      Document document = parse(await getFileString(url));
      var body = document.body;
      List<Element> elements = [];
      getElement(elements, body!);
      String content = findMaxChineseContent(elements);
      if (content.isEmpty) {
        return;
      }
      return _formatContent(content);
    } catch(err) {
      Log.e(url);
    }
  }
  static getElement(List<Element> elements, Element parent) {
    if (ignoreContentHtmlTag.contains(parent.localName)) {
      return;
    }
    if (parent.children.isEmpty && parent.innerHtml.trim().isNotEmpty) {
      elements.add(parent);
      return;
    }

    List<Element> children = parent.children;
    int flag = 0;
    for (var child in children) {
      if (child.children.isEmpty || child.innerHtml.trim().isEmpty) {
        flag++;
      } else {
        flag = 0;
      }
      if (flag >= 3) {
        elements.add(parent);
        return;
      }
      getElement(elements, child);
    }
  }

  static String findMaxChineseContent(List<Element> elements) {
    String returnContent = "";
    int max = 0;
    for (var element in elements) {
      var content = element.innerHtml;
      var allMatch = chinese.allMatches(content);
      if (allMatch.length > max) {
        returnContent = content;
        max = allMatch.length;
      }
    }
    return returnContent;
  }

  static _formatContent(String content) {
    final String preFormat = content.replaceAll("&nbsp;", "").replaceAll("<br>", "\n").replaceAll(RegExp(r"<.*>.*|.*</.*>|.*<!.*>"), "").replaceAll(RegExp(r".*(www|http)+.*\n"), "");
    return _beautifulFormat(preFormat);
  }

  static getFileString(String url, {String? originUrl}) async{
    File file = File(await getFilePath(url, originUrl: originUrl));
    try {
      return file.readAsStringSync();
    } catch(err) {
      String res = gbk.decode(file.readAsBytesSync());
      return res;
    }
  }
  static getFilePath(String url, {String? originUrl}) async{
    var dir = await getExternalStorageDirectory();
    String filePath = "${dir!.path}/book/temp.txt";
    try {
      await DioManager.instance.download(url, filePath);
      return filePath;
    } catch(err) {
      if (originUrl != null) {
        await DioManager.instance.download(originUrl, filePath);
        return filePath;
      } else {
        rethrow;
      }
    }
  }

  static _beautifulFormat(String str) {
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
}
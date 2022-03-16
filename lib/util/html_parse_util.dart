import 'dart:convert';

import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/util/content_fliter.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:book_app/api/http_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:fast_gbk/fast_gbk.dart';
final RegExp chinese = RegExp(r"[\u4E00-\u9FA5]");
final RegExp contentFilter = contentFilterRegExp();
final RegExp nextPageReg = RegExp("下(.{1})页");
class HtmlParseUtil {
  static final List<String> ignoreContentHtmlTag = ["a", "option", "h1", "h2", "strong", "font", "button", "script"];
  static Future<List<Chapter>> parseChapter(String url, {Function(String? url)? img}) async{
    Document document = parse(await getFileString(url));
    var body = document.body;
    if (img != null) {
      var imgs = document.getElementsByTagName("img");
      if (imgs.isNotEmpty) {
        for (var imgE in imgs) {
          String? _uri = imgE.attributes['src'];
          if (_uri != null && (_uri.endsWith("jpg") || _uri.endsWith("jpeg") || _uri.endsWith("png"))) {
            if (_uri.startsWith("/")) {
              _uri = Uri.parse(url).origin + _uri;
            }
            img(_uri);
            break;
          }
        }
      }
    }
    List res = await _getChapterAllTags(body!, url);
    var aTags = res[1];
    url = res[0];
    Map<String, List<Map<String, dynamic>>> parseMap = {};
    int index = 0;
    for (int i = 0; i < aTags.length; i++) {
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


  static Future<String> parseContent(String url, {String? originPageId}) async{
    try {
      var html = await getFileString(url);
      Document document = parse(html);
      var body = document.body;
      List<Element> elements = [];
      getElement(elements, body!);
      Element? contentElement = findMaxChineseElement(elements);
      if (contentElement == null) {
        return "";
      }
      // 有没有下一页
      String content = contentElement.innerHtml;
      for (var a in contentElement.getElementsByTagName("a")) {
        if (a.text.contains(nextPageReg)) {
          String? nextPageUrl = a.attributes["href"];
          nextPageUrl = url.substring(0, url.lastIndexOf("/")) + nextPageUrl!.substring(nextPageUrl.lastIndexOf('/'));
          originPageId ??= url.substring(url.lastIndexOf('/') + 1).split(".")[0];
          String nextPageId = nextPageUrl.substring(nextPageUrl.lastIndexOf('/') + 1).split(".")[0];
          if (!nextPageId.contains(originPageId)) {
            break;
          }
          var nextPageContent = await parseContent(nextPageUrl, originPageId: originPageId);
          content += nextPageContent;
          break;
        }
      }
      return _beautifulFormat(_beautyUnknownTag(_beautyNotes(_beautyScript(_beautyBrAndP(_trim(content))))));
    } catch(err) {
      Log.e(err);
      return "";
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

  static Element? findMaxChineseElement(List<Element> elements) {
    Element? returnElement;
    int max = 0;
    for (var element in elements) {
      var content = element.innerHtml;
      var allMatch = chinese.allMatches(content);
      if (allMatch.length > max) {
        returnElement = element;
        max = allMatch.length;
      }
    }
    return returnElement;
  }


  static getFileString(String url) async{
    Log.i("发起请求 --- $url");
    return await getString(url);
  }
  static Future<String?> getString(String url) async{
    var request = await HttpManager.httpClient!.getUrl(Uri.parse(url));
    request.headers.add("Accept", "text/html;charset=UTF-8");
    request.headers.add("User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1 Edg/96.0.4664.110");
    var response = await request.close();
    List<List<int>> dataBytes = await response.toList();
    return decodeToStr(dataBytes);
  }

  static String decodeToStr(List<List<int>> dataBytes) {
    try{
      return utf8Decode(dataBytes);
    }catch(_) {
      return gbkDecode(dataBytes);
    }
  }

  static String utf8Decode(List<List<int>> dataBytesList) {
    List<int> dataBytes = [];
    for (var value in dataBytesList) {
      dataBytes.addAll(value);
    }
    return utf8.decode(dataBytes);
  }

  static String gbkDecode(List<List<int>> dataBytesList) {
    List<int> dataBytes = [];
    for (var value in dataBytesList) {
      dataBytes.addAll(value);
    }
    return gbk.decode(dataBytes);
  }

  /// 获取所有的章节
  static Future<List<dynamic>> _getChapterAllTags(Element body, String url) async{
    var aTags = body.getElementsByTagName("a");
    for (var a in aTags) {
      if (a.text.contains("章节列表") || a.text.contains("目录") || a.text.contains("电脑版")) {
        String? fullUrl = a.attributes["href"];
        if (fullUrl != null) {
          if (fullUrl.startsWith("/")) {
            fullUrl = Uri.parse(url).origin + fullUrl;
          }
          var html = await getFileString(fullUrl);
          Document document = parse(html);
          return [fullUrl, document.body!.getElementsByTagName("a")];
        }
      }
    }
    return [url, body.getElementsByTagName("a")];
  }
}

String _trim(String text) {
  return text.replaceAll("&nbsp;", "").replaceAll(" ", "");
}
String _beautyBrAndP(String text) {
  return text.replaceAll("<br>", "\n")
      .replaceAll("<p>", "").replaceAll("</p>", "")
    .replaceAll(RegExp(r"<div.*>"), "")
    .replaceAll("</div>", "")
  ;
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
String _beautifulFormat(String str) {
  var strList = str.split('\n');
  List<String> newStr = [];
  for (var element in strList) {
    if (element.isEmpty) {
      continue;
    }
    if (chinese.allMatches(element).isEmpty) {
      continue;
    }
    if (element.contains(contentFilter)) {
      continue;
    }
    newStr.add(element);
  }
  return newStr.join('\n').trim();
}
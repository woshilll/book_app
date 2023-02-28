import 'dart:convert';
import 'dart:io';

import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/message.dart';
import 'package:book_app/util/content_fliter.dart';
import 'package:book_app/util/random_user_agent.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:book_app/api/http_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:fast_gbk/fast_gbk.dart';
final RegExp chinese = RegExp(r"[\u4E00-\u9FA5]");
final RegExp contentFilter = contentFilterRegExp();
final RegExp nextPageReg = RegExp(r"下[1一]?页");
class HtmlParseUtil {
  static final List<String> ignoreContentHtmlTag = ["a", "option", "h1", "h2", "strong", "font", "button", "script"];
  static Future<List<dynamic>> parseChapter(String url, {Function(String? url)? img, Function(String name)? name, Function(int page)? pageFunc, String? originUrl, int page = 1}) async{
    Document document = parse(await getFileString(url));
    var body = document.body;
    if (img != null) {
      var imgs = document.getElementsByTagName("img");
      if (imgs.isNotEmpty) {
        for (var imgE in imgs) {
          String? _uri = imgE.attributes['src'];
          String? _width = imgE.attributes['width'];
          String? _height = imgE.attributes['height'];
          if (_uri != null && _width != null && _height != null) {
            if (_uri.startsWith("/")) {
              _uri = Uri.parse(url).origin + _uri;
            }
            img(_uri);
            break;
          }
        }
      }
    }
    if (name != null) {
      var _h1S = document.getElementsByTagName("h1");
      String? _bookName;
      if (_h1S.isNotEmpty) {
        _bookName = _h1S.first.text;
      }
      name(_bookName ?? "网络小说");
    }
    List res = await _getChapterAllTags(body!);
    var aTags = res;
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
    var chapters = format(trueChapters, originUrl ?? url);
    for (var a in aTags) {
      if (a.text.contains(nextPageReg)) {
        String? nextPageUrl = a.attributes["href"];
        if (nextPageUrl == null || nextPageUrl == "javascript:") {
          break;
        }
        // nextPageUrl = url.substring(0, url.lastIndexOf("/")) + nextPageUrl.substring(nextPageUrl.lastIndexOf('/'));
        nextPageUrl = _getNextPageUrl(url, nextPageUrl);
        originUrl ??= url;
        if (pageFunc != null) {
          pageFunc(page);
        }
        await Future.delayed(const Duration(milliseconds: 1500));
        var nextPageData = await parseChapter(nextPageUrl, originUrl: originUrl, page: page + 1, pageFunc: pageFunc);
        chapters.addAll(nextPageData[1]);
        break;
      }
    }
    return [originUrl ?? url, chapters];
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
    Uri uri = Uri.parse(url);
    if (childUrl.startsWith("//")) {
      url = uri.scheme + ":";
    } else if (childUrl.startsWith("/")) {
      url = uri.origin;
    } else if (childUrl.startsWith("http") || childUrl.startsWith("www")) {
      url = "";
    } else {
      if (!url.endsWith("/")) {
        url = url.substring(0, url.lastIndexOf("/") + 1);
      }
    }
    List<Chapter> returnChapters = [];
    RegExp chapterMatch = RegExp(r"^第.*章|^\d+$");
    for (var element in chapters) {
      var name = element["name"] as String;
      if (name.contains(RegExp("(正序)|(倒序)|(首页)|(尾页)|(上一页)|(下一页)"))) {
        if (!chapterMatch.hasMatch(name)) {
          continue;
        }
      }
      returnChapters.add(Chapter(name: element["name"].trim(), url: url + element["url"]));
    }
    return returnChapters;
  }


  static Future<String> parseContent(String chapterName, String url, String? nextChapterUrl, {String? originPageId, int maxPage = 0}) async{
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
      if (!content.contains("<br>")) {
        content = contentElement.parent!.innerHtml;
      }
      // 最多应该有10页
      for (var a in body.getElementsByTagName("a")) {
        if (maxPage >= 10) {
          break;
        }
        if (a.text.contains(nextPageReg)) {
          String? nextPageUrl = a.attributes["href"];
          if (nextPageUrl == null) {
            break;
          }
          nextPageUrl = _getNextPageUrl(url, nextPageUrl);
          originPageId ??= url;
          if (nextChapterUrl != null && nextChapterUrl.isNotEmpty) {
            if (nextPageUrl.contains(nextChapterUrl) || nextPageUrl == nextChapterUrl) {
              break;
            }
          }
          await Future.delayed(const Duration(milliseconds: 1500));
          var nextPageContent = await parseContent(chapterName, nextPageUrl, nextChapterUrl,originPageId: originPageId, maxPage: maxPage + 1);
          content += nextPageContent;
          break;
        }
      }
      return _removeChapterName(chapterName, _beautifulFormat(_beautyUnknownTag(_beautyNotes(_beautyScript(_beautyBrAndP(_trim(content)))))));
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
      var content = element.innerHtml.replaceAll(RegExp(r"<a+.*?>([\s\S]*?)</a>"), "");
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
    var res = await getString(url);
    return res;
  }
  static Future<String?> getString(String url, {bool retry = false, int retryTimes = 0}) async{
    // var client = retry ? HttpClient() : HttpManager.httpClient!;
    var client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
    try {
      var request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 10));
      request.headers.remove("User-Agent", "Dart/2.16 (dart:io)");
      request.headers.add("Accept", "text/html;charset=UTF-8");
      request.headers.add("content-type", "text/html; charset=utf-8");
      request.headers.add("User-Agent", randomUserAgent());
      var response = await request.close().timeout(const Duration(seconds: 10));
      List<List<int>> dataBytes = await response.toList();
      return decodeToStr(dataBytes);
    } catch(e) {
      if (retryTimes > 0) {
        rethrow;
      }
      await Future.delayed(const Duration(milliseconds: 1500));
      return await getString(url, retry: true, retryTimes: retryTimes + 1);
    }
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
  static Future<List<dynamic>> _getChapterAllTags(Element body) async{
    return body.getElementsByTagName("a");
  }

  static String _removeChapterName(String chapterName, String beautifulFormat) {
    try {
      chapterName = chapterName.replaceAll(" ", "");
      return beautifulFormat.replaceAll(RegExp(".*$chapterName.*"), "");
    } catch(_) {
      return beautifulFormat;
    }
  }

  static String _getNextPageUrl(String url, String nextPageUrl) {
    var uri = Uri.parse(url);
    /// //aaa/cvvv
    if (nextPageUrl.startsWith("//")) {
      return uri.scheme + ":" + nextPageUrl;
    }
    /// /aaa/cvvv
    if (nextPageUrl.startsWith("/")) {
      return uri.origin + nextPageUrl;
    }
    /// http://aaa/cvvv
    if (nextPageUrl.startsWith("http")) {
      return nextPageUrl;
    }
    if (nextPageUrl.startsWith("www")) {
      return uri.scheme + ":" + "//" + nextPageUrl;
    }
    if (!url.endsWith("/")) {
      url += "/";
    }
    return url + nextPageUrl;
  }
}

String _trim(String text) {
  return text
      .replaceAll("&nbsp;", "")
      .replaceAll("&gt;", "")
      .replaceAll(" ", "");
}
String _beautyBrAndP(String text) {
  return text.replaceAll(RegExp(r"<p[^>]*>"), "")
      .replaceAll("</p>", "<br>").replaceAll(RegExp(r"<div[^>]*>"), "")
    .replaceAll(RegExp(r"<span[^>]*>"), "").replaceAll("</div>", "")
    .replaceAll("</span>", "<br>").replaceAll("<br>", "\n")
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
    var match = chinese.allMatches(element);
    if (match.isEmpty || match.length <= 1) {
      continue;
    }
    if (element.contains(contentFilter)) {
      continue;
    }
    newStr.add(element.replaceAll(" ", "").replaceAll("\u3000", ""));
  }
  return newStr.join('\n').trim();
}
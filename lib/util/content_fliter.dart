/// 需要过滤的词汇
List<String> _contentFilter() {
  return [
    "笔趣阁",
    "小说网",
    "书屋",
    "首页",
    "上一页",
    "下一页",
    "上一章",
    "下一章",
    "加入书签",
    "投票推荐",
    "目录",
    "手机版",
    "推荐阅读"
  ];
}

String _contentRStr() {
  List<String> rStr = [];
  for (var value in _contentFilter()) {
    rStr.add("($value)");
  }
  return rStr.join("|");
}
RegExp contentFilterRegExp() {
  return RegExp(_contentRStr());
}
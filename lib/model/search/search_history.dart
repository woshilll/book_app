import 'dart:convert' as convert;

import 'package:book_app/model/base.dart';

class SearchHistory extends Base{
  String? label;
  String? site;

  SearchHistory({this.label, this.site});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'site': site,
  };
  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(site: json["site"], label: json["label"]);
  static List<SearchHistory> fromList(List<String>? data) {
    List<SearchHistory> res = [];
    if (data == null) {
      return res;
    }
    for (var value in data) {
      res.add(SearchHistory.fromJson(convert.jsonDecode(value)));
    }
    return res;
  }

  @override
  String toString() {
    return 'SearchHistory{label: $label, site: $site}';
  }
}
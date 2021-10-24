import 'dart:convert' as convert;

import 'package:book_app/model/base.dart';

class SearchResult extends Base{
  String? label;
  String? url;
  String? description;


  SearchResult({this.label, this.url, this.description});

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'url': url,
    'description': description,
  };
  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(url: json["url"], label: json["label"], description: json["description"]);
  static List<SearchResult> fromList(List<String>? data) {
    List<SearchResult> res = [];
    if (data == null) {
      return res;
    }
    for (var value in data) {
      res.add(SearchResult.fromJson(convert.jsonDecode(value)));
    }
    return res;
  }

  @override
  String toString() {
    return 'SearchResult{label: $label, url: $url, description: $description}';
  }
}
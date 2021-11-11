import 'package:book_app/model/chapter/chapter.dart';
import 'package:flutter/material.dart';
class ContentPage {
  String content;
  TextStyle style;
  int index;
  int? chapterId;
  String? chapterName;
  double width;
  bool noContent;

  ContentPage(this.content, this.style, this.index, this.chapterId, this.chapterName, this.width, {this.noContent = false});

}


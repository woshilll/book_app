import 'package:flutter/material.dart';

class ContentPage {
  String content;
  int index;
  int? chapterId;
  String? chapterName;
  double width;
  double height;
  bool noContent;
  TextStyle textStyle;

  ContentPage(this.content, this.index, this.chapterId, this.chapterName, this.width, this.height, this.textStyle, {this.noContent = false});

}


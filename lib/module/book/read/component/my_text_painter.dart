import 'package:book_app/module/book/read/component/content_page.dart';
import 'package:flutter/material.dart';

class MyTextPainter extends CustomPainter {
  final TextPainter _painter;
  final ContentPage contentPage;


  MyTextPainter(this._painter, this.contentPage);
  @override
  void paint(Canvas canvas, Size size) {
    _painter.text = TextSpan(
      text: contentPage.content,
      style: contentPage.textStyle
    );
  }

  @override
  bool shouldRepaint(covariant MyTextPainter oldDelegate) {
    return contentPage.index != oldDelegate.contentPage.index;
  }

}
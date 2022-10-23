import 'package:book_app/model/book/book.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/module/book/read/component/content_gen.dart';
import 'package:book_app/module/book/readSetting/component/read_setting_config.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';

import 'content_page.dart';

class PageGen{
  final TextPainter _painter = TextPainter(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.ltr,
      locale: WidgetsBinding.instance.window.locale,
      textScaleFactor: MediaQuery.of(globalContext).textScaleFactor,
      textWidthBasis: TextWidthBasis.longestLine
  );
  late TextStyle _contentStyle;
  late double _screenWidth;
  late double _titleHeight;
  late double _screenHeight;
  late double _screenTop;
  late double _screenBottom;
  late double _wordHeight;
  final double _paddingWidth = 40;
  late double _screenLeft;
  late double _screenRight;
  final TextStyle _titleStyle = const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold);

  PageGen(ReadSettingConfig readSettingConfig) {
    _contentStyle = _readSettingConfigToTextStyle(readSettingConfig);
    _initSize();
  }

  TextStyle _readSettingConfigToTextStyle(ReadSettingConfig readSettingConfig) {
    return TextStyle(
        color: hexToColor(readSettingConfig.fontColor),
        fontSize: readSettingConfig.fontSize,
        height: readSettingConfig.fontHeight,
        fontWeight: FontUtil.intToFontWeight(readSettingConfig.fontWeight),
        fontFamily: FontUtil.getFontFamily());
  }


  Future<List<ContentPage>> genPages(Chapter chapter, Book book, Function(List<ContentPage>)? finishFunc) async{
    await contentGen(chapter, book);
    List<ContentPage> list = await _genPages(chapter);
    if (finishFunc != null) {
      finishFunc(list);
    }
    return list;
  }

  Future<List<ContentPage>> _genPages(Chapter chapter) async {
    List<ContentPage> list = [];
    _calTitleHeight(chapter.name);
    _calWordHeightAndWidth();
    int maxLines = _calMaxLines(firstPage: true);
    String content = chapter.content??"";
    if (content.isEmpty) {
      list.add(
          ContentPage("", 1, chapter.id, chapter.name, _contentWidth(), noContent: true));
      return list;
    }
    _painter.text = TextSpan(text: content, style: _contentStyle);
    _painter.maxLines = maxLines;
    // 统计第一页字符偏移量
    _painter.layout(maxWidth: _contentWidth());
    double paintWidth = _painter.width;
    double paintHeight = _painter.height;
    int offset =
        _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    // 得到第一页偏移量
    int i = 1;
    do {
      String subContent = content.substring(0, offset);
      list.add(
          ContentPage(subContent, i, chapter.id, chapter.name, _contentWidth()));
      i++;
      if (i == 2) {
        maxLines = _calMaxLines();
      }
      content = content.substring(offset);
      if (content.startsWith("\n")) {
        content = content.substring(1);
      }
      _painter.text = TextSpan(text: content, style: _contentStyle);
      _painter.maxLines = maxLines;
      _painter.layout(maxWidth: _contentWidth());
      paintWidth = _painter.width;
      paintHeight = _painter.height;
      offset =
          _painter.getPositionForOffset(Offset(paintWidth, paintHeight)).offset;
    } while (offset < content.characters.length && content.trim().isNotEmpty);
    if (offset > 0 && content.trim().isNotEmpty) {
      list.add(
          ContentPage(content, i, chapter.id, chapter.name, _contentWidth()));
    }
    return list;
  }



  changeContentStyle(ReadSettingConfig readSettingConfig) {
    _contentStyle = _readSettingConfigToTextStyle(readSettingConfig);
  }




  _calTitleHeight(String? title) {
    _painter.text = TextSpan(text: title, style: _titleStyle);
    _painter.layout(maxWidth: _screenWidth);
    var cal = _painter.computeLineMetrics()[0];
    _titleHeight = cal.height;
  }
  double _contentWidth() {
    return _screenWidth - _paddingWidth - _screenLeft - _screenRight;
  }

  void _initSize() {
    MediaQueryData data = MediaQuery.of(globalContext);
    _screenWidth = data.size.width;
    _screenHeight = data.size.height;
    _screenLeft = data.padding.left;
    _screenRight = data.padding.right;
    _screenBottom = 16;
    double top = data.padding.top;
    if (top < 33) {
      top = 33;
    }
    _screenTop = top;
  }

  /// 计算词宽和词高
  _calWordHeightAndWidth() {
    _painter.text = TextSpan(text: "哈", style: _contentStyle);
    _painter.layout(maxWidth: 100);
    var cal = _painter.computeLineMetrics()[0];
    _wordHeight = cal.height;
  }

  int _calMaxLines({bool firstPage = false}) {
    double extend = 0;
    if (firstPage) {
      extend = _titleHeight;
    }
    double _remainHeight = (_screenHeight -
        _screenTop - _screenBottom - extend) %
        _wordHeight;
    if (_remainHeight < (_wordHeight / 2)) {
      _remainHeight = _wordHeight / 2;
    }
    return (_screenHeight -
        _screenTop - _screenBottom - extend - (_remainHeight ~/ 1)) ~/
        _wordHeight;
  }

  void heightWidthSwap([bool flag = false]) {
    double temp = _screenHeight;
    _screenHeight = _screenWidth;
    _screenWidth = temp;
    if (flag) {
      _screenLeft = _screenTop;
      _screenRight = _screenTop;
    } else {
      _screenLeft = 0;
      _screenRight = 0;
    }
  }

  double get screenRight => _screenRight;

  double get screenLeft => _screenLeft;

  double get paddingWidth => _paddingWidth;

  double get wordHeight => _wordHeight;

  double get screenBottom => _screenBottom;

  double get screenTop => _screenTop;

  double get screenHeight => _screenHeight;

  double get titleHeight => _titleHeight;

  double get screenWidth => _screenWidth;

  TextStyle get contentStyle => _contentStyle;
  TextStyle get titleStyle => _titleStyle;
}
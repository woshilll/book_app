
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_quill/flutter_quill.dart';

///富文本编辑器主题
class QuillTheme {
  static DefaultStyles getDefaultStyle(BuildContext context) {
    return DefaultStyles(
      /// 正文
      paragraph: DefaultTextBlockStyle(
          Theme.of(context).textTheme.bodyText1!,
          const Tuple2(0, 0),
          const Tuple2(0, 0),
          null
      ),
      h1: DefaultTextBlockStyle(
          Theme.of(context).textTheme.headline1!,
          const Tuple2(0, 0),
          const Tuple2(0, 0),
          null
      ),
      h2: DefaultTextBlockStyle(
          Theme.of(context).textTheme.headline3!,
          const Tuple2(0, 0),
          const Tuple2(0, 0),
          null
      ),
      h3: DefaultTextBlockStyle(
          Theme.of(context).textTheme.headline5!,
          const Tuple2(0, 0),
          const Tuple2(0, 0),
          null
      ),
    );
  }

  static QuillIconTheme getIconTheme(BuildContext context) {
    return QuillIconTheme(iconSelectedColor: Theme.of(context).primaryColor, iconUnselectedColor: Colors.grey, iconSelectedFillColor: Colors.transparent, iconUnselectedFillColor: Colors.transparent);
  }
}
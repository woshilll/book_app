import 'package:book_app/theme/color.dart';
import 'package:flutter/material.dart';

class DialogBuild extends StatelessWidget {
  final String title;
  final String cancelText;
  final String confirmText;
  final Widget body;
  final Function? cancelFunction;
  final Function? confirmFunction;

  const DialogBuild(this.title, this.body, {Key? key, this.cancelText = "取消", this.confirmText = "确定", this.cancelFunction, this.confirmFunction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: textColor()),),
      backgroundColor: backgroundColorL2(),
      titlePadding: const EdgeInsets.all(10),
      titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      content: body,
      contentPadding: const EdgeInsets.all(10),
      //中间显示内容的文本样式
      contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      actions: [
        ElevatedButton(
          child: Text(cancelText, style: TextStyle(color: textColor()),),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(backgroundColor())
          ),
          onPressed: () {
            if (cancelFunction != null) {
              cancelFunction!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        ElevatedButton(
          child: Text(confirmText, style: TextStyle(color: textColor()),),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(backgroundColor())
          ),
          onPressed: () {
            if (confirmFunction != null) {
              confirmFunction!();
            } else {
              Navigator.of(context).pop();
            }
          },
        )
      ],
    );
  }

}
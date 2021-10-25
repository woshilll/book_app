import 'package:book_app/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextPaint extends CustomPainter {
  String str;
  SplashController controller = Get.find();
  TextPaint(this.str);
  @override
  void paint(Canvas canvas, Size size) {
    double height = 0;
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
        text: str[0],
        style: const TextStyle(fontSize: 30, color: Colors.red)
    );
    painter.layout();
    var cal = painter.computeLineMetrics()[0];
    height = cal.height;
    double startHeight = (MediaQuery.of(controller.context).size.height - (height * str.length)) / 2;
    for (int i = 0; i < str.length; i++) {
      painter.text = TextSpan(
        text: str[i],
        style: const TextStyle(fontSize: 30, color: Colors.red)
      );
      painter.layout();
      painter.paint(canvas, Offset(20, startHeight + (i * height)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}

import 'dart:ui';

import 'package:book_app/log/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import '../serach_controller.dart';

class ContentPaint extends CustomPainter {
  final TextPainter _painter = TextPainter(textDirection: TextDirection.ltr);
  SearchController controller = Get.find();
  @override
  Future<void> paint(Canvas canvas, Size size)  async {
    canvas.drawColor(Colors.orange, BlendMode.color);
    _painter.text = TextSpan(
      text: controller.alphanumericToFullLength(controller.text),
      style: const TextStyle(color: Colors.green, fontSize: 16)
    );
    _painter.maxLines = 35;
    _painter.layout(maxWidth: MediaQuery.of(controller.context).size.width);
    var temp = _painter.computeLineMetrics();
    Log.i(MediaQuery.of(controller.context).size.height);
    Log.i((MediaQuery.of(controller.context).size.height - MediaQuery.of(controller.context).padding.top) / 23);
    _painter.paint(canvas, Offset(MediaQuery.of(controller.context).size.width % 22 / 2, MediaQuery.of(controller.context).padding.top));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


  Future<ui.Image> getAssetImage(String asset,{width,height}) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetWidth: 		width,targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }


}

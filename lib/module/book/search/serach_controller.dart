import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

class SearchController extends GetxController {
  late BuildContext context;
  late ui.Image image;
  String text = "看见\n萨\n迪克\n撒开\n的卡\n萨丁\n开始\n看你\n好呀a\najid\naidai！……%\n&#@*（看\n见萨\n迪克撒\n开的\n卡萨\n丁开\n始\n看你\n好呀ji\ndaid\nai！…\n…%&#@\n*（看见"
      "萨\n迪克\n撒开\n的卡萨\n丁开始\n看你\n好呀jidai\ndai！……%&#@*\n（看见\n萨迪\n克撒\n开的\n卡萨丁\n开始看\n你好呀jida\nidai！……%\n&#@*（看\n见萨\n迪克\n撒开的卡萨丁开\n始看\n你好";
  //返回ui.Image
  Future<ui.Image> getAssetImage(String asset,{width,height}) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetWidth: 		width,targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    image = await getAssetImage("asset/image/1.jpg");
  }

  String alphanumericToFullLength(String str) {
    var temp = str.codeUnits;
    final regex = RegExp(r'^[a-zA-Z0-9!,.@#$%^&*()@￥?]+$');
    final string = temp.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char)
          ? String.fromCharCode(rune + 65248)
          : char;
    });
    return string.join();
  }
  String alphanumericToHalfLength(String str) {
    var runes = str.codeUnits;
    final regex = RegExp(r'^[Ａ-Ｚａ-ｚ０-９]+$');
    final string = runes.map<String>((rune) {
      final char = String.fromCharCode(rune);
      return regex.hasMatch(char)
          ? String.fromCharCode(rune - 65248)
          : char;
    });
    return string.join();
  }
}

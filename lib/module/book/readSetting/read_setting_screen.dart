import 'dart:convert';

import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/book/readSetting/read_setting_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:book_app/util/save_util.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReadSettingScreen extends GetView<ReadSettingController> {
  const ReadSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("自定义设置"),
        centerTitle: true,
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios),
          onTap: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: backgroundColor(),
      ),
      backgroundColor: backgroundColor(),
      body: _body(context),
    );
  }


  Widget _body(context) {
    return Stack(
      children: [
        Positioned(
          top: 30,
          left: 50,
          right: 50,
          child: GetBuilder<ReadSettingController>(
            id: 'setting',
            builder: (controller) {
              return Card(
                color: hexToColor(controller.config.backgroundColor),
                elevation: 10,
                child: Container(
                  height: 500,
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.all(10),
                  child: ScrollConfiguration(
                    behavior: NoShadowScrollBehavior(),
                    child: SingleChildScrollView(
                      child: Text.rich(
                          TextSpan(
                              children: const [
                                TextSpan(text: "1.你可以设置背景色\n\n"),
                                TextSpan(text: "2.你可以设置字体颜色\n\n"),
                                TextSpan(text: "3.你可以设置字体大小\n\n"),
                                TextSpan(text: "4.你可以设置字体粗细\n\n"),
                                TextSpan(text: "5.接下来是一段测试\n\n"),
                                TextSpan(text: "得，好美，它如深山里的一泓泉水，带着清澈和甘甜，温润心灵；它如初春的那抹新绿，清新自然，点缀生命；它如花笺里的兰花，恬淡生香，芬芳怡人；它如清晨小草上的露珠，晶莹剔透，不染风尘。懂得，是蓝天与白云的相拥；是清风与花香的缠绵；是润物细无声的点点春雨；是清晨坐拥的满怀阳光。"),
                              ],
                              style: TextStyle(
                                  fontSize: controller.config.fontSize,
                                  color: hexToColor(controller.config.fontColor),
                                  fontFamily: FontUtil.getFontFamily(),
                                  fontWeight: FontUtil.intToFontWeight(controller.config.fontWeight)
                              )
                          )
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Card(
            color: backgroundColorL2() ?? Colors.white,
            child: SizedBox(
              height: 150,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: Text("阅读底色", style: TextStyle(color: textColor() ?? Colors.black),),
                          onTap: () => _colorPicker(context, true),
                        ),
                        GestureDetector(
                          child: Text("字体颜色", style: TextStyle(color: textColor() ?? Colors.black)),
                          onTap: () => _colorPicker(context, false),
                        ),
                        GestureDetector(
                          child: Text("Aa-", style: TextStyle(color: textColor() ?? Colors.black)),
                          onTap: () => controller.fontSizeSub(),
                        ),
                        GestureDetector(
                          child: Text("Aa+", style: TextStyle(color: textColor() ?? Colors.black)),
                          onTap: () => controller.fontSizeAdd(),
                        ),
                        GestureDetector(
                          child: Text("B-", style: TextStyle(color: textColor() ?? Colors.black)),
                          onTap: () => controller.fontWeightSub(),
                        ),
                        GestureDetector(
                          child: Text("B+", style: TextStyle(color: textColor() ?? Colors.black)),
                          onTap: () => controller.fontWeightAdd(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20,),
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            child: Container(
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: textColor() ?? Theme.of(context).primaryColor)
                              ),
                              child: Text("恢复默认设置", style: TextStyle(color: textColor() ?? Theme.of(context).primaryColor, fontSize: 15),),
                            ),
                            onTap: () => controller.setDefault(),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            child: Container(
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: textColor() ?? Theme.of(context).primaryColor)
                              ),
                              child: Text("保存设置", style: TextStyle(color: textColor() ?? Theme.of(context).primaryColor, fontSize: 15)),
                            ),
                            onTap: () {
                              String data = json.encode(controller.config);
                              SaveUtil.setString(Constant.readSettingConfig, data);
                              Get.back(result: {"config": controller.config});
                            },
                          ),
                        ),
                        const SizedBox(width: 20,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _colorPicker(context, flag) {
    String preHex;
    if (flag) {
      // 背景色
      ReadController readController = Get.find();
      if (readController.isDark) {
        return;
      }
      preHex = controller.config.backgroundColor;
    } else {
      // 字体颜色
      preHex = controller.config.fontColor;
    }
    Color pre = hexToColor(preHex);
    String selectColorHex = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColorL2(),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pre,
              onColorChanged: (color) {
                selectColorHex = colorToHex(color, includeHashSign: true, enableAlpha: false);
              },
              showLabel: false,
              enableAlpha: false,
              pickerAreaHeightPercent: .8,
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text("确定", style: TextStyle(color: textColor()),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(backgroundColor())
              ),
              onPressed: () {
                if (selectColorHex.isNotEmpty) {
                  controller.setColor(selectColorHex, flag);
                }
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}

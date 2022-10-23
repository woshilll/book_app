import 'package:book_app/log/log.dart';
import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/book/readMoreSetting/component/page_style_bottom.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/list_item.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

class ReadMoreSettingScreen extends GetView<ReadMoreSettingController> {
  ReadMoreSettingScreen({Key? key}) : super(key: key);
  final ReadController _readController = Get.find();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("更多设置"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: backgroundColor(),
        ),
        backgroundColor: backgroundColor(),
        body: _body(context),
      ),
      onWillPop: () async {
        controller.pop();
        return false;
      },
    );
  }

  Widget _body(context) {
    return GetBuilder<ReadMoreSettingController>(
      id: 'moreSetting',
      builder: (controller) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            ListItem(
              "自动翻页",
              FlutterSwitch(
                  value: controller.autoPage,
                  height: 25,
                  width: 50,
                  onToggle: (value) {
                    Log.i(value);
                    controller.setAutoPage(value);
                  }
              ),
              textColor: textColor()
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            ListItem(
              "翻页速度",
              NumberPicker(
                value: controller.autoPageRate,
                minValue: 3,
                maxValue: 30,
                itemCount: 1,
                itemHeight: 30,
                itemWidth: 50,
                textMapper: (str) {
                  return "${str}s/页";
                },
                textStyle: TextStyle(fontSize: 16, color: textColor()),
                selectedTextStyle: TextStyle(fontSize: 16, color: textColor()),
                onChanged: (value) {
                  controller.setAutoPageRate(value);
                },
              ),
                textColor: textColor()
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            ListItem("护眼模式", FlutterSwitch(
                value: controller.goodEyes,
                height: 25,
                width: 50,
                onToggle: (value) {
                  controller.setGoodEyes(value);
                }
            ),
                textColor: textColor()
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            ListItem("翻页样式",
                GestureDetector(
                  child: Row(
                    children: [
                      Text(_pageStyleStr(_readController.readPageType), style: TextStyle(color: textColor(), height: 1, fontSize: 14),),
                      Icon(Icons.keyboard_arrow_right, color: textColor(), size: 25,)
                    ],
                  ),
                  onTap: () {
                    pageStyleBottom(context, controller);
                  },
                ),
              textColor: textColor()
              ,
            ),
          ],
        );
      },
    );
  }

  String _pageStyleStr(ReadPageType pageType) {
    switch(pageType) {
      case ReadPageType.point:
        return "点击翻页";
      case ReadPageType.slide:
        return "滑动翻页";
      case ReadPageType.slideUpDown:
        return "上下滑动翻页";
    }
  }
}

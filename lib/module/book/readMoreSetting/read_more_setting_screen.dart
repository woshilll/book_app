import 'package:book_app/log/log.dart';
import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/book/readMoreSetting/component/page_style_bottom.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
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
        ),
        backgroundColor: const Color.fromRGBO(220, 220, 220, 1),
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
                textStyle: const TextStyle(fontSize: 16),
                selectedTextStyle: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  controller.setAutoPageRate(value);
                },
              ),
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
                      Text(_pageStyleStr(_readController.readPageType), style: TextStyle(color: Theme.of(globalContext).textTheme.bodyText1!.color, height: 1, fontSize: 14),),
                      Icon(Icons.keyboard_arrow_right, color: Theme.of(globalContext).textTheme.bodyText1!.color, size: 25,)
                    ],
                  ),
                  onTap: () {
                    pageStyleBottom(context, controller);
                  },
                )
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
        return "点击";
      case ReadPageType.smooth:
        return "滑动";
      case ReadPageType.smooth_1:
        return "滑动_动画一";
      case ReadPageType.smooth_2:
        return "滑动_动画二";
      case ReadPageType.smooth_3:
        return "滑动_动画三";
      case ReadPageType.smooth_4:
        return "滑动_动画四";
      case ReadPageType.smooth_5:
        return "滑动_动画五";
      case ReadPageType.smooth_6:
        return "滑动_动画六";
    }
  }
}

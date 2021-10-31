import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
import 'package:book_app/util/list_item.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

class ReadMoreSettingScreen extends GetView<ReadMoreSettingController> {
  const ReadMoreSettingScreen({Key? key}) : super(key: key);

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
                itemHeight: 20,
                itemWidth: 50,
                textMapper: (str) {
                  return "${str}s/页";
                },
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
            ))
          ],
        );
      },
    );
  }

}
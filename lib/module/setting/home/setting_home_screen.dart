import 'package:book_app/log/log.dart';
import 'package:book_app/module/setting/home/setting_home_controller.dart';
import 'package:book_app/util/list_item.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

class SettingHomeScreen extends GetView<SettingHomeController>{
  const SettingHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return GetBuilder<SettingHomeController>(
      id: 'setting',
      builder: (controller) {
        controller.backgroundColor = Theme.of(context).textTheme.bodyText2!.color;
        controller.textColor = Theme.of(context).textTheme.bodyText1!.color;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            ListItem(
              "暗色模式",
              FlutterSwitch(
                  value: controller.isDarkModel,
                  height: 25,
                  width: 50,
                  onToggle: (value) async{
                      await controller.setDarkMode(value);
                  }
              ),
                controller.backgroundColor,
                controller.textColor
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            GestureDetector(
              child: ListItem(
                  "检查更新",
                  Text("V${controller.thisVersion}", style: TextStyle(color: controller.textColor, fontSize: 14),)
                  ,
                  controller.backgroundColor,
                  controller.textColor
              ),
              onTap: () {
                controller.checkVersion();
              },
            ),
          ],
        );
      },
    );
  }
}

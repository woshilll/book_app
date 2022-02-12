import 'package:book_app/log/log.dart';
import 'package:book_app/module/setting/home/setting_home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/list_item.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

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
      body: SingleChildScrollView(
        child: _body(context),
      ),
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
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
            GestureDetector(
              child: ListItem(
                  "启动页",
                  Text(Routes.getRouteName(SaveUtil.getString(Constant.initRoute)), style: TextStyle(color: controller.textColor, fontSize: 14),),
                  controller.backgroundColor,
                  controller.textColor
              ),
              onTap: () {
                showBottom(context);
              },
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Divider(
                height: 1,
                color: Colors.grey[300],
              ),
            ),
          ],
        );
      },
    );
  }
  showBottom(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Opacity(
            opacity: .7,
            child: SizedBox(
              height: 220,
              child: Column(
                children: [
                  InkWell(
                    child:  Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text("默认", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                    ),
                    onTap: () {
                      setInitRoute(Routes.home, context);
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  InkWell(
                    child:  Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text("电影", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                    ),
                    onTap: () {
                      setInitRoute(Routes.movieHome, context);
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  InkWell(
                    child:  Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text("小说", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                    ),
                    onTap: () {
                      setInitRoute(Routes.bookHome, context);
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  InkWell(
                    child:  Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text("日记", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                    ),
                    onTap: () {
                      setInitRoute(Routes.home, context);
                    },
                  ),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  setInitRoute(String route, context) {
    SaveUtil.setString(Constant.initRoute, route);
    EasyLoading.showToast("重启设备后生效");
    Navigator.of(context).pop();
    controller.update(["setting"]);
  }
}

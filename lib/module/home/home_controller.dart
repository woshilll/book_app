import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:book_app/api/chapter_api.dart';
import 'package:book_app/api/login_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/mapper/chapter_db_provider.dart';
import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/model/menu.dart';
import 'package:book_app/module/book/read/component/content_page.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/audio/text_player_handler.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/device_util.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'component/drag_overlay.dart';

class HomeController extends GetxController {

  List<Menu> menu = [];
  bool oldMan = false;
  List<Widget> tiles = [];


  @override
  void onInit() {
    super.onInit();
    var flag = SaveUtil.getTrue(Constant.oldManTrue);
    if (flag != null) {
      oldMan = flag;
    }
    oldMan ? oldManVersion() : normal();
  }



  void normal() {
    bool dark = Get.isDarkMode;
    tiles = [
      item(dark ? Colors.grey : Colors.green, Icons.my_library_books, toast: "小说", route: Routes.bookHome,),
      item(dark ? Colors.grey : Colors.lightBlue, Icons.send),
      item(dark ? Colors.grey : Colors.amber, Icons.library_music, toast: "音乐"),
      item(dark ? Colors.grey : Colors.brown, Icons.map),
      item(dark ? Colors.grey : Colors.deepOrange, Icons.video_library, toast: "电影", route: Routes.movieHome, shouldLogin: true),
      item(dark ? Colors.grey : Colors.indigo, Icons.airline_seat_flat),
      item(dark ? Colors.grey : Colors.red, Icons.bluetooth),
      item(dark ? Colors.grey : Colors.pink, Icons.battery_alert),
      item(dark ? Colors.grey : Colors.purple, Icons.settings, toast: "设置", route: Routes.settingHome),
      item(dark ? Colors.grey : Colors.blue, Icons.radio),
    ];
  }
  void oldManVersion() {
    bool dark = Get.isDarkMode;
    tiles = [
      item(dark ? Colors.grey : Colors.green, Icons.my_library_books, toast: "小说", route: Routes.bookHome,),
      item(dark ? Colors.grey : Colors.lightBlue, Icons.send),
      item(dark ? Colors.grey : Colors.amber, Icons.library_music, toast: "音乐"),
      item(dark ? Colors.grey : Colors.brown, Icons.map),
      item(dark ? Colors.grey : Colors.deepOrange, Icons.video_library, toast: "电影", route: Routes.movieHome, shouldLogin: true),
      item(dark ? Colors.grey : Colors.indigo, Icons.airline_seat_flat),
      item(dark ? Colors.grey : Colors.red, Icons.bluetooth),
      item(dark ? Colors.grey : Colors.pink, Icons.battery_alert),
      item(dark ? Colors.grey : Colors.purple, Icons.settings, toast: "设置", route: Routes.settingHome),
      item(dark ? Colors.grey : Colors.blue, Icons.radio),
    ];
  }

  void changeOldMan() {
    oldMan = !oldMan;
    SaveUtil.setTrue(Constant.oldManTrue, isTrue: oldMan);
    oldMan ? oldManVersion() : normal();
    update(["oldMan"]);
  }


  Widget item(Color backgroundColor, IconData iconData, {String? toast, String? route, bool shouldLogin = false}) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () async {
          if (route != null) {
            if (shouldLogin) {
              String? token = SaveUtil.getString(Constant.token);
              if (token == null || token.isEmpty) {
                // 登录
                Get.toNamed(Routes.login, arguments: {"route": route});
              } else {
                // 验证token
                LoginApi.validToken(await DeviceUtil.getId()).then((value) {
                  Get.toNamed(route);
                });
              }
            } else {
              Get.toNamed(route);
            }
          } else {
            EasyLoading.showToast("敬请期待");
          }

        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: oldMan ? Text(toast ?? '未命名', style: const TextStyle(color: Colors.white, fontSize: 25),)
            : Icon(
              iconData,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        onLongPress: () {
          if (toast != null) {
            EasyLoading.showToast(toast);
          }
        },
      ),
    );
  }


}

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
  List<Widget> tiles = [];


  @override
  void onInit() {
    super.onInit();
    normal();
  }



  void normal() {
    bool dark = Get.isDarkMode;
    tiles = [
      item(dark ? Colors.grey : Colors.green, Icons.my_library_books, name: "小说", route: Routes.bookHome,),
      item(dark ? Colors.grey : Colors.deepOrange, Icons.video_library, name: "电影", route: Routes.movieHome, shouldLogin: true),
      item(dark ? Colors.grey : Colors.brown, Icons.map, name: "日记", route: Routes.diaryHome, shouldLogin: true),
      item(dark ? Colors.grey : Colors.lightBlue, Icons.send),
      item(dark ? Colors.grey : Colors.amber, Icons.library_music, name: "音乐"),
      item(dark ? Colors.grey : Colors.indigo, Icons.airline_seat_flat),
      item(dark ? Colors.grey : Colors.red, Icons.bluetooth),
      item(dark ? Colors.grey : Colors.pink, Icons.battery_alert),
      item(dark ? Colors.grey : Colors.blue, Icons.radio),
      item(dark ? Colors.grey : Colors.purple, Icons.settings, name: "设置", route: Routes.settingHome),
    ];
  }



  Widget item(Color backgroundColor, IconData iconData, {String? name, String? route, bool shouldLogin = false}) {
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
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
                  Get.toNamed(route)?.then((value) {
                    normal();
                    update(["main"]);
                  });
                });
              }
            } else {
              Get.toNamed(route)?.then((value) {
                normal();
                update(["main"]);
              });
            }
          } else {
            EasyLoading.showToast("敬请期待");
          }

        },
        child: Container(
          padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 10,),
              Text(name ?? '待定')
            ],
          ),
        ),
        onLongPress: () {
          
        },
      ),
    );
  }


}

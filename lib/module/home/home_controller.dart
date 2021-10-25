import 'package:book_app/model/menu.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/save_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

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
    tiles = [
      item(Colors.green, Icons.my_library_books, toast: "小说", route: Routes.bookHome,),
      item(Colors.lightBlue, Icons.send),
      item(Colors.amber, Icons.library_music, toast: "音乐"),
      item(Colors.brown, Icons.map),
      item(Colors.deepOrange, Icons.video_library, toast: "电影",),
      item(Colors.indigo, Icons.airline_seat_flat),
      item(Colors.red, Icons.bluetooth),
      item(Colors.pink, Icons.battery_alert),
      item(Colors.purple, Icons.desktop_windows),
      item(Colors.blue, Icons.radio),
    ];
  }
  void oldManVersion() {
    tiles = [
      item(Colors.green, Icons.my_library_books, toast: "小说", route: Routes.bookHome,),
      item(Colors.lightBlue, Icons.send),
      item(Colors.amber, Icons.library_music, toast: "音乐"),
      item(Colors.brown, Icons.map),
      item(Colors.deepOrange, Icons.video_library, toast: "电影",),
      item(Colors.indigo, Icons.airline_seat_flat),
      item(Colors.red, Icons.bluetooth),
      item(Colors.pink, Icons.battery_alert),
      item(Colors.purple, Icons.desktop_windows),
      item(Colors.blue, Icons.radio),
    ];
  }

  void changeOldMan() {
    oldMan = !oldMan;
    SaveUtil.setTrue(Constant.oldManTrue, isTrue: oldMan);
    oldMan ? oldManVersion() : normal();
    update(["oldMan"]);
  }


  Widget item(Color backgroundColor, IconData iconData, {String? toast, String? route}) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          if (route != null) {
            Get.toNamed(route);
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

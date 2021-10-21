import 'package:book_app/model/menu.dart';
import 'package:book_app/route/routes.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<Menu> menu = [];

  @override
  void onInit() {
    super.onInit();
    menu.add(Menu("lib/resource/svg/小说.svg", "小说", Routes.bookHome));
    menu.add(Menu("lib/resource/svg/电影.svg", "电影", ""));
    menu.add(Menu("lib/resource/svg/音乐.svg", "音乐", ""));
  }

}

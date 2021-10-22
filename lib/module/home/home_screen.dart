import 'package:book_app/log/log.dart';
import 'package:book_app/module/home/home_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:book_app/model/book/book.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("主页"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
  Widget _body(context) {
    return GetBuilder<HomeController>(
      id: 'bookList',
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
          child: ScrollConfiguration(
            behavior: NoShadowScrollBehavior(),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1
                ),
                itemCount: controller.menu.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Column(
                      children: [
                        SvgPicture.asset(controller.menu[index].assetPath, width: 80, height: 80,),
                        Text(controller.menu[index].name, style: const TextStyle(fontSize: 16, color: Colors.grey),)
                      ],
                    ),
                    onTap: () {
                      if (controller.menu[index].route.isEmpty) {
                        EasyLoading.showToast("敬请期待", duration: const Duration(milliseconds: 500));
                        return;
                      }
                      Get.toNamed(controller.menu[index].route);
                    },
                  );
                }
            ),
          ),
        );
      },
    );
  }

}

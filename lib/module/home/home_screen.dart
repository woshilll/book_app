import 'package:book_app/log/log.dart';
import 'package:book_app/module/home/home_controller.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:book_app/util/size_fit_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<HomeController> {

  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return Scaffold(
      appBar: AppBar(
          title: const Text("主页"),
          centerTitle: true,
          elevation: 0,
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: _managePop(),
              ),
            )
          ]
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return GetBuilder<HomeController>(
      id: 'oldMan',
      builder: (controller) {
        return ScrollConfiguration(
            behavior: NoShadowScrollBehavior(),
            child: StaggeredGrid.count(
              crossAxisCount: 4,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: controller.tiles,
            ));
      },
    );
  }
  Widget _managePop() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => <PopupMenuItem<String>>[
        controller.oldMan ? const PopupMenuItem<String>(
          child: Text("正常"),
          value: "1",
        ) :const PopupMenuItem<String>(
          child: Text("老年人版"),
          value: "1",
        )
      ],
      offset: const Offset(20, 30),
      onSelected: (value) {
        if (value == "1") {
          controller.changeOldMan();
        }
      },
    );
  }
}



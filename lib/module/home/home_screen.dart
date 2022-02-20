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
      ),
      body: _body(context),
    );
  }

  Widget _body(context) {
    return GetBuilder<HomeController>(
      id: 'main',
      builder: (controller) {
        return ScrollConfiguration(
            behavior: NoShadowScrollBehavior(),
            child: StaggeredGrid.count(
              crossAxisCount: 1,
              children: controller.tiles,
            ));
      },
    );
  }
}



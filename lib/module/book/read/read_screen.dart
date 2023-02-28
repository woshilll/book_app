import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/component/bottom.dart';
import 'package:book_app/module/book/read/component/drawer.dart' as dr;
import 'package:book_app/module/book/read/component/point.dart';
import 'package:book_app/module/book/read/component/slide.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

class ReadScreen extends GetView<ReadController>{
  const ReadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return WillPopScope(
      child: ZoomDrawer(
        controller: controller.zoomDrawerController,
        menuScreen: dr.Drawer(),
        mainScreen: GetBuilder<ReadController>(
          id: ReadRefreshKey.background,
          builder: (controller) {
            return Container(
              color: hexToColor(
                  controller.readSettingConfig.backgroundColor),
              child: _body(context),
            );
          },
        ),
        angle: 0,
        mainScreenScale: 0,
        mainScreenTapClose: true,
        style: DrawerStyle.DefaultStyle,
        showShadow: true,
      ),
      onWillPop: () async {
        await controller.popRead();
        return false;
      },
    );
  }

  Widget _body(context) {
    return GetBuilder<ReadController>(
        id: ReadRefreshKey.page,
        builder: (controller) {
          return GestureDetector(
            child: _content(),
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (controller.zoomDrawerController.isOpen!()) {
                controller.zoomDrawerController.toggle!.call();
              }
            },
            onTapUp: (e) async {
              if (controller.zoomDrawerController.isOpen!()) {
                return;
              }
              if (e.globalPosition.dx < controller.pageGen.screenWidth / 3) {
                if (controller.readPageType == ReadPageType.point) {
                  await controller.prePage();
                }
              } else if (e.globalPosition.dx > (controller.pageGen.screenWidth / 3 * 2)) {
                // if (!controller.loading) {
                  if (controller.readPageType == ReadPageType.point) {
                    await controller.nextPage();
                  }
                // }
              } else {
                // 中间
                // Get.toNamed(Routes.readBottom);
                controller.initBrightness();
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).then((value) {
                  bottom(context);
                });

              }
            },
          );
        }
    );
  }

  _content() {
    switch (controller.readPageType) {
      case ReadPageType.slide:
        return slide();
      case ReadPageType.point:
        return point();
      case ReadPageType.slideUpDown:
        return slide(scrollDirection: Axis.vertical);
    }
  }

}

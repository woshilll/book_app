import 'package:book_app/log/log.dart';
import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/component/bottom.dart';
import 'package:book_app/module/book/read/component/cover.dart';
import 'package:book_app/module/book/read/component/drawer.dart' as dr;
import 'package:book_app/module/book/read/component/point.dart';
import 'package:book_app/module/book/read/component/smooth.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/transformers.dart';
import 'package:flutter/material.dart';
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
        mainScreen: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              bottom: 0,
              child: GetBuilder<ReadController>(
                id: "backgroundColor",
                builder: (controller) {
                  return Container(
                    color: hexToColor(
                        controller.readSettingConfig.backgroundColor),
                  );
                },
              ),
            ),
            _body(context),
          ],
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
        id: "preContent",
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
                await bottom(context);
              }
            },
          );
        }
    );
  }

  _content() {
    switch (controller.readPageType) {
      case ReadPageType.smooth:
        return smooth();
      case ReadPageType.point:
        return point();
      case ReadPageType.smooth_1:
        return smooth(transformer: AccordionTransformer());
      case ReadPageType.smooth_2:
        return smooth(transformer: ThreeDTransformer());
      case ReadPageType.smooth_3:
        return smooth(transformer: ZoomInPageTransformer());
      case ReadPageType.smooth_4:
        return smooth(transformer: ZoomOutPageTransformer());
      case ReadPageType.smooth_5:
        return smooth(transformer: DeepthPageTransformer());
      case ReadPageType.smooth_6:
        return smooth(transformer: ScaleAndFadeTransformer());
    }
  }

}

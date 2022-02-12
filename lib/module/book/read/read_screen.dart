import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/component/battery.dart';
import 'package:book_app/module/book/read/component/bottom.dart';
import 'package:book_app/module/book/read/component/cover.dart';
import 'package:book_app/module/book/read/component/drawer.dart';
import 'package:book_app/module/book/read/component/point.dart';
import 'package:book_app/module/book/read/component/smooth.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/size_fit_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'component/custom_drawer.dart';

class ReadScreen extends GetView<ReadController>{
  const ReadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return WillPopScope(
      child: GetBuilder<ReadController>(
        id: "refreshKey",
        builder: (controller) {
          return Scaffold(
            key: controller.scaffoldKey,
            drawerEdgeDragWidth: 0,
            body: Stack(
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
            drawer: drawer(),
          );
        },
      ),
      onWillPop: () async {
        await controller.popRead();
        return false;
      },
    );
  }

  Widget _body(context) {
    return GetBuilder<ReadController>(
        id: "content",
        builder: (controller) {
          return GestureDetector(
            child: _content(),
            onTapUp: (e) async {
              if (e.globalPosition.dx < controller.screenWidth / 3) {
                if (controller.readPageType == ReadPageType.point) {
                  await controller.prePage();
                }
              } else if (e.globalPosition.dx > (controller.screenWidth / 3 * 2)) {
                if (!controller.loading) {
                  if (controller.readPageType == ReadPageType.point) {
                    await controller.nextPage();
                  }
                }
              } else {
                // 中间
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
        return smooth(controller);
      case ReadPageType.point:
        return point();
    }
    return Container();
  }

}

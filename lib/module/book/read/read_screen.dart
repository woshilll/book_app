import 'dart:async';

import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/component/battery.dart';
import 'package:book_app/module/book/read/component/bottom.dart';
import 'package:book_app/module/book/read/component/drawer.dart';
import 'package:book_app/module/book/read/component/smooth.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'component/custom_drawer.dart';

class ReadScreen extends GetView<ReadController> {
  const ReadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      key: controller.scaffoldKey,
      drawerEdgeDragWidth: 0,
      body: WillPopScope(
        child: Stack(
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
        onWillPop: () async {
          controller.pop();
          return false;
        },
      ),
      drawer: drawer(),
    );
  }

  Widget _body(context) {
    return GestureDetector(
      child: Stack(
        children: [
          GetBuilder<ReadController>(
            id: "content",
            builder: (controller) {
              switch (controller.readPageType) {
                case ReadPageType.smooth:
                  return smooth();
              }
              return Container();
            },
          ),
          Positioned(
            bottom: 4,
            left: 15,
            child: battery(),
          ),
        ],
      ),
      onTapUp: (e) async {
        controller.screenWidth = MediaQuery.of(context).size.width;
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

  Widget _content(context, index) {
    return Stack(
      children: [
        Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                  left: ((MediaQuery.of(context).size.width %
                                  controller.pages[index].wordWith) +
                              controller.pages[index].wordWith) /
                          2 +
                      MediaQuery.of(context).padding.left),
              child: Column(
                children: [
                  if (controller.pages[index].index == 1)
                    Container(
                      height: 80,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${controller.pages[index].chapterName}\n",
                        style: TextStyle(
                            color: controller.pages[index].style.color,
                            fontSize: 25,
                            height: 1,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text.rich(
                    TextSpan(
                        text: controller.pages[index].content,
                        style: controller.pages[index].style),
                  )
                ],
              ),
            )),
        Positioned(
          top: 4,
          left: 15,
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "${controller.pages[index].chapterName}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 25,
          child: Text(
            "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

}

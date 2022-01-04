import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'custom_drawer.dart';
ReadController controller = Get.find();
drawer() {

  return MediaQuery.removePadding(
      context: controller.context,
      removeTop: true,
      child: Opacity(
        opacity: 1,
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.only(top: MediaQuery
              .of(controller.context)
              .padding
              .top),
          child: CustomDrawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 41,
                  alignment: Alignment.centerLeft,
                  margin:
                  const EdgeInsets.only(left: 15),
                  child: Text(
                    "共${controller.chapters.length + 1}章",
                    style:
                    const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        child: NotificationListener<ScrollNotification>(
                          child: ScrollConfiguration(
                            behavior: NoShadowScrollBehavior(),
                            child: ScrollablePositionedList.separated(
                              itemScrollController: controller.menuController,
                              itemPositionsListener: controller.menuPositionsListener,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  child: Container(
                                    height: 41,
                                    padding:
                                    const EdgeInsets.only(left: 10),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "${controller.chapters[index]
                                          .name}",
                                      style:
                                      controller.readChapterIndex ==
                                          index
                                          ? const TextStyle(
                                          color: Colors.lightBlue)
                                          : const TextStyle(
                                          color: Colors.grey),
                                    ),
                                  ),
                                  onTap: () async {
                                    await controller.jumpChapter(index);
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: const Divider(
                                      height: 1.0, color: Colors.grey),
                                );
                              },
                              itemCount: controller.chapters.length,
                            ),
                          ),
                          onNotification: _handleScrollNotification,
                        ),
                      ),
                      // GetBuilder<ReadController>(
                      //   id: "menuMove",
                      //   builder: (controller) {
                      //     return Positioned(
                      //       right: 0,
                      //       top: controller.menuBarMove,
                      //       child: Container(
                      //         width: 10,
                      //         height: 40,
                      //         decoration: BoxDecoration(
                      //             color: Colors.grey,
                      //             borderRadius: BorderRadius.circular(4)
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // )
                    ],
                  ),
                )
              ],
            ),
            widthPercent: 0.7,
          ),
        ),
      ));

}
bool _handleScrollNotification(ScrollNotification notification) {
  // final ScrollMetrics metrics = notification.metrics;
  // controller.menuBarMove = (metrics.pixels / metrics.maxScrollExtent) * (controller.screenHeight - 82 - controller.screenTop);
  // controller.update(["menuMove"]);
  return true;
}
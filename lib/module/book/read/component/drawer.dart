import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_drawer.dart';

drawer() {
  ReadController controller = Get.find();
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
                  margin:
                  const EdgeInsets.only(top: 10, bottom: 10, left: 15),
                  child: GetBuilder<ReadController>(
                    // id: 'content',
                    builder: (controller) {
                      return Text(
                        "共${controller.chapters.length + 1}章",
                        style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        child: ScrollConfiguration(
                          behavior: NoShadowScrollBehavior(),
                          child: Scrollbar(
                            child: GetBuilder<ReadController>(
                              // id: 'content',
                              builder: (controller) {
                                return ListView.separated(
                                  controller: controller.menuController,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      child: Container(
                                        height: 40,
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
                                  itemCount: controller.chapters.length,
                                  cacheExtent: 200,
                                  separatorBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: const Divider(
                                          height: 1.0, color: Colors.grey),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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

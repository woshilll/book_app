import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:book_app/model/chapter/chapter.dart';
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
                        child: GetBuilder<ReadController>(
                          id: "loadMenuItems",
                          builder: (controller) {
                            return NotificationListener<ScrollNotification>(
                              child: ScrollConfiguration(
                                behavior: NoShadowScrollBehavior(),
                                child: ListView.separated(
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      child: Container(
                                        height: 41,
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "${controller.menuItems[index]
                                              .name}",
                                          style:
                                          controller.pages[controller.pageIndex.count].chapterId ==
                                              controller.menuItems[index].id
                                              ? const TextStyle(
                                              color: Colors.lightBlue)
                                              : const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ),
                                      onTap: () async {
                                        controller.pageIndex.resetCount();
                                        await controller.jumpChapter(controller.chapters.indexWhere((element) => element.id == controller.menuItems[index].id));
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
                                  itemCount: controller.menuItems.length,
                                  cacheExtent: 100,
                                ),
                              ),
                              onNotification: (value) {
                                return _handleScrollNotification(value, controller);
                              },
                            );
                          },
                        ),
                      ),
                      GetBuilder<ReadController>(
                        id: "menuMove",
                        builder: (controller) {
                          return Positioned(
                            right: 0,
                            top: controller.menuBarMove,
                            child: Container(
                              width: 10,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(4)
                              ),
                            ),
                          );
                        },
                      )
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


/// 加载更多 flag true 底部插入  false 顶部插入
_loadMore(ReadController controller, [bool flag = true]) {
  int index = controller.chapters.indexWhere((element) => element.id == controller.menuItems[flag ? (controller.menuItems.length - 1) : 0].id);
  if (!flag) {
    if (index == 0) {
      return;
    }
  }
  for(int i = flag ? index + 1 : index - 1; flag ? (i < controller.chapters.length && i < index + 30) : (i >= 0 && i > index - 30); flag ? i++ : i--) {
    if (flag) {
      controller.menuItems.add(controller.chapters[i]);
    } else {
      controller.menuItems.insert(0, controller.chapters[i]);
    }
  }
  controller.update(["loadMenuItems"]);
}

bool _handleScrollNotification(ScrollNotification notification, ReadController controller) {
  final ScrollMetrics metrics = notification.metrics;
  if (metrics.pixels >= metrics.maxScrollExtent) {
    LimitUtil.throttle(() {
      _loadMore(controller);
    });
  }else if (metrics.pixels <= 0) {
    LimitUtil.throttle(() {
      _loadMore(controller, false);
    });
  }
  controller.menuBarMove = (metrics.pixels / metrics.maxScrollExtent) * (controller.screenHeight - 82 - controller.screenTop);
  controller.update(["menuMove"]);
  return true;
}
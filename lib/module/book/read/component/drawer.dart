import 'dart:async';

import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'custom_drawer.dart';
drawer(context) async{
  ReadController controller = Get.find();
  int listIndex = controller.chapters.indexWhere((element) => element.id == controller.pages[controller.pageIndex.count].chapterId);
  ScrollController scrollController = ScrollController();
  await Navigator.of(context)
      .push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: MediaQuery.removePadding(
                context: controller.context,
                removeTop: true,
                child: GestureDetector(
                  child: Stack(
                    children: [
                      Container(color: Colors.transparent,),
                      Opacity(
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
                                  child: ScrollConfiguration(
                                    behavior: NoShadowScrollBehavior(),
                                    child: _list(controller, scrollController, listIndex),
                                )
                                )
                              ],
                            ),
                            widthPercent: 0.7,
                          ),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                )),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      }
  ))
      .then((value) {
        scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  });
}

Widget _list(ReadController controller, ScrollController scrollController, listIndex) {
  Timer(const Duration(milliseconds: 10), () {
    scrollController.animateTo(41.0 * listIndex, duration: Duration(seconds: listIndex ~/ 100), curve: Curves.linear);
  });
  return CustomScrollView(
    controller: scrollController,
    slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) {
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
                    controller.pages[controller.pageIndex.count].chapterId ==
                        controller.chapters[index].id
                        ? const TextStyle(
                        color: Colors.lightBlue)
                        : const TextStyle(
                        color: Colors.grey),
                  ),
                ),
                onTap: () async {
                  controller.pageIndex.resetCount();
                  await controller.jumpChapter(controller.chapters.indexWhere((element) => element.id == controller.chapters[index].id));
                },
              );
            },
          childCount: controller.chapters.length,
        ),
      )
    ],
    cacheExtent: 500,
  );
}
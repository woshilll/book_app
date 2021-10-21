import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'component/custom_drawer.dart';

class ReadScreen extends GetView<ReadController> {
  const ReadScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      body: _body(context),
      // floatingActionButton: SizedBox(
      //   width: 60,
      //   height: 60,
      //   child: ElevatedButton(
      //     child: const Text("搜书", style: TextStyle(fontSize: 14)),
      //     style: ButtonStyle(
      //       shape: MaterialStateProperty.all(const CircleBorder()),
      //     ),
      //     onPressed: () {
      //     },
      //   ),
      // ),
      drawer: _drawer(context),
      onDrawerChanged: (e) {
        if (e) {
          controller.menuJump();
        } else {
          controller.menuJumpFlag = false;
        }
      },
    );
  }

  Widget _body(context) {
    return Stack(
      children: [
        Positioned(
          child: Container(
            margin: EdgeInsets.only(left: 5, top: MediaQuery.of(context).padding.top),
            child: ScrollConfiguration(
              behavior: NoShadowScrollBehavior(),
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: _content(),
              ),
            ),
          ),
        ),
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   child: Opacity(
        //     opacity: 0.7,
        //     child: Container(
        //       height: 40,
        //       color: Colors.black,
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget _drawer(context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Opacity(
          opacity: 0.9,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: CustomDrawer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10, left: 15),
                    child: GetBuilder<ReadController>(
                      id: 'content',
                      builder: (controller) {
                        return Text("共${controller.chapters.length}章", style: const TextStyle(fontSize: 14),);
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
                                id: 'content',
                                builder: (controller) {
                                  return ListView.separated(
                                    controller: controller.menuController,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        child: Container(
                                          height: controller.menuHeight,
                                          padding: const EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Text("${controller.chapters[index].name}", style: TextStyle(fontSize: 16, color: controller.chapters[index].id == controller.curChapter.id ? Colors.green : Colors.black),),
                                        ),
                                        onTap: () async{
                                          await controller.jumpTo(index);
                                        },
                                      );
                                    },
                                    itemCount: controller.chapters.length,
                                    cacheExtent: 200,
                                    separatorBuilder: (context, index) {
                                      return Divider(height: 1.0, color: Colors.grey[300]);
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
        )
    );
  }
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      controller.calWhenScrollEndCurChapter(notification.metrics.pixels);
    }
    return false;
  }
  Widget _content() {
    return GetBuilder<ReadController>(
      id: 'content',
      builder: (controller) {
        return ListView.builder(
          controller: controller.contentController,
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          cacheExtent: 5,
          itemCount: controller.readChapters.length,
          itemBuilder: (context, index) {
            return Listener(
              child: Container(
                key: Key("${controller.readChapters[index].id}"),
                child: Text.rich(
                  TextSpan(
                      children: [
                        TextSpan(
                          text: "${controller.readChapters[index].name}",
                          style: const TextStyle(fontSize: 18, height: 3, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: "\n",
                        ),
                        TextSpan(
                          text: "${controller.readChapters[index].content}",
                          style: const TextStyle(fontSize: 18, height: 1.8),
                        )
                      ]
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

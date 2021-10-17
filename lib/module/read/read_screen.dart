import 'package:book_app/log/log.dart';
import 'package:book_app/module/read/component/custom_drawer.dart';
import 'package:book_app/module/read/read_controller.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReadScreen extends GetView<ReadController> {
  const ReadScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
      //     onPressed: () => controller.cal(context),
      //   ),
      // ),
      drawer: _drawer(context),
    );
  }

  Widget _body(context) {
    return Stack(
      children: [
        Positioned(
          child: ScrollConfiguration(
            behavior: NoShadowScrollBehavior(),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 5, top: MediaQuery.of(context).padding.top),
                child: GetBuilder<ReadController>(
                  id: 'content',
                  builder: (controller) {
                    return Text("${controller.curChapter.content}",
                      style: const TextStyle(fontSize: 18, height: 1.8),
                    );
                  },
                ),
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
                    child: ScrollConfiguration(
                      behavior: NoShadowScrollBehavior(),
                      child: Scrollbar(
                        notificationPredicate: _handleScrollNotification,
                        child: GetBuilder<ReadController>(
                          id: 'content',
                          builder: (controller) {
                            return ListView.separated(
                              itemBuilder: (context, index) {
                                return InkWell(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                                    child: Text("${controller.chapters[index].name}", style: const TextStyle(fontSize: 16),),
                                  ),
                                  onTap: () {

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
    final ScrollMetrics metrics = notification.metrics;
    controller.drawerY.value =  -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
    return true;
  }
}
import 'dart:async';

import 'package:book_app/model/chapter/chapter.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/no_shadow_scroll_behavior.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'custom_drawer.dart';
class Drawer extends GetView<ReadController> {
  Drawer({Key? key}) : super(key: key);
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReadController>(
      id: "drawer",
      builder: (controller) {
        Future.delayed(const Duration(milliseconds: 100), (){
          scrollController.jumpTo(controller.pages.isEmpty ? 0 : (controller.chapters.indexWhere((element) => controller.pages[controller.pageIndex.count].chapterId == element.id)) * 41);
        });
        return Container(
          width: MediaQuery.of(context).size.width * .7,
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 41,
                alignment: Alignment.centerLeft,
                margin:
                const EdgeInsets.only(left: 15),
                child: Text(
                  "共${controller.chapters.length}章",
                  style:
                  const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              MediaQuery.removePadding(
                  context: context,
                  child: Expanded(
                    child: DraggableScrollbar.rrect(
                    controller: scrollController,
                    child: ListView.builder(
                      itemBuilder:
                          (context, index) {
                        return InkWell(
                          child: Container(
                            padding:
                            const EdgeInsets.only(left: 10, right: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "${controller.chapters[index]
                                  .name}",
                              maxLines: 2,
                              style:
                              controller.pages.isEmpty ? null : controller.pages[controller.pageIndex.count].chapterId ==
                                  controller.chapters[index].id
                                  ? const TextStyle(
                                  color: Colors.lightBlue)
                                  : const TextStyle(
                                  color: Colors.grey),
                            ),
                          ),
                          onTap: () async {
                            ReadController controller = Get.find();
                            await controller.jumpChapter(controller.chapters.indexWhere((element) => element.id == controller.chapters[index].id), pop: false, clearCount: true);
                            controller.zoomDrawerController.toggle?.call();
                          },
                        );
                      },
                      itemCount: controller.chapters.length,
                      controller: scrollController,
                      itemExtent: 41,
                    ),
                  )
              ),
                removeTop: true,
              )
            ],
          ),
        );
      },
    );
  }
}
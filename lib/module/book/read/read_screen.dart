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
    return WillPopScope(
      child: Scaffold(
        body: _body(context),
        drawer: _drawer(context),
      ),
      onWillPop: () async {
        await controller.pop();
        return false;
      },
    );
  }

  Widget _body(context) {
    return GetBuilder<ReadController>(
      id: "content",
      builder: (controller) {
        return PageView.builder(
          controller: controller.contentPageController,
          itemCount: controller.pages.length,
          itemBuilder: (context, index) {
            return _content(context, index);
          },
          onPageChanged: (index) async{
            controller.pageIndex = index;
            if (index + 2 >= controller.pages.length) {
              await controller.pageChangeListen(index);
            }
          },
        );
      },
    );
  }

  Widget _content(context, index) {
    return Stack(
      children: [
        Positioned(
            top: MediaQuery.of(context).padding.top,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: (MediaQuery.of(context).size.width % controller.pages[index].wordWith) / 2),
              child: Text.rich(
                TextSpan(
                    text: controller.pages[index].content,
                    style: controller.pages[index].style),
              ),
            )),
        Positioned(
          bottom: 0,
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            child: Text(
              "${controller.pages[index].chapterName}",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 10,
          child: Text(
            "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        )
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
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        child: Container(
                                          height: 40,
                                          padding: const EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Text("${controller.chapters[index].name}",),
                                        ),
                                        onTap: () async{
                                          await controller.jumpPage(index);
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

}

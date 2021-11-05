import 'package:book_app/module/book/read/read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
/// 平滑
Widget smooth() {
  ReadController controller = Get.find();
  return Listener(
    child: PageView.builder(
      controller: controller.contentPageController,
      itemCount: controller.pages.length,
      itemBuilder: (context, index) {
        return content(context, index, controller);
      },
      onPageChanged: (index) async {
        controller.pageIndex = index;
        if (index + 10 >= controller.pages.length &&
            !controller.loading) {
          await controller.pageChangeListen(index);
        }
      },
    ),
    onPointerDown: (e) {
      controller.autoPageCancel();
      controller.xMove = e.position.dx;
    },
    onPointerUp: (e) async {
      double move = e.position.dx - controller.xMove;
      // 滑动了五十距离, 且当前为0
      if (move > 50 && controller.pageIndex == 0) {
        await controller.prePage();
      } else if (move < -50 &&
          controller.pageIndex == controller.pages.length - 1) {
        await controller.nextPage();
      }
    },
  );
}
Widget content(context, index, controller) {
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

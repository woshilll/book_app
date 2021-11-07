import 'package:book_app/util/size_fit_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Widget content(context, index, controller) {
  return Stack(
    children: [
      Positioned(
          top: controller.screenTop,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.topCenter,
            width: controller.screenWidth,
            padding: EdgeInsets.only(
                left: controller.calPaddingLeft(index)),
            child: Column(
              children: [
                if (controller.pages[index].index == 1)
                  Container(
                    height: SizeFitUtil.setPx(80),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${controller.pages[index].chapterName}\n",
                      style: TextStyle(
                          color: controller.pages[index].style.color,
                          fontSize: SizeFitUtil.setPx(25),
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
      if (controller.pages[index].noContent)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            alignment: Alignment.center,
            child: GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, color: Theme.of(context).primaryColor, size: 25,),
                  Text("重新加载", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, height: 1),)
                ],
              ),
              onTap: () async {
                if (controller.book.type == 1) {
                  await controller.reloadPage();
                } else {
                  EasyLoading.showToast("本地导入文章,无法加载");
                }
              },
            ),
          ),
        )
    ],
  );
}

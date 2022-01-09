import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'battery.dart';

Widget content(context, index, ReadController controller) {
  if (controller.pages.isEmpty || controller.pages.length < index) {
    return Container();
  }
  return Column(
    children: [
      _top(context, controller),
      Expanded(
        child: SizedBox(
          width: controller.pages[index].width,
          child: Column(
            children: [
              if (controller.pages[index].index == 1)
                Container(
                  height: controller.titleHeight,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${controller.pages[index].chapterName}\n",
                    style: TextStyle(
                        color: hexToColor(controller.readSettingConfig.fontColor),
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Text(
                  controller.pages[index].content,
                  textWidthBasis: TextWidthBasis.longestLine,
                  textAlign: TextAlign.justify,
                  textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  style: TextStyle(
                    color: hexToColor(controller.readSettingConfig.fontColor),
                    fontSize: controller.readSettingConfig.fontSize,
                    height: controller.readSettingConfig.fontHeight
                  )),
            ],
          ),
        ),
      ),
      if (controller.pages[index].noContent)
        Container(
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
              if (controller.book!.type == 1) {
                await controller.reloadPage();
              } else {
                EasyLoading.showToast("本地导入文章,无法加载");
              }
            },
          ),
        ),
      _bottom(context, index, controller),
    ],
  );
}

Widget _top(context, ReadController controller) {
  return SizedBox(
    height: MediaQuery.of(context).padding.top,
    width: MediaQuery.of(context).size.width,
    child: Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 15),
              child: Text("${controller.book == null ? "" : controller.book!.name}", maxLines: 1, style: const TextStyle(height: 1, color: Colors.grey)),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(right: 15),
            child: battery(),
          ),
        ],
      ),
    ),
  );
}

_bottom(context, index, ReadController controller) {
  return Container(
    height: 16,
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 25),
            child: Text(
              "${controller.pages[index].chapterName}",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 25),
          child: Text(
            "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
        )
      ],
    ),
  );
}

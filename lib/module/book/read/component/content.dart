import 'package:book_app/module/book/read/component/content_bottom.dart';
import 'package:book_app/module/book/read/component/content_top.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/font_util.dart';
import 'package:book_app/util/toast.dart';
import 'package:flutter/material.dart';

Widget content(context, index, ReadController controller) {
  if (controller.pages.isEmpty || controller.pages.length < index) {
    return Container();
  }
  return Column(
    children: [
      contentTop(context, controller),
      Expanded(
        child: SizedBox(
          width: controller.pages[index].width,
          child: Column(
            crossAxisAlignment: controller.rotateScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (controller.pages[index].index == 1)
                Container(
                  height: controller.pageGen.titleHeight,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${controller.pages[index].chapterName}\n",
                    style: TextStyle(
                        color: hexToColor(controller.readSettingConfig.fontColor),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontUtil.getFontFamily()
                    ),
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
                    height: controller.readSettingConfig.fontHeight,
                    fontFamily: FontUtil.getFontFamily(),
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
                Toast.toast(toast: "本地导入文章,无法加载");
              }
            },
          ),
        ),
      contentBottom(context, index, controller),
    ],
  );
}

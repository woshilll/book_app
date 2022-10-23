import 'package:book_app/module/book/read/component/content_bottom.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/theme/color.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:book_app/util/toast.dart';
import 'package:flutter/material.dart';

Widget content(context, index, ReadController controller) {
  if (controller.pages.isEmpty || controller.pages.length < index) {
    return Container();
  }
  return Column(
    children: [
      SizedBox(height: controller.rotateScreen ? controller.pageGen.screenTop / 2 : controller.pageGen.screenTop,),
      Expanded(
        child: Container(
          alignment: Alignment.topCenter,
          width: controller.pages[index].width + 2,
          child: Text.rich(
            TextSpan(
                children: [
                  if (controller.pages[index].index == 1)
                    TextSpan(
                      text: "${controller.pages[index].chapterName}\n",
                      style: TextStyle(
                          color: hexToColor(controller.readSettingConfig.fontColor),
                          fontSize: controller.pageGen.titleStyle.fontSize,
                          fontWeight: controller.pageGen.titleStyle.fontWeight,
                          fontFamily: controller.pageGen.titleStyle.fontFamily
                      ),
                    ),
                  TextSpan(
                      text: controller.pages[index].content,
                      style: TextStyle(
                          color: hexToColor(controller.readSettingConfig.fontColor),
                          fontSize: controller.pageGen.contentStyle.fontSize,
                          fontWeight: controller.pageGen.contentStyle.fontWeight,
                          fontFamily: controller.pageGen.contentStyle.fontFamily
                      )),
                ]
            ),
            textAlign: TextAlign.justify,
            textScaleFactor: MediaQuery.of(globalContext).textScaleFactor,
            textWidthBasis: TextWidthBasis.longestLine,
            locale: WidgetsBinding.instance!.window.locale,
            textDirection: TextDirection.ltr,
            strutStyle: StrutStyle(
                forceStrutHeight: true,
                fontSize: controller.pageGen.contentStyle.fontSize,
                height: controller.pageGen.contentStyle.height
            ),
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

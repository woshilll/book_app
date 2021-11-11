import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget content(context, index, ReadController controller) {
  return Column(
    children: [
      SizedBox(
        height: controller.screenTop,
      ),
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
                        color: controller.pages[index].style.color,
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
                  textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  style: controller.pages[index].style),
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
              if (controller.book.type == 1) {
                await controller.reloadPage();
              } else {
                EasyLoading.showToast("本地导入文章,无法加载");
              }
            },
          ),
        ),
      Container(
        height: 16,
        margin: EdgeInsets.only(bottom: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 25),
              child: Text(
                "${controller.pages[index].chapterName}",
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 25),
              child: Text(
                "${controller.pages[index].index}/${controller.calThisChapterTotalPage(index)}",
                style: TextStyle(fontSize: 12.sp, color: Colors.black54),
              ),
            )
          ],
        ),
      ),
    ],
  );
}

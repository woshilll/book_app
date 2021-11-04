import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

pageStyleBottom(context, ReadMoreSettingController controller) {
  ReadController readController = Get.find();
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Opacity(
          opacity: .7,
          child: SizedBox(
            height: 220,
            child: Column(
              children: [
               InkWell(
                 child:  Container(
                   height: 50,
                   alignment: Alignment.center,
                   child: Text("平滑翻页", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                 ),
                 onTap: () {
                   if (readController.readPageType != ReadPageType.smooth) {
                     readController.setPageType(ReadPageType.smooth);
                     controller.fresh();
                     Navigator.of(context).pop();
                   }
                 },
               ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                InkWell(
                  child:  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text("点击翻页", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                  ),
                  onTap: () {
                    if (readController.readPageType != ReadPageType.point) {
                      readController.setPageType(ReadPageType.point);
                      controller.fresh();
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                InkWell(
                  child:  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text("仿真翻页(未实现)", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                  ),
                  onTap: () {},
                ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                InkWell(
                  child:  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text("覆盖翻页(未实现)", style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 20),),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      }
  );
}

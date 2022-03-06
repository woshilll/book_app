import 'package:book_app/model/read_page_type.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

pageStyleBottom(context, ReadMoreSettingController controller) {
  var list = [
    ["平滑翻页", ReadPageType.smooth],
    ["平滑翻页_动画一", ReadPageType.smooth_1],
    ["平滑翻页_动画二", ReadPageType.smooth_2],
    ["平滑翻页_动画三", ReadPageType.smooth_3],
    ["平滑翻页_动画四", ReadPageType.smooth_4],
    ["平滑翻页_动画五", ReadPageType.smooth_5],
    ["平滑翻页_动画六", ReadPageType.smooth_6],
    ["点击翻页", ReadPageType.point],
  ];
  ReadController readController = Get.find();
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Opacity(
          opacity: .7,
          child: SizedBox(
            height: 51 * list.length + 16,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return InkWell(
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        "${list[index][0]}",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontSize: 20),
                      ),
                    ),
                    onTap: () {
                      ReadPageType readPageType = list[index][1] as ReadPageType;
                      if (readController.readPageType != readPageType) {
                        readController.setPageType(readPageType);
                        controller.fresh();
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    color: Colors.grey,
                  );
                },
                itemCount: list.length),
          ),
        );
      });
}

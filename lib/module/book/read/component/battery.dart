import 'package:battery_plus/battery_plus.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:book_app/util/time_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
Color activeColor = Theme.of(globalContext).primaryColor;
Color unActiveColor = Colors.grey;
/// 底部电池和时间
Widget battery() {

  return GetBuilder<ReadController>(
    id: "battery",
    builder: (controller) {
      // 判断电池状态
      if (controller.batteryState == BatteryState.charging) {
        // 正在充电
        return Row(
          children: [
            Container(
              width: 25,
              height: 12,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: activeColor)
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                width: (controller.batteryLevel / 100) * 21,
                child: Container(),
                color: activeColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 1),
              width: 1,
              height: 6,
              color: activeColor,
            ),
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(TimeUtil.getSystemTime(), style: TextStyle(color: unActiveColor),),
            )
          ],
        );
      } else {
        // 放电
        return Row(
          children: [
            Container(
              width: 25,
              height: 12,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: unActiveColor)
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                alignment: Alignment.center,
                child: Text("${controller.batteryLevel}", style: TextStyle(fontSize: 10, color: unActiveColor, height: 1),),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 1),
              width: 1,
              height: 6,
              color: unActiveColor,
            ),
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(TimeUtil.getSystemTime(), style: TextStyle(color: unActiveColor),),
            )
          ],
        );
      }
    },
  );
}

import 'package:battery_plus/battery_plus.dart';
import 'package:book_app/module/book/read/read_controller.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:book_app/util/time_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
/// 充电时颜色
Color activeColor = Theme.of(globalContext).primaryColor;
/// 放电颜色
Color unActiveColor = Colors.grey;
/// 电量低于20
Color warningColor = Colors.orangeAccent;
/// 电量低于10
Color dangerColor = Colors.redAccent;
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
              width: 28,
              height: 16,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: activeColor)
              ),
              child: FractionallySizedBox(
                widthFactor: controller.batteryLevel / 100,
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(1),
                  color: activeColor,
                ),
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
              child: Text(TimeUtil.getSystemTime(), style: TextStyle(color: unActiveColor, fontSize: 10),),
            )
          ],
        );
      } else {
        // 放电
        Color color = unActiveColor;
        if (controller.batteryLevel <= 10) {
          color = dangerColor;
        } else if (controller.batteryLevel <= 20) {
          color = warningColor;
        }
        return Row(
          children: [
            Container(
              height: 16,
              width: 28,
              decoration: BoxDecoration(
                  border: Border.all(color: color)
              ),
              child: Container(
                margin: const EdgeInsets.all(1),
                alignment: Alignment.center,
                child: Text("${controller.batteryLevel}", style: TextStyle(fontSize: 9, color: color, height: 1.1),textScaleFactor: MediaQuery.of(globalContext).textScaleFactor,),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 1),
              width: 1,
              height: 6,
              color: color,
            ),
            Container(
              margin: const EdgeInsets.only(left: 5),
              child: Text(TimeUtil.getSystemTime(), style: TextStyle(color: unActiveColor, fontSize: 10, height: 1.1),textScaleFactor: MediaQuery.of(globalContext).textScaleFactor,),
            )
          ],
        );
      }
    },
  );
}

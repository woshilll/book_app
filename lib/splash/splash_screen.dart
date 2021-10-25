
import 'package:book_app/route/routes.dart';
import 'package:book_app/splash/component/text_paint.dart';
import 'package:book_app/splash/splash_controller.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends GetView<SplashController>{
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset("lib/resource/image/front.png"),
          ),
          _textDraw(),
          // _pointDraw(),
          _timeCountdownDraw(context),
          // _lastPageButtonDraw(context)
        ],
      ),
    );
  }

  /// 画相同数量的点点
  Widget _pointDraw() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(controller.defaultInitPage.length, (index) {
          return GetBuilder<SplashController>(
            id: 'pageIndexChange',
            builder: (controller) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.pageIndex == index
                        ? Colors.blue
                        : Colors.grey
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _timeCountdownDraw(context) {
    return Positioned(
      top: getStatusBarHeight(context) + 10,
      right: 10,
      child: InkWell(
        child: Container(
          child: GetBuilder<SplashController>(
            id: 'timeCountdown',
            builder: (controller) {
              return Container(
                padding: const EdgeInsets.fromLTRB(13, 3, 13, 3),
                child: Text("${controller.timeCountdown}s"),
              );
            },
          ),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all()
          ),
        ),
        onTap: () => controller.toHome(),
      ),
    );
  }

  Widget _lastPageButtonDraw(context) {
    return Positioned(
      left: 10,
      right: 10,
      bottom: 60,
      child: GetBuilder<SplashController>(
        id: 'lastPageButton',
        builder: (controller) {
          if (controller.pageIndex == controller.defaultInitPage.length - 1) {
            return FractionallySizedBox(
              widthFactor: .5,
              child: ElevatedButton(onPressed: () => controller.toHome(), child: const Text("开启旅程")),
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _textDraw() {
    return CustomPaint(
      painter: TextPaint("求推荐"),
    );
  }
}

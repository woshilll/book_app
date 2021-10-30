import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/splash/component/text_paint.dart';
import 'package:book_app/splash/splash_controller.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    controller.context = context;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              height: 100,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                        fontSize: 40.0,
                        color: Colors.white
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        RotateAnimatedText('请!', duration: const Duration(milliseconds: 1000)),
                        RotateAnimatedText('现在!', duration: const Duration(milliseconds: 1000)),
                        RotateAnimatedText('立刻!', duration: const Duration(milliseconds: 1000)),
                        RotateAnimatedText('加入我们!', duration: const Duration(milliseconds: 1000)),
                        TypewriterAnimatedText('青年戒色吧欢迎你的加入!', textStyle: TextStyle(fontSize: (MediaQuery.of(context).size.width - 20) / 12), speed: const Duration(milliseconds: 300)),
                      ],
                      repeatForever: true,
                      pause: const Duration(milliseconds: 100),
                      onTap: () {
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          _topRightDraw(context),
        ],
      ),
    );
  }

  Widget _topRightDraw(context) {
    return Positioned(
      top: getStatusBarHeight(context) + 10,
      right: 10,
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 3, 13, 3),
          child: const Text("跳过", style: TextStyle(color: Colors.white),),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.white)),
        ),
        onTap: () => controller.toHome(),
      ),
    );
  }

  Widget _textDraw() {
    return CustomPaint(
      painter: TextPaint("求推荐"),
    );
  }
}

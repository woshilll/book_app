import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/module/login/login_controller.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/limit_util.dart';
import 'package:book_app/util/size_fit_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        child: Scaffold(
          body: _body(context),
        ),
        value: SystemUiOverlayStyle.light,
      ),
      onWillPop: () async {
        controller.goBack(false);
        return false;
      },
    );
  }

  Widget _body(context) {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          GestureDetector(
            child: Container(
              height: 56.h,
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 15),
              child: GestureDetector(
                child: Icon(Icons.close, color: Colors.white, size: 30.sp,),
                onTap: () => controller.goBack(false),
              ),
            ),
          ),
          Container(
            height: 50.h,
            margin: const EdgeInsets.only(left: 15),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 35.sp,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 7.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: GetBuilder<LoginController>(
                id: "welcome",
                builder: (controller) {
                  return AnimatedOpacity(
                    opacity: controller.welcome, duration: const Duration(seconds: 1),
                    child: Text("嗨!"),
                    onEnd: () {
                        controller.textOp = 1;
                        controller.update(["textOp"]);
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30, top: 20),
            height: 50.h,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 25.sp,
                height: 1,
                shadows: const [
                  Shadow(
                    blurRadius: 7.0,
                    color: Colors.white,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: GetBuilder<LoginController>(
                id: "textOp",
                builder: (controller) {
                  return AnimatedOpacity(
                    opacity: controller.textOp,
                    duration: const Duration(seconds: 1),
                    child: Text(controller.codeLength == 11 ? '请输入你的手机号:' : '请输入验证码:'),
                    onEnd: () {
                      controller.inOp = 1;
                      controller.update(["inOp"]);
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: GetBuilder<LoginController>(
              id: "inOp",
              builder: (controller) {
                if (controller.codeLength == 11) {
                  return AnimatedOpacity(
                    opacity: controller.inOp,
                    duration: const Duration(seconds: 1),
                    child: PinCodeTextField(
                      key: const Key("1"),
                    appContext: context,
                    length: 11,
                    keyboardType: TextInputType.number,
                    onChanged: (v) {},
                    pinTheme: PinTheme(
                        fieldWidth: (MediaQuery.of(context).size.width - 80) / 11,
                        activeColor: Colors.white,
                        selectedColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.white
                    ),
                    onCompleted: (value) {
                      // 验证手机
                      controller.validPhone(value);
                    },
                  ),
                    onEnd: () {
                      controller.register = 1;
                      controller.update(["extend"]);
                    },
                  );
                }
                return AnimatedOpacity(
                    opacity: controller.inOp,
                    duration: const Duration(seconds: 1),
                    child:PinCodeTextField(
                      key: const Key("2"),
                      appContext: globalContext,
                      length: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {},
                      pinTheme: PinTheme(
                          activeColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor,
                          inactiveColor: Colors.white
                      ),
                      onCompleted: (value) async{
                        await controller.login(value);
                      },
                    )
                  );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15),
            child: GetBuilder<LoginController>(
              id: "extend",
              builder: (controller) {
                if (controller.codeLength != 11) {
                  return Row(
                    children: [
                      GestureDetector(
                        child: Text(controller.time == 60 ? "重新发送" : "${controller.time}/s后可再次发送"),
                        onTap: () {
                          if (controller.time == 60) {
                            LimitUtil.throttle(() => controller.resend());
                          }
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          child: const Text("返回"),
                          onTap: () {
                            controller.showPhone();
                          },
                        ),
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
          )
        ],
      ),
    );
  }

}

import 'dart:async';

import 'package:book_app/log/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class LoginController extends GetxController{
  double welcome = 0;
  double textOp = 0;
  double inOp = 0;
  double register = 0;
  int codeLength = 11;
  final RegExp _regExp = RegExp(r"^1[3-9][0-9][\d]{8}$");
  TextEditingController textController = TextEditingController();
  String? phone;
  int time = 10;
  Timer? _timeDown;
  @override
  void onReady() {
    super.onReady();
    welcome = 1;
    update(["welcome"]);
  }

  void validPhone(String value) {
    if (!_regExp.hasMatch(value)) {
      EasyLoading.showToast("手机号不正确");
      return;
    }
    phone = value;
    textController.text = "";
    inOp = 0;
    textOp = 0;
    update(["textOp", "inOp"]);
    Log.i(1111);
    _timeDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      Log.i(222);
      if (time >= 1) {
        time--;
        update(["extend"]);
      } else {
        timer.cancel();
        _timeDown?.cancel();
        time = 10;
        update(["extend"]);
      }
    });
    Timer(const Duration(milliseconds: 800), () {
      codeLength = 6;
      inOp = 1;
      textOp = 1;
      update(["textOp", "inOp"]);
    });
  }

  void resend() {
    /// 重新发送验证码
    if (time != 10) {
      return;
    }
    _timeDown?.cancel();
    _timeDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time >= 1) {
        time--;
        update(["extend"]);
      } else {
        time = 10;
        _timeDown?.cancel();
        update(["extend"]);
      }
    });
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:book_app/api/login_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/util/decrypt_util.dart';
import 'package:book_app/util/rsa_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

class LoginController extends GetxController{
  double welcome = 0;
  double textOp = 0;
  double inOp = 0;
  double register = 0;
  int codeLength = 11;
  final RegExp _regExp = RegExp(r"^1[3-9][0-9][\d]{8}$");
  TextEditingController textController = TextEditingController();
  String? phone;
  int time = 60;
  Timer? _timeDown;
  @override
  void onReady() {
    super.onReady();
    RsaUtil.gen();
    welcome = 1;
    update(["welcome"]);
  }

  void validPhone(String value) async{
    if (!_regExp.hasMatch(value)) {
      EasyLoading.showToast("手机号不正确");
      return;
    }
    Log.i(RsaUtil.publicKey!.modulus);
    // Log.i(RsaUtil.publicKey!.exponent);
    var str = await LoginApi.getPublicKey(RsaUtil.publicKey!.modulus, RsaUtil.publicKey!.exponent);
    Log.i(json.decode(str)["aes"]);
    // DecryptUtil.getAes(json.decode(str)["aes"]);
    DecryptUtil.getAes(json.decode(str)["aes"]);
    // /// 数据库验证
    // phone = value;
    // textController.text = "";
    // inOp = 0;
    // textOp = 0;
    // update(["textOp", "inOp"]);
    // _timeDown = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (time >= 1) {
    //     time--;
    //     update(["extend"]);
    //   } else {
    //     timer.cancel();
    //     _timeDown?.cancel();
    //     time = 60;
    //     update(["extend"]);
    //   }
    // });
    // Timer(const Duration(milliseconds: 800), () {
    //   codeLength = 6;
    //   inOp = 1;
    //   textOp = 1;
    //   update(["textOp", "inOp"]);
    // });
  }

  void resend() {
    /// 重新发送验证码
    if (time != 60) {
      return;
    }
    _timeDown?.cancel();
    _timeDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time >= 1) {
        time--;
        update(["extend"]);
      } else {
        time = 60;
        _timeDown?.cancel();
        update(["extend"]);
      }
    });
  }
}

import 'package:book_app/module/login/login_controller.dart';
import 'package:book_app/util/size_fit_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      child: Scaffold(
        body: _body(context),
      ),
      value: SystemUiOverlayStyle.light,
    );
  }

  Widget _body(context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            color: Colors.black,
          ),
        ),
        Positioned(
          top: SizeFitUtil.setPx(MediaQuery.of(context).padding.top),
          left: 0,
          right: 0,
          child: GestureDetector(
            child: Container(
              height: SizeFitUtil.setPx(56),
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 15),
              child: Icon(Icons.close, color: Colors.white, size: 30,),
            ),
          ),
        )
      ],
    );
  }

}
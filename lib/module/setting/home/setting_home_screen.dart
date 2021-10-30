import 'package:book_app/log/log.dart';
import 'package:book_app/module/setting/home/setting_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SettingHomeScreen extends GetView<SettingHomeController>{
  const SettingHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        centerTitle: true,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Container(
        )
      ],
    );
  }
}
import 'package:book_app/log/log.dart';
import 'package:book_app/module/setting/home/setting_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SettingHomeScreen extends GetView<SettingHomeController>{
  const SettingHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Log.i(MediaQuery.of(context).padding.top);
    return MediaQuery.removeViewPadding(
      removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        context: context,
        child: Stack(
          children: [
            Positioned(
              left: 10,
              child: Icon(Icons.menu),
            )
          ],
        )
    );
  }

}
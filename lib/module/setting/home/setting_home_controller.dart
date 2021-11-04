import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingHomeController extends GetxController {
  bool isDarkModel = false;
  BuildContext context = globalContext;
  Color? backgroundColor;
  Color? textColor;
  setDarkMode(bool value) {
    if (value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    isDarkModel = value;
    update(["setting"]);
  }

  @override
  void onInit() {
    super.onInit();
    backgroundColor = Theme.of(context).textTheme.bodyText2!.color;
    textColor = Theme.of(context).textTheme.bodyText1!.color;
    isDarkModel = Get.isDarkMode;
  }

  /// 检查更新
  void checkVersion() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("1.0.7更新"),
        content: Text("1.花生地挥洒\n2.大师嘎十一点"),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            child: const Text("稍后更新", style: TextStyle(color: Colors.grey, fontSize: 16),),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("立即更新", style: TextStyle(fontSize: 16),),
            onPressed: () async {
              Log.i(33333);
              if (await Permission.storage.isGranted) {
                Log.i(11111);
                var dir = await getExternalStorageDirectory();
                DioManager.instance.download(
                    "https://github.com/woshilll/book_app/releases/download/1.0.7/1.0.7.apk",
                    "${dir!.path}/1.0.7.apk",
                    onProgress: (receive, total) {
                      EasyLoading.showProgress(receive / total, status: "下载中...");
                    }
                ).then((_) {
                  EasyLoading.dismiss();
                  OpenFile.open("${dir.path}/1.0.7.apk");
                });
                Log.i(2222);
                Navigator.pop(context);

              }
            },
          )
        ],
      );
    });
  }
}

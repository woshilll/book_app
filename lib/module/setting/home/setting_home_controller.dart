import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/api/version_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/versionUpdate/version.dart';
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
    Version newVersion = await VersionApi.getVersion();

    // if (await _checkNewVersion(newVersion.name)) {
    //   EasyLoading.showToast("已是最新版本");
    //   return;
    // }
    String versionName = newVersion.name.substring(0, newVersion.name.lastIndexOf("."));
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("$versionName更新"),
        content: Text(newVersion.description),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            child: const Text("稍后更新", style: TextStyle(color: Colors.grey, fontSize: 16),),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("立即更新", style: TextStyle(fontSize: 16),),
            onPressed: () async {
              await Permission.storage.request();
              if (await Permission.storage.isGranted) {
                var dir = await getExternalStorageDirectory();
                DioManager.instance.download(
                    newVersion.downloadUrl,
                    "${dir!.path}/${newVersion.name}",
                    onProgress: (receive, total) {
                      EasyLoading.showProgress(receive / total, status: "下载中...");
                    }
                ).then((_) {
                  EasyLoading.dismiss();
                  OpenFile.open("${dir.path}/${newVersion.name}");
                });
                Navigator.pop(context);

              }
            },
          )
        ],
      );
    });
  }

  Future<bool> _checkNewVersion(String version) async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return version.substring(0, version.lastIndexOf(".")) == packageInfo.version;
  }
}

import 'dart:io';

import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/api/version_api.dart';
import 'package:book_app/log/log.dart';
import 'package:book_app/model/versionUpdate/version.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:dio/dio.dart';
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
  bool _downloading = false;
  CancelToken? _downloadCancel;
  double _downloadProgress = 0;
  String thisVersion = "";
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
  void onInit() async{
    super.onInit();
    backgroundColor = Theme.of(context).textTheme.bodyText2!.color;
    textColor = Theme.of(context).textTheme.bodyText1!.color;
    isDarkModel = Get.isDarkMode;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    thisVersion = packageInfo.version;
    update(["setting"]);
  }

  /// 检查更新
  void checkVersion() async{
    Version newVersion = await VersionApi.getVersion();
    var dir = await getExternalStorageDirectory();
    String filePath = "${dir!.path}/${newVersion.name}";
    if (_checkNewVersion(newVersion.name)) {
      EasyLoading.showToast("已是最新版本");
      return;
    }
    File file = File(filePath);
    if (await file.exists()) {
      if (newVersion.size == file.lengthSync()) {
        /// 已下载完成
        OpenFile.open(filePath);
        return;
      }
    }
    String versionName = newVersion.name.substring(0, newVersion.name.lastIndexOf("."));
    showDialog(context: context, builder: (context) {
      return GetBuilder<SettingHomeController>(
        id: "downloading",
        builder: (controller) {
          return AlertDialog(
            title: Text("$versionName更新"),
            content:
            _downloading ?
              Container(
                height: 100,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 10,),
                    Text("${(_downloadProgress * 100).toStringAsFixed(2)}%", style: const TextStyle(color: Colors.grey, fontSize: 14),)
                  ],
                ),
              ) :
            Text(newVersion.description)
            ,
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              TextButton(
                child: Text(_downloading ? "取消下载" : "稍后更新", style: const TextStyle(color: Colors.grey, fontSize: 16),),
                onPressed: () {
                  if (_downloading) {
                    _downloadCancel?.cancel("取消下载");
                    _downloading = false;
                    _downloadProgress = 0;
                  }
                  Navigator.of(context).pop();
                },
              ),
              if (!_downloading)
              TextButton(
                child: const Text("立即更新", style: TextStyle(fontSize: 16),),
                onPressed: () async {
                  await Permission.storage.request();
                  if (await Permission.storage.isGranted) {
                    _downloadCancel = CancelToken();
                    _downloading = true;
                    update(["downloading"]);
                    DioManager.instance.download(
                        newVersion.downloadUrl,
                        filePath,
                        onProgress: (receive, total) {
                          _downloadProgress = receive / total;
                          update(["downloading"]);
                        },
                        cancelToken: _downloadCancel
                    ).then((_) {
                      Navigator.of(context).pop();
                      OpenFile.open("${dir.path}/${newVersion.name}").then((openRes) {
                        Log.i(openRes.type);
                        if (openRes.type == ResultType.permissionDenied) {
                          EasyLoading.showToast("安装失败");
                        }
                      });
                    }).catchError((error) {
                      if (error != null) {
                        EasyLoading.showToast(error.message);
                      } else {
                        EasyLoading.showToast("下载失败");
                      }
                      _downloadCancel?.cancel();
                      _downloading = false;
                      _downloadProgress = 0;
                    });
                  }
                },
              )
            ],
          );
        },
      );
    });
  }

  bool _checkNewVersion(String version) {
    return version.substring(0, version.lastIndexOf(".")) == thisVersion;
  }
}

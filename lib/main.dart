import 'dart:io';
import 'dart:ui';

import 'package:book_app/app_binding.dart';
import 'package:book_app/app_controller.dart';
import 'package:book_app/di.dart';
import 'package:book_app/lang/lang_service.dart';
import 'package:book_app/route/route_pages.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/theme.dart';
import 'package:book_app/util/bar_util.dart';
import 'package:book_app/util/constant.dart';
import 'package:book_app/util/save_util.dart';
import 'package:book_app/util/system_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const App());
  transparentBar();
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(AppController());
    String initRoute = Routes.splash;
    var splashTrue = SaveUtil.getTrue(Constant.splashTrue);
    if (splashTrue != null && splashTrue) {
      // 去默认页
      initRoute = SaveUtil.getString(Constant.initRoute) ?? Routes.home;
    }
    return GetBuilder<AppController>(
      id: "fullScreen",
      builder: (controller) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(controller.screenColor, controller.screenColorModel),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            enableLog: true,
            initialRoute: initRoute,
            defaultTransition: Transition.fade,
            getPages: RoutePages.routes,
            initialBinding: AppBinding(),
            smartManagement: SmartManagement.keepFactory,
            title: '小小说',
            locale: LangService.locale,
            fallbackLocale: LangService.fallbackLocale,
            translations: LangService(),
            theme: ThemeConfig.lightTheme,
            builder: EasyLoading.init(),
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.light,
          ),
        );
      },
    );
  }
}


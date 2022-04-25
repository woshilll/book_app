import 'package:book_app/app_binding.dart';
import 'package:book_app/app_controller.dart';
import 'package:book_app/di.dart';
import 'package:book_app/route/route_pages.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/util/bar_util.dart';
import 'package:flutter/material.dart';
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
    return GetBuilder<AppController>(
      id: "fullScreen",
      builder: (controller) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(controller.screenColor, controller.screenColorModel),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            enableLog: true,
            initialRoute: Routes.bookHome,
            defaultTransition: Transition.rightToLeft,
            getPages: RoutePages.routes,
            initialBinding: AppBinding(),
            smartManagement: SmartManagement.keepFactory,
            title: '轻阅读',
            builder: EasyLoading.init(),
          ),
        );
      },
    );
  }
}


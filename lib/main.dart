import 'package:book_app/app_binding.dart';
import 'package:book_app/di.dart';
import 'package:book_app/lang/lang_service.dart';
import 'package:book_app/route/route_pages.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      enableLog: true,
      initialRoute: Routes.splash,
      defaultTransition: Transition.fade,
      getPages: RoutePages.routes,
      initialBinding: AppBinding(),
      smartManagement: SmartManagement.keepFactory,
      title: 'Flutter Demo',
      locale: LangService.locale,
      fallbackLocale: LangService.fallbackLocale,
      translations: LangService(),
      theme: ThemeConfig.lightTheme,
      builder: EasyLoading.init(),
    );
  }
}


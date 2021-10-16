import 'package:book_app/module/home/home_binding.dart';
import 'package:book_app/module/home/home_screen.dart';
import 'package:book_app/route/routes.dart';
import 'package:book_app/splash/splash_binding.dart';
import 'package:book_app/splash/splash_screen.dart';
import 'package:get/get.dart';

class RoutePages {
  static const initial = Routes.splash;
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding()
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding()
    )
  ];
}

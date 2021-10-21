import 'package:book_app/module/book/home/book_home_binding.dart';
import 'package:book_app/module/book/home/book_home_screen.dart';
import 'package:book_app/module/book/read/read_binding.dart';
import 'package:book_app/module/book/read/read_screen.dart';
import 'package:book_app/module/book/search/search_binding.dart';
import 'package:book_app/module/book/search/search_screen.dart';
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
    ),
    GetPage(
        name: Routes.bookHome,
        page: () => const BookHomeScreen(),
        binding: BookHomeBinding()
    ),
    GetPage(
        name: Routes.read,
        page: () => const ReadScreen(),
        binding: ReadBinding()
    ),
    GetPage(
        name: Routes.search,
        page: () => const SearchScreen(),
        binding: SearchBinding()
    )
  ];
}

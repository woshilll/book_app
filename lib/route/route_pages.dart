import 'package:book_app/module/book/home/book_home_binding.dart';
import 'package:book_app/module/book/home/book_home_screen.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_binding.dart';
import 'package:book_app/module/book/readMoreSetting/read_more_setting_screen.dart';
import 'package:book_app/module/book/readSetting/read_setting_binding.dart';
import 'package:book_app/module/book/readSetting/read_setting_screen.dart';
import 'package:book_app/module/book/read/read_binding.dart';
import 'package:book_app/module/book/read/read_screen.dart';
import 'package:book_app/module/book/search/search_binding.dart';
import 'package:book_app/module/book/search/search_screen.dart';
import 'package:book_app/module/book/searchValue/component/search_value_view_binding.dart';
import 'package:book_app/module/book/searchValue/component/search_value_view_screen.dart';
import 'package:book_app/module/book/searchValue/search_value_binding.dart';
import 'package:book_app/module/book/searchValue/search_value_screen.dart';
import 'package:book_app/module/home/home_binding.dart';
import 'package:book_app/module/home/home_screen.dart';
import 'package:book_app/module/login/login_binding.dart';
import 'package:book_app/module/login/login_screen.dart';
import 'package:book_app/module/setting/home/setting_home_binding.dart';
import 'package:book_app/module/setting/home/setting_home_screen.dart';
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
        name: Routes.login,
        page: () => const LoginScreen(),
        binding: LoginBinding()
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
        name: Routes.readSetting,
        page: () => const ReadSettingScreen(),
        binding: ReadSettingBinding()
    ),
    GetPage(
        name: Routes.readMoreSetting,
        page: () => ReadMoreSettingScreen(),
        binding: ReadMoreSettingBinding()
    ),
    GetPage(
        name: Routes.search,
        page: () => const SearchScreen(),
        binding: SearchBinding()
    ),
    GetPage(
        name: Routes.searchValue,
        page: () => const SearchValueScreen(),
        binding: SearchValueBinding()
    ),
    GetPage(
        name: Routes.searchValueView,
        page: () => const SearchValueViewScreen(),
        binding: SearchValueViewBinding()
    ),









    GetPage(
        name: Routes.settingHome,
        page: () => const SettingHomeScreen(),
        binding: SettingHomeBinding()
    )
  ];
}

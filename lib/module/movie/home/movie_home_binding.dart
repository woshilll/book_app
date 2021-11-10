import 'package:book_app/module/movie/home/movie_home_controller.dart';
import 'package:get/get.dart';

class MovieHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MovieHomeController>(() => MovieHomeController());
  }

}

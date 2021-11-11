import 'package:book_app/module/movie/info/movie_info_controller.dart';
import 'package:get/get.dart';

class MovieInfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MovieInfoController());
  }

}

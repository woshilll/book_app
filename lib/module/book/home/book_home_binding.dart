import 'package:get/get.dart';

import 'book_home_controller.dart';


class BookHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookHomeController>(() => BookHomeController());
  }

}

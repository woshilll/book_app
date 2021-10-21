import 'package:book_app/module/book/search/serach_controller.dart';
import 'package:get/get.dart';

class SearchBinding implements Bindings {

  @override
  void dependencies() {
    Get.put<SearchController>(SearchController());
  }

}

import 'package:book_app/module/book/searchValue/search_value_controller.dart';
import 'package:get/get.dart';

class SearchValueBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SearchValueController>(SearchValueController());
  }

}
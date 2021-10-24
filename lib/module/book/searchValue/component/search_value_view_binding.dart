import 'package:book_app/module/book/searchValue/component/search_value_view_controller.dart';
import 'package:get/get.dart';

class SearchValueViewBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<SearchValueViewController>(SearchValueViewController());
  }

}
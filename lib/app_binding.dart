import 'package:book_app/api/api_export.dart';
import 'package:get/get.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiProvider(), permanent: true);
    Get.put(ApiRepository(apiProvider: Get.find()), permanent: true);
  }

}

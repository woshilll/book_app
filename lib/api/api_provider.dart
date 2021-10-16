import 'package:book_app/api/base_provider.dart';
import 'package:get/get.dart';

class ApiProvider extends BaseProvider {
  Future<Response> getInfo(String path) {
    return get(path);
  }
}

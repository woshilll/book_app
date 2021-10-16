import 'package:get/get.dart';
import 'api_export.dart';

class BaseProvider extends GetConnect {

  @override
  void onInit() {
    httpClient.baseUrl = "";
    httpClient.addAuthenticator(authInterceptor);
    httpClient.addRequestModifier(requestInterceptor);
    httpClient.addResponseModifier(responseInterceptor);
  }
}

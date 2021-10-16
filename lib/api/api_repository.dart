
import 'package:book_app/api/api_provider.dart';

class ApiRepository {
  ApiRepository({required this.apiProvider});
  final ApiProvider apiProvider;
  void getInfo() async {
    final res = await apiProvider.getInfo("api");
  }
}

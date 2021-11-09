import 'package:book_app/api/dio/dio_manager.dart';

class LoginApi {
  /// 获取版本
  static Future<dynamic> getPublicKey(modulus, exponent) async{
    return await DioManager.instance.get<dynamic>(url: "/login/publicKey", params: {"modulus": modulus, "exponent": exponent});
  }


}

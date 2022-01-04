import 'package:book_app/api/dio/dio_manager.dart';
import 'package:book_app/util/rsa_util.dart';

class LoginApi {
  /// 获取服务器公钥
  static Future<dynamic> getPublicKey() async{
    return await DioManager.instance.get(url: "/login/publicKey", params: RsaUtil.getPublicParams(), showLoading: false);
  }

  /// 发送短信验证码
  static Future<dynamic> sendSms(phone, device) async{
    return await DioManager.instance.get(url: "/login/send/$phone/$device");
  }

  /// 验证token
  static Future<dynamic> validToken(device) async{
    return await DioManager.instance.get(url: "/login/token/$device");
  }

  /// 登录
  static Future<dynamic> login(body) async{
    return await DioManager.instance.post(url: "/login", body: body, params: RsaUtil.getPublicParams(), encrypt: true);
  }


}

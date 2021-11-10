// ignore: implementation_imports
import 'package:book_app/api/login_api.dart';
import 'package:book_app/log/log.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import "package:pointycastle/export.dart";


class RsaUtil {
  static RSAPublicKey? publicKey;
  static RSAPrivateKey? privateKey;
  static String? serverPublicKey;
  static gen() {
    final keyGen = KeyGenerator("RSA");
    final rsaParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64);
    final paramsWithRnd = ParametersWithRandom(rsaParams, secureRandom());
    keyGen.init(paramsWithRnd);
    final pair = keyGen.generateKeyPair();
    publicKey = pair.publicKey as RSAPublicKey;
    privateKey = pair.privateKey as RSAPrivateKey;
  }

  static SecureRandom secureRandom() {

    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(
          Platform.instance.platformEntropySource().getBytes(32)));
    return secureRandom;
  }

  static getServerPublicKey() async{
    var publicKey = await LoginApi.getPublicKey();
    RsaUtil.serverPublicKey = publicKey;
  }

  static dynamic getPublicParams() => {
    "modulus": RsaUtil.publicKey!.modulus,
    "exponent": RsaUtil.publicKey!.publicExponent
  };
}

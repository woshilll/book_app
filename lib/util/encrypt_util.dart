import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:book_app/log/log.dart';
import 'package:book_app/util/rsa_util.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class EncryptUtil {
  static String _genAes() {
    final random = Random();
    String aes = "";
    for(int i = 0; i < 16; i++) {
      int type = random.nextInt(3);
      switch (type) {
        case 0:
          aes += random.nextInt(10).toString();
          break;
        case 1:
          aes += String.fromCharCode(random.nextInt(25) + 65);
          break;
        case 2:
          aes += String.fromCharCode(random.nextInt(25) + 97);
          break;
        default:
          break;
      }
    }
    return aes;
  }

  static dynamic encryptData(data) {
    String aes = _genAes();
    final encrypt = Encrypter(AES(Key.fromUtf8(aes), mode: AESMode.ecb));
    final encryptData = encrypt.encrypt(json.encode(data), iv: IV.fromUtf8(aes)).base64;
    final encryptAes = _encryptAes(aes);
    return [encryptData, encryptAes];
  }

  static String _encryptAes(String aes) {
    String rsaPublic = "-----BEGIN PUBLIC KEY-----\n${RsaUtil.serverPublicKey!.replaceAll("\"", "")}\n-----END PUBLIC KEY-----";
    RSAPublicKey publicKey =  RSAKeyParser().parse(rsaPublic) as RSAPublicKey;
    final encrypt = Encrypter(RSA(publicKey: publicKey));
    return encrypt.encrypt(aes).base64;
  }
}

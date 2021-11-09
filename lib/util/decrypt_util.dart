import 'dart:convert';
import 'dart:typed_data';

import 'package:book_app/log/log.dart';
import 'package:book_app/util/rsa_util.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class DecryptUtil {
  static getAes(String aes) {
    RSAPublicKey publicKey = RSAPublicKey(RsaUtil.publicKey!.modulus!, RsaUtil.publicKey!.exponent!);
    RSAPrivateKey privateKey = RSAPrivateKey(RsaUtil.privateKey!.modulus!, RsaUtil.privateKey!.exponent!, RsaUtil.privateKey!.p!, RsaUtil.privateKey!.q!);
    final encrypt = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
    Log.i(encrypt.encrypt("12345678").base64);
    Uint8List sourceBytes = base64Decode(aes);
    int inputLen = sourceBytes.length;
    int maxLen = 245;
    List<int> totalBytes = [];
    for (var i = 0; i < inputLen; i += maxLen) {
      int endLen = inputLen - i;
      Uint8List item;
      if (endLen > maxLen) {
        item = sourceBytes.sublist(i, i + maxLen);
      } else {
        item = sourceBytes.sublist(i, i + endLen);
      }
      totalBytes.addAll(encrypt.decryptBytes(Encrypted(item)));
    }
    Log.i(utf8.decode(totalBytes));
  }
}

const String empty = r"^$";
const String phone = r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$";
const String email = r"^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$";


RegExp phoneReg = RegExp(phone);
RegExp emptyReg = RegExp(empty);
RegExp emailReg = RegExp(email);


String? phoneValidator(String? value) {
  if (value == null) {
    return null;
  }
  if (emptyReg.hasMatch(value) || phoneReg.hasMatch(value)) {
    return null;
  }
  return "手机号不正确";
}

String? emailValidator(String? value) {
  if (value == null) {
    return null;
  }
  if (emptyReg.hasMatch(value) || emailReg.hasMatch(value)) {
    return null;
  }
  return "邮箱不正确";
}

String? lengthValidator(String? value, int min, int max) {
  if (value == null) {
    return "长度不能为空";
  }
  if (value.length < min || value.length > max) {
    return "长度需在$min - $max";
  }
  return null;
}
import 'package:flutter/services.dart';

class RegInputFormatter extends TextInputFormatter {
  RegInputFormatter(this.regExp);
  final String regExp;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (RegExp(regExp).firstMatch(newValue.text) != null) {
        return newValue;
      }
      return oldValue;
    }
    return newValue;
  }

}
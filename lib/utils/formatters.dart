import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length <= 2) {
        formatted = '($digitsOnly';
      } else if (digitsOnly.length <= 7) {
        formatted = '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2)}';
      } else if (digitsOnly.length <= 11) {
        formatted =
            '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
      } else {
        formatted =
            '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7, 11)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
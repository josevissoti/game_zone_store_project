import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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

class CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return TextEditingValue.empty;
    }

    final value = int.parse(digitsOnly) / 100;
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );

    return TextEditingValue(
      text: formatter.format(value),
      selection: TextSelection.collapsed(
        offset: formatter.format(value).length,
      ),
    );
  }

  static String format(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  static double parse(String formatted) {
    final digitsOnly = formatted.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.');
    return double.tryParse(digitsOnly) ?? 0.0;
  }
}

class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';

    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length <= 2) {
        formatted = digitsOnly;
      } else if (digitsOnly.length <= 4) {
        formatted = '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
      } else if (digitsOnly.length <= 8) {
        formatted =
            '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2, 4)}/${digitsOnly.substring(4)}';
      } else {
        formatted =
            '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2, 4)}/${digitsOnly.substring(4, 8)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String format(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static DateTime? parse(String formatted) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(formatted);
    } catch (_) {
      return null;
    }
  }
}
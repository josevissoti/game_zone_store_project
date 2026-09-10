class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return 'Nome deve conter apenas letras';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefone é obrigatório';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Telefone inválido (10 ou 11 dígitos)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter no mínimo 8 caracteres';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Senha deve conter letra minúscula';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Senha deve conter letra maiúscula';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Senha deve conter número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Senha deve conter símbolo (!@#\$%^&*)';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    if (value != password) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static String? validateGameName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome do jogo é obrigatório';
    }
    if (value.trim().length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Nome deve ter no máximo 100 caracteres';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Preço é obrigatório';
    }
    // Remove R\$, spaces, thousand separators, replace comma with dot
    String cleanValue = value.trim();
    cleanValue = cleanValue.replaceAll(r'R$', '');
    cleanValue = cleanValue.replaceAll(' ', '');
    cleanValue = cleanValue.replaceAll('.', '');
    cleanValue = cleanValue.replaceAll(',', '.');
    final price = double.tryParse(cleanValue);
    if (price == null) {
      return 'Preço inválido';
    }
    if (price <= 0) {
      return 'Preço deve ser maior que zero';
    }
    if (price > 999999.99) {
      return 'Preço muito alto';
    }
    return null;
  }

  static String? validateReleaseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Data de publicação é obrigatória';
    }
    final parts = value.trim().split('/');
    if (parts.length != 3) {
      return 'Data inválida (use dd/mm/aaaa)';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida';
    }
    try {
      final date = DateTime(year, month, day);
      if (date.isAfter(DateTime.now().add(const Duration(days: 365 * 10)))) {
        return 'Data muito distante no futuro';
      }
      return null;
    } catch (_) {
      return 'Data inválida';
    }
  }

  static String? validateCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Empresa é obrigatória';
    }
    if (value.trim().length < 2) {
      return 'Empresa deve ter pelo menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Empresa deve ter no máximo 100 caracteres';
    }
    return null;
  }

  static String? validateGenre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Gênero é obrigatório';
    }
    if (value.trim().length < 2) {
      return 'Gênero deve ter pelo menos 2 caracteres';
    }
    if (value.trim().length > 50) {
      return 'Gênero deve ter no máximo 50 caracteres';
    }
    return null;
  }
}
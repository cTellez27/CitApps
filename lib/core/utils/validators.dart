/// Form validation utilities for CitApps.
library;

abstract class Validators {
  /// Validates that a value is not null or empty.
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional field
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  /// Validates that email is present and valid.
  static String? emailRequired(String? value) {
    final req = required(value, 'El correo');
    if (req != null) return req;
    return email(value);
  }

  /// Validates password strength.
  static String? password(String? value) {
    final req = required(value, 'La contraseña');
    if (req != null) return req;
    if (value!.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe contener al menos una letra mayúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  /// Validates that two passwords match.
  static String? confirmPassword(String? value, String password) {
    final req = required(value, 'La confirmación');
    if (req != null) return req;
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Validates phone number format.
  static String? phone(String? value) {
    final req = required(value, 'El teléfono');
    if (req != null) return req;
    final cleaned = value!.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Ingresa un número de teléfono válido';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'El teléfono solo debe contener números';
    }
    return null;
  }

  /// Validates that a number is positive.
  static String? positiveNumber(String? value, [String fieldName = 'El valor']) {
    final req = required(value, fieldName);
    if (req != null) return req;
    final number = double.tryParse(value!);
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }
    if (number <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    return null;
  }

  /// Validates that a number is non-negative (>= 0).
  static String? nonNegativeNumber(String? value, [String fieldName = 'El valor']) {
    final req = required(value, fieldName);
    if (req != null) return req;
    final number = double.tryParse(value!);
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }
    if (number < 0) {
      return '$fieldName no puede ser negativo';
    }
    return null;
  }

  /// Validates that duration is a multiple of 15 minutes.
  static String? duration(String? value) {
    final req = positiveNumber(value, 'La duración');
    if (req != null) return req;
    final minutes = int.tryParse(value!);
    if (minutes == null || minutes < 15) {
      return 'La duración mínima es 15 minutos';
    }
    if (minutes % 15 != 0) {
      return 'La duración debe ser múltiplo de 15 minutos';
    }
    return null;
  }
}

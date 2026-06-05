import 'package:physical_activity_log_app/constants/input_limits.dart';

abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (trimmed.length < InputLimits.nameMin) {
      return 'El nombre debe tener al menos ${InputLimits.nameMin} caracteres';
    }
    if (trimmed.length > InputLimits.nameMax) {
      return 'El nombre no puede superar ${InputLimits.nameMax} caracteres';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'El email es obligatorio';
    }
    if (trimmed.length > InputLimits.emailMax) {
      return 'El email no puede superar ${InputLimits.emailMax} caracteres';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (text.length < InputLimits.passwordMin) {
      return 'La contraseña debe tener al menos ${InputLimits.passwordMin} caracteres';
    }
    if (text.length > InputLimits.passwordMax) {
      return 'La contraseña no puede superar ${InputLimits.passwordMax} caracteres';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final error = Validators.password(value);
    if (error != null) {
      return error;
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}

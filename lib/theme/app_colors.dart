import 'package:flutter/material.dart';

/// Paleta alineada con el icono de la app (azul vibrante y tonos metálicos).
abstract final class AppColors {
  /// Azul principal de marca (tono central del icono).
  static const Color primary = Color(0xFF0060E0);

  /// Azul vibrante para botones, enlaces y detalles destacados.
  static const Color accent = Color(0xFF0080F0);

  /// Cian brillante para reflejos y acentos secundarios.
  static const Color highlight = Color(0xFF30C8F8);

  /// Azul profundo para gradientes (esquinas del icono).
  static const Color primaryDark = Color(0xFF003BC1);

  /// Azul medio-oscuro para transiciones de gradiente.
  static const Color primaryDeep = Color(0xFF004FD8);

  /// Gris metálico / acero (tonos plateados de la mancuerna).
  static const Color steelGrey = Color(0xFFB0C4DE);

  /// Placa de pesas — plateado más oscuro.
  static const Color plateGrey = Color(0xFF8899B0);

  /// Fondo general de pantallas con ligero tinte azul.
  static const Color screenBackground = Color(0xFFF0F5FC);

  static const Color inputBorder = Color(0xFFC8D8EC);
  static const Color placeholderGrey = Color(0xFF94A3B8);
  static const Color bodyTextGrey = Color(0xFF64748B);
  static const Color dividerGrey = Color(0xFFD1DEEF);
}

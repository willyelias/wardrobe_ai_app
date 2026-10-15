import 'package:flutter/material.dart';

/// Paleta de cores minimalista com inspiração nos padrões de design da Apple (iOS / macOS).
/// Foco em superfícies limpas, off-white, contrastes elegantes e tipografia refinada.
class AppColors {
  AppColors._();

  // Cores de Fundo e Superfícies
  static const Color background = Color(0xFFF9F9FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF2F2F7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Bordas e Divisores
  static const Color border = Color(0xFFE5E5EA);
  static const Color borderSubtle = Color(0xFFF0F0F2);
  static const Color divider = Color(0xFFE5E5EA);

  // Textos e Tipografia (Hierarquia Apple)
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF636366);
  static const Color textTertiary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFFFFFFF);

  // Acentos & Destaques (Monocromático sofisticado)
  static const Color primary = Color(0xFF1C1C1E);
  static const Color primaryLight = Color(0xFF2C2C2E);
  static const Color accent = Color(0xFF007AFF); // Apple Blue sutil para interações
  static const Color goldAccent = Color(0xFFD4AF37); // Para IA / Premium

  // Status & Tags
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);

  // Sombras suaves
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

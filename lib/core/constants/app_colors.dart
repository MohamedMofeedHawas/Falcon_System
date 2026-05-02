import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF0D2B6B); // نيلي عسكري غامق
  static const Color secondary = Color(0xFFC9A84C); // ذهبي
  static const Color accent = Color(0xFF1E5FA8); // أزرق ملكي

  // Background Colors
  static const Color background = Color(0xFFF4F6FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color sidebarBg = Color(0xFF0A1F4E);
  static const Color sidebarActive = Color(0xFFC9A84C);

  // Status Colors
  static const Color danger = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF0288D1);

  // Evaluation Colors
  static const Color excellent = Color(0xFF2E7D32); // ≥90%
  static const Color good = Color(0xFF1976D2); // 75-89%
  static const Color acceptable = Color(0xFFF57C00); // 60-74%
  static const Color unsafe = Color(0xFFD32F2F); // <60%

  // Slider Colors
  static const Color sliderRed = Color(0xFFD32F2F); // 0-4
  static const Color sliderOrange = Color(0xFFF57C00); // 5-6
  static const Color sliderYellow = Color(0xFFFBC02D); // 7-8
  static const Color sliderGreen = Color(0xFF2E7D32); // 9-10

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = Color(0xFF0D2B6B);
  static const Color borderError = Color(0xFFD32F2F);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D2B6B), Color(0xFF1E5FA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC9A84C), Color(0xFFE8C568)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

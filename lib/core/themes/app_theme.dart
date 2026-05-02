import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.card,
        error: AppColors.danger,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textWhite,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.tajawal,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _dialogTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      drawerTheme: _drawerTheme,
      dividerTheme: _dividerTheme,
      chipTheme: _chipTheme,
      sliderTheme: _sliderTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      tabBarTheme: _tabBarTheme,
      bottomSheetTheme: _bottomSheetTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: const Color(0xFF1E1E1E),
        error: AppColors.danger,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textWhite,
        onError: AppColors.textWhite,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: AppFonts.tajawal,
      textTheme: _darkTextTheme,
      appBarTheme: _darkAppBarTheme,
      cardTheme: _darkCardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _darkInputDecorationTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      snackBarTheme: _snackBarTheme,
      dialogTheme: _darkDialogTheme,
      bottomNavigationBarTheme: _darkBottomNavigationBarTheme,
      drawerTheme: _darkDrawerTheme,
      dividerTheme: _dividerTheme,
      chipTheme: _chipTheme,
      sliderTheme: _sliderTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      tabBarTheme: _darkTabBarTheme,
      bottomSheetTheme: _darkBottomSheetTheme,
    );
  }

  // Text Theme - Light
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppFonts.headline1.copyWith(color: AppColors.textPrimary),
      displayMedium: AppFonts.headline2.copyWith(color: AppColors.textPrimary),
      displaySmall: AppFonts.headline3.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppFonts.headline4.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppFonts.headline5.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppFonts.headline6.copyWith(color: AppColors.textPrimary),
      titleLarge: AppFonts.titleLarge.copyWith(color: AppColors.textPrimary),
      titleMedium: AppFonts.titleMedium.copyWith(color: AppColors.textPrimary),
      titleSmall: AppFonts.titleSmall.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppFonts.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
      bodySmall: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
      labelLarge: AppFonts.labelLarge.copyWith(color: AppColors.textPrimary),
      labelMedium: AppFonts.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      labelSmall: AppFonts.labelSmall.copyWith(color: AppColors.textHint),
    );
  }

  // Text Theme - Dark
  static TextTheme get _darkTextTheme {
    return TextTheme(
      displayLarge: AppFonts.headline1.copyWith(color: AppColors.textWhite),
      displayMedium: AppFonts.headline2.copyWith(color: AppColors.textWhite),
      displaySmall: AppFonts.headline3.copyWith(color: AppColors.textWhite),
      headlineLarge: AppFonts.headline4.copyWith(color: AppColors.textWhite),
      headlineMedium: AppFonts.headline5.copyWith(color: AppColors.textWhite),
      headlineSmall: AppFonts.headline6.copyWith(color: AppColors.textWhite),
      titleLarge: AppFonts.titleLarge.copyWith(color: AppColors.textWhite),
      titleMedium: AppFonts.titleMedium.copyWith(color: AppColors.textWhite),
      titleSmall: AppFonts.titleSmall.copyWith(color: AppColors.textWhite),
      bodyLarge: AppFonts.bodyLarge.copyWith(color: AppColors.textWhite),
      bodyMedium: AppFonts.bodyMedium.copyWith(color: AppColors.textWhite),
      bodySmall: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
      labelLarge: AppFonts.labelLarge.copyWith(color: AppColors.textWhite),
      labelMedium: AppFonts.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      labelSmall: AppFonts.labelSmall.copyWith(color: AppColors.textHint),
    );
  }

  // AppBar Theme - Light
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      titleTextStyle: AppFonts.headline5.copyWith(color: AppColors.textWhite),
      iconTheme: const IconThemeData(color: AppColors.textWhite),
      actionsIconTheme: const IconThemeData(color: AppColors.textWhite),
    );
  }

  // AppBar Theme - Dark
  static AppBarTheme get _darkAppBarTheme {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.sidebarBg,
      foregroundColor: AppColors.textWhite,
      titleTextStyle: AppFonts.headline5.copyWith(color: AppColors.textWhite),
      iconTheme: const IconThemeData(color: AppColors.textWhite),
      actionsIconTheme: const IconThemeData(color: AppColors.textWhite),
    );
  }

  // Card Theme - Light
  static CardThemeData get _cardTheme {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Card Theme - Dark
  static CardThemeData get _darkCardTheme {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppFonts.titleMedium,
        minimumSize: const Size(120, 52),
      ),
    );
  }

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppFonts.labelLarge,
      ),
    );
  }

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppFonts.titleMedium,
        minimumSize: const Size(120, 52),
      ),
    );
  }

  // Input Decoration Theme - Light
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderError, width: 2),
      ),
      labelStyle: AppFonts.labelMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppFonts.labelMedium.copyWith(color: AppColors.textHint),
      errorStyle: AppFonts.labelSmall.copyWith(color: AppColors.danger),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    );
  }

  // Input Decoration Theme - Dark
  static InputDecorationTheme get _darkInputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderError, width: 2),
      ),
      labelStyle: AppFonts.labelMedium.copyWith(color: AppColors.textSecondary),
      hintStyle: AppFonts.labelMedium.copyWith(color: AppColors.textHint),
      errorStyle: AppFonts.labelSmall.copyWith(color: AppColors.danger),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    );
  }

  // Floating Action Button Theme
  static FloatingActionButtonThemeData get _floatingActionButtonTheme {
    return FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      iconSize: 24,
    );
  }

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme {
    return SnackBarThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
      contentTextStyle: AppFonts.labelLarge.copyWith(
        color: AppColors.textWhite,
      ),
      actionTextColor: AppColors.secondary,
    );
  }

  // Dialog Theme - Light
  static DialogThemeData get _dialogTheme {
    return DialogThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.card,
      titleTextStyle: AppFonts.headline5.copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppFonts.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  // Dialog Theme - Dark
  static DialogThemeData get _darkDialogTheme {
    return DialogThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1E1E1E),
      titleTextStyle: AppFonts.headline5.copyWith(color: AppColors.textWhite),
      contentTextStyle: AppFonts.bodyMedium.copyWith(
        color: AppColors.textWhite,
      ),
    );
  }

  // Bottom Navigation Bar Theme - Light
  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      elevation: 8,
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppFonts.labelMedium,
      unselectedLabelStyle: AppFonts.labelSmall,
      type: BottomNavigationBarType.fixed,
    );
  }

  // Bottom Navigation Bar Theme - Dark
  static BottomNavigationBarThemeData get _darkBottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      elevation: 8,
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppFonts.labelMedium,
      unselectedLabelStyle: AppFonts.labelSmall,
      type: BottomNavigationBarType.fixed,
    );
  }

  // Drawer Theme - Light
  static DrawerThemeData get _drawerTheme {
    return DrawerThemeData(
      elevation: 4,
      backgroundColor: AppColors.sidebarBg,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
    );
  }

  // Drawer Theme - Dark
  static DrawerThemeData get _darkDrawerTheme {
    return DrawerThemeData(
      elevation: 4,
      backgroundColor: AppColors.sidebarBg,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
    );
  }

  // Divider Theme
  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    );
  }

  // Chip Theme
  static ChipThemeData get _chipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary.withOpacity(0.1),
      disabledColor: AppColors.border,
      labelStyle: AppFonts.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  // Slider Theme
  static SliderThemeData get _sliderTheme {
    return SliderThemeData(
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withOpacity(0.1),
      valueIndicatorColor: AppColors.primary,
      valueIndicatorTextStyle: AppFonts.labelMedium.copyWith(
        color: AppColors.textWhite,
      ),
    );
  }

  // Progress Indicator Theme
  static ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
    );
  }

  // Tab Bar Theme - Light
  static TabBarThemeData get _tabBarTheme {
    return TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppFonts.labelLarge,
      unselectedLabelStyle: AppFonts.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(color: AppColors.primary, width: 3),
        insets: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // Tab Bar Theme - Dark
  static TabBarThemeData get _darkTabBarTheme {
    return TabBarThemeData(
      labelColor: AppColors.secondary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppFonts.labelLarge,
      unselectedLabelStyle: AppFonts.labelMedium,
      indicator: UnderlineTabIndicator(
        borderSide: const BorderSide(color: AppColors.secondary, width: 3),
        insets: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // Bottom Sheet Theme - Light
  static BottomSheetThemeData get _bottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    );
  }

  // Bottom Sheet Theme - Dark
  static BottomSheetThemeData get _darkBottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 8,
    );
  }
}

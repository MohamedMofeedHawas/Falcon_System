import 'package:flutter/material.dart';

class AppFonts {
  // Font Families
  static const String tajawal = 'Tajawal';
  static const String amiri = 'Amiri';

  // Font Weights
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Font Sizes
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize40 = 40.0;
  static const double fontSize48 = 48.0;

  // Font Styles
  static const TextStyle tajawalExtraLight = TextStyle(
    fontFamily: tajawal,
    fontWeight: extraLight,
  );

  static const TextStyle tajawalLight = TextStyle(
    fontFamily: tajawal,
    fontWeight: light,
  );

  static const TextStyle tajawalRegular = TextStyle(
    fontFamily: tajawal,
    fontWeight: regular,
  );

  static const TextStyle tajawalMedium = TextStyle(
    fontFamily: tajawal,
    fontWeight: medium,
  );

  static const TextStyle tajawalSemiBold = TextStyle(
    fontFamily: tajawal,
    fontWeight: semiBold,
  );

  static const TextStyle tajawalBold = TextStyle(
    fontFamily: tajawal,
    fontWeight: bold,
  );

  static const TextStyle tajawalExtraBold = TextStyle(
    fontFamily: tajawal,
    fontWeight: extraBold,
  );

  static const TextStyle tajawalBlack = TextStyle(
    fontFamily: tajawal,
    fontWeight: black,
  );

  static const TextStyle amiriRegular = TextStyle(
    fontFamily: amiri,
    fontWeight: regular,
  );

  static const TextStyle amiriBold = TextStyle(
    fontFamily: amiri,
    fontWeight: bold,
  );

  // Common Text Styles
  static TextStyle get headline1 =>
      tajawalExtraBold.copyWith(fontSize: fontSize36, height: 1.2);

  static TextStyle get headline2 =>
      tajawalExtraBold.copyWith(fontSize: fontSize32, height: 1.2);

  static TextStyle get headline3 =>
      tajawalBold.copyWith(fontSize: fontSize28, height: 1.3);

  static TextStyle get headline4 =>
      tajawalBold.copyWith(fontSize: fontSize24, height: 1.3);

  static TextStyle get headline5 =>
      tajawalSemiBold.copyWith(fontSize: fontSize20, height: 1.4);

  static TextStyle get headline6 =>
      tajawalSemiBold.copyWith(fontSize: fontSize18, height: 1.4);

  static TextStyle get bodyLarge =>
      tajawalRegular.copyWith(fontSize: fontSize16, height: 1.5);

  static TextStyle get bodyMedium =>
      tajawalRegular.copyWith(fontSize: fontSize14, height: 1.5);

  static TextStyle get bodySmall =>
      tajawalRegular.copyWith(fontSize: fontSize12, height: 1.5);

  static TextStyle get labelLarge =>
      tajawalMedium.copyWith(fontSize: fontSize14, height: 1.4);

  static TextStyle get labelMedium =>
      tajawalMedium.copyWith(fontSize: fontSize12, height: 1.4);

  static TextStyle get labelSmall =>
      tajawalMedium.copyWith(fontSize: fontSize10, height: 1.4);

  static TextStyle get titleLarge =>
      tajawalBold.copyWith(fontSize: fontSize22, height: 1.3);

  static TextStyle get titleMedium =>
      tajawalSemiBold.copyWith(fontSize: fontSize16, height: 1.4);

  static TextStyle get titleSmall =>
      tajawalSemiBold.copyWith(fontSize: fontSize14, height: 1.4);

  // Amiri Text Styles (for reports and titles)
  static TextStyle get amiriTitle =>
      amiriBold.copyWith(fontSize: fontSize24, height: 1.4);

  static TextStyle get amiriBody =>
      amiriRegular.copyWith(fontSize: fontSize16, height: 1.6);

  static TextStyle get amiriCaption =>
      amiriRegular.copyWith(fontSize: fontSize12, height: 1.5);
}

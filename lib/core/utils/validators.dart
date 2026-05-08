import 'package:flutter/material.dart';

class Validators {
  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  // National ID Validator (Egyptian - 14 digits)
  static String? validateNationalId(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرقم القومي مطلوب';
    }
    if (value.length != 14) {
      return 'الرقم القومي يجب أن يكون 14 رقم';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'الرقم القومي يجب أن يحتوي على أرقام فقط';
    }
    return null;
  }

  // Phone Validator (Egyptian - 11 digits starting with 0)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (value.length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقم';
    }
    if (!value.startsWith('0')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 0';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }
    return null;
  }

  // Age Validator (18-80)
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'العمر مطلوب';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'العمر يجب أن يكون رقماً';
    }
    if (age < 18 || age > 80) {
      return 'العمر يجب أن يكون بين 18 و 80';
    }
    return null;
  }

  // Required Field Validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  // ICAO Code Validator (4 capital letters)
  static String? validateIcaoCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز ICAO مطلوب';
    }
    if (value.length != 4) {
      return 'رمز ICAO يجب أن يكون 4 أحرف';
    }
    if (!RegExp(r'^[A-Z]{4}$').hasMatch(value)) {
      return 'رمز ICAO يجب أن يكون 4 أحرف إنجليزية كبيرة';
    }
    return null;
  }

  // Runway Name Validator (ICAO format: 01-36 with optional L/C/R)
  static String? validateRunwayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المدرج مطلوب';
    }
    final runwayRegex = RegExp(r'^([0-3][0-9])(/[0-3][0-9])?$');
    if (!runwayRegex.hasMatch(value)) {
      return 'اسم المدرج غير صحيح (مثال: 05/23)';
    }
    return null;
  }

  // Numeric Validator
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '$fieldName يجب أن يكون رقماً';
    }
    return null;
  }

  // Positive Number Validator
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName يجب أن يكون رقماً';
    }
    if (number <= 0) {
      return '$fieldName يجب أن يكون رقماً موجباً';
    }
    return null;
  }

  // Min Length Validator
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    if (value.length < minLength) {
      return '$fieldName يجب أن يكون على الأقل $minLength أحرف';
    }
    return null;
  }

  // Max Length Validator
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return '$fieldName يجب أن لا يتجاوز $maxLength حرف';
    }
    return null;
  }

  // Parse Birth Date from National ID (Egyptian format)
 /* static DateTime? parseBirthDateFromNationalId(
    String nationalId
    
    ) {
   // if (nationalId.length != 14) return null;

    try {
      final century = int.parse(nationalId.substring(0, 1));
      final year = int.parse(nationalId.substring(1, 3));
      final month = int.parse(nationalId.substring(3, 5));
      final day = int.parse(nationalId.substring(5, 7));

      // Determine century (1900s or 2000s)
      final fullYear = (century == 2) ? 1900 + year : 2000 + year;

      return DateTime(fullYear, month, day);
    } catch (e) {
      return null;
    }
  }*/

  // Calculate License Validity
  static Map<String, dynamic> calculateLicenseValidity(
    DateTime issueDate,
    DateTime expiryDate,
  ) {
    final now = DateTime.now();
    final isExpired = now.isAfter(expiryDate);
    final totalDays = expiryDate.difference(issueDate).inDays;
    final remainingDays = isExpired ? 0 : expiryDate.difference(now).inDays;

    // Calculate years, months, days
    final years = remainingDays ~/ 365;
    final months = (remainingDays % 365) ~/ 30;
    final days = (remainingDays % 365) % 30;

    // Calculate percentage remaining
    final percentage = isExpired ? 0.0 : (remainingDays / totalDays * 100);

    return {
      'isExpired': isExpired,
      'years': years,
      'months': months,
      'days': days,
      'percentage': percentage,
      'remainingDays': remainingDays,
    };
  }

  // Get License Status Color
  static Color getLicenseStatusColor(double percentage) {
    if (percentage >= 50) {
      return const Color(0xFF2E7D32); // Green
    } else if (percentage >= 20) {
      return const Color(0xFFF57C00); // Orange
    } else {
      return const Color(0xFFD32F2F); // Red
    }
  }

  // Get License Status Text
  static String getLicenseStatusText(double percentage) {
    if (percentage >= 50) {
      return 'سارية';
    } else if (percentage >= 20) {
      return 'تنتهي قريباً';
    } else {
      return 'منتهية';
    }
  }
}

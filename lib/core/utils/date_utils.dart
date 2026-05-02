import 'package:intl/intl.dart';

class DateUtils {
  // Format date to Arabic format
  static String formatToArabic(DateTime date) {
    final arabicDays = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final dayName = arabicDays[date.weekday % 7];
    final monthName = arabicMonths[date.month - 1];

    return '$dayName، ${date.day} $monthName ${date.year}';
  }

  // Format date to short Arabic format
  static String formatToShortArabic(DateTime date) {
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final monthName = arabicMonths[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }

  // Format date to standard format (dd/MM/yyyy)
  static String formatToStandard(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date to ISO format (yyyy-MM-dd)
  static String formatToISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Parse date from standard format (dd/MM/yyyy)
  static DateTime? parseFromStandard(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Parse date from ISO format (yyyy-MM-dd)
  static DateTime? parseFromISO(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  // Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays.abs();
  }

  // Get months between two dates
  static int monthsBetween(DateTime start, DateTime end) {
    final months = (end.year - start.year) * 12 + end.month - start.month;
    return months.abs();
  }

  // Get years between two dates
  static int yearsBetween(DateTime start, DateTime end) {
    final years = end.year - start.year;
    if (end.month < start.month ||
        (end.month == start.month && end.day < start.day)) {
      return years.abs() - 1;
    }
    return years.abs();
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Get relative date string (Today, Yesterday, Tomorrow, or formatted date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'اليوم';
    } else if (isYesterday(date)) {
      return 'أمس';
    } else if (isTomorrow(date)) {
      return 'غداً';
    } else {
      return formatToShortArabic(date);
    }
  }

  // Check if date is overdue
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }

  // Check if date is within next X days
  static bool isWithinDays(DateTime date, int days) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference >= 0 && difference <= days;
  }

  // Format duration to human readable string
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days يوم');
    if (hours > 0) parts.add('$hours ساعة');
    if (minutes > 0) parts.add('$minutes دقيقة');

    if (parts.isEmpty) return 'أقل من دقيقة';
    return parts.join(' و ');
  }

  // Get current time in HH:MM:SS format
  static String getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('HH:mm:ss').format(now);
  }

  // Get current date and time in Arabic
  static String getCurrentDateTimeArabic() {
    final now = DateTime.now();
    final dateStr = formatToArabic(now);
    final timeStr = DateFormat('HH:mm').format(now);
    return '$dateStr - $timeStr';
  }

  // Get report number format: EAF-YYYY-SEQ
  static String generateReportNumber(int sequence) {
    final year = DateTime.now().year;
    final seq = sequence.toString().padLeft(4, '0');
    return 'EAF-$year-$seq';
  }

  // Calculate reinspection date based on score
  static DateTime calculateReinspectionDate(
    double score,
    DateTime evaluationDate,
  ) {
    if (score >= 90) {
      // Excellent - 2 years
      return evaluationDate.add(const Duration(days: 730));
    } else if (score >= 75) {
      // Good - 1 year
      return evaluationDate.add(const Duration(days: 365));
    } else if (score >= 60) {
      // Acceptable - 6 months
      return evaluationDate.add(const Duration(days: 180));
    } else {
      // Unsafe - 3 months
      return evaluationDate.add(const Duration(days: 90));
    }
  }

  // Get maintenance urgency level
  static String getMaintenanceUrgency(DateTime nextMaintenanceDate) {
    final daysUntil = DateUtils.daysUntil(nextMaintenanceDate);

    if (daysUntil < 0) {
      return 'متأخر';
    } else if (daysUntil <= 7) {
      return 'عاجل';
    } else if (daysUntil <= 30) {
      return 'قريباً';
    } else {
      return 'مجدول';
    }
  }

  // Get maintenance urgency color
  static String getMaintenanceUrgencyColor(DateTime nextMaintenanceDate) {
    final daysUntil = DateUtils.daysUntil(nextMaintenanceDate);

    if (daysUntil < 0) {
      return '#D32F2F'; // Red
    } else if (daysUntil <= 7) {
      return '#D32F2F'; // Red
    } else if (daysUntil <= 30) {
      return '#F57C00'; // Orange
    } else {
      return '#2E7D32'; // Green
    }
  }
}

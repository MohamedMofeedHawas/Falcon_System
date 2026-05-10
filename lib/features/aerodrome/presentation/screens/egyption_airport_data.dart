import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// بيانات جميع مطارات وقواعد جمهورية مصر العربية
/// ─────────────────────────────────────────────────────────────────────────

enum EgyptAirportCategory {
  civil, // مدني
  military, // عسكري
  mixed, // مختلط
  local, // محلي / خاص
}

class EgyptAirportEntry {
  final String icaoCode;
  final String? iataCode;
  final String arabicName;
  final String englishName;
  final EgyptAirportCategory category;

  const EgyptAirportEntry({
    required this.icaoCode,
    this.iataCode,
    required this.arabicName,
    required this.englishName,
    required this.category,
  });

  // ── نوع النص المعروض ──────────────────────────────────────────────────
  String get typeLabel {
    switch (category) {
      case EgyptAirportCategory.civil:
        return 'مدني';
      case EgyptAirportCategory.military:
        return 'عسكري';
      case EgyptAirportCategory.mixed:
        return 'مختلط';
      case EgyptAirportCategory.local:
        return 'محلي';
    }
  }

  // ── أيقونة النوع ──────────────────────────────────────────────────────
  IconData get icon {
    switch (category) {
      case EgyptAirportCategory.civil:
        return Icons.flight_takeoff_rounded;
      case EgyptAirportCategory.military:
        return Icons.military_tech_rounded;
      case EgyptAirportCategory.mixed:
        return Icons.connecting_airports_rounded;
      case EgyptAirportCategory.local:
        return Icons.local_airport_rounded;
    }
  }

  // ── لون النوع ─────────────────────────────────────────────────────────
  Color get color {
    switch (category) {
      case EgyptAirportCategory.civil:
        return const Color(0xFF1565C0); // أزرق
      case EgyptAirportCategory.military:
        return const Color(0xFFC62828); // أحمر
      case EgyptAirportCategory.mixed:
        return const Color(0xFF6A1B9A); // بنفسجي
      case EgyptAirportCategory.local:
        return const Color(0xFF00695C); // أخضر غامق
    }
  }

  // ── نص العرض فى الـ dropdown ──────────────────────────────────────────
  String get displayLabel => '$icaoCode — $arabicName';
}

// ══════════════════════════════════════════════════════════════════════════
// القائمة الكاملة
// ══════════════════════════════════════════════════════════════════════════

class EgyptianAirportsData {
  EgyptianAirportsData._();

  static const List<EgyptAirportEntry> all = [
    // ─────────────────────────────────────────────────────────────────
    //  مطارات مدنية دولية ومحلية
    // ─────────────────────────────────────────────────────────────────
    EgyptAirportEntry(
      icaoCode: 'HECA',
      iataCode: 'CAI',
      arabicName: 'مطار القاهرة الدولي',
      englishName: 'Cairo International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HESX',
      iataCode: 'SPX',
      arabicName: 'مطار سفنكس الدولي',
      englishName: 'Sphinx International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HECP',
      iataCode: 'CCE',
      arabicName: 'مطار كابيتال الدولي',
      englishName: 'Capital International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEBA',
      iataCode: 'HBE',
      arabicName: 'مطار برج العرب الدولي',
      englishName: 'Borg El Arab International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEAX',
      iataCode: 'ALY',
      arabicName: 'مطار الإسكندرية',
      englishName: 'Alexandria International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEGN',
      iataCode: 'HRG',
      arabicName: 'مطار الغردقة الدولي',
      englishName: 'Hurghada International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HESH',
      iataCode: 'SSH',
      arabicName: 'مطار شرم الشيخ الدولي',
      englishName: 'Sharm El Sheikh International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HELX',
      iataCode: 'LXR',
      arabicName: 'مطار الأقصر الدولي',
      englishName: 'Luxor International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HESN',
      iataCode: 'ASW',
      arabicName: 'مطار أسوان الدولي',
      englishName: 'Aswan International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEAT',
      iataCode: 'ATZ',
      arabicName: 'مطار أسيوط',
      englishName: 'Assiut Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEMK',
      iataCode: 'HMB',
      arabicName: 'مطار سوهاج الدولي',
      englishName: 'Sohag International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEMA',
      iataCode: 'RMF',
      arabicName: 'مطار مرسى علم الدولي',
      englishName: 'Marsa Alam International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEMM',
      iataCode: 'MUH',
      arabicName: 'مطار مرسى مطروح',
      englishName: 'Mersa Matruh Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEAL',
      iataCode: 'DBB',
      arabicName: 'مطار العلمين الدولي',
      englishName: 'El Alamein International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEAR',
      iataCode: 'AAC',
      arabicName: 'مطار العريش الدولي',
      englishName: 'El Arish International Airport',
      category: EgyptAirportCategory.mixed,
    ),
    EgyptAirportEntry(
      icaoCode: 'HETB',
      iataCode: 'TCP',
      arabicName: 'مطار طابا الدولي',
      englishName: 'Taba International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HESC',
      iataCode: 'SKV',
      arabicName: 'مطار سانت كاترين الدولي',
      englishName: 'St. Catherine International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEBL',
      iataCode: 'ABS',
      arabicName: 'مطار أبو سمبل',
      englishName: 'Abu Simbel Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEOW',
      iataCode: 'GSQ',
      arabicName: 'مطار شرق العويناط',
      englishName: 'Sharq El Owainat Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEDK',
      iataCode: 'DAK',
      arabicName: 'مطار الداخلة',
      englishName: 'Dakhla Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEKG',
      iataCode: 'UVL',
      arabicName: 'مطار الخارجة',
      englishName: 'El Kharga Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEPS',
      iataCode: 'PSD',
      arabicName: 'مطار بورسعيد',
      englishName: 'Port Said Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HETR',
      iataCode: 'ELT',
      arabicName: 'مطار الطور',
      englishName: 'El Tor Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEGR',
      iataCode: 'EGH',
      arabicName: 'مطار الجورة',
      englishName: 'El Gora Airport',
      category: EgyptAirportCategory.civil,
    ),

    // ─────────────────────────────────────────────────────────────────
    //  قواعد جوية عسكرية
    // ─────────────────────────────────────────────────────────────────
    EgyptAirportEntry(
      icaoCode: 'HECW',
      iataCode: 'CWE',
      arabicName: 'قاعدة القاهرة الغربية الجوية',
      englishName: 'Cairo West Air Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEAZ',
      arabicName: 'قاعدة الماظة الجوية',
      englishName: 'Almaza Air Force Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEBS',
      arabicName: 'قاعدة بني سويف الجوية',
      englishName: 'Beni Suef Air Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEGS',
      arabicName: 'قاعدة جيانكليس الجوية',
      englishName: 'Jiyanklis Air Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEMN',
      iataCode: 'EMY',
      arabicName: 'قاعدة المنيا الجوية',
      englishName: 'Minya Air Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HE15',
      arabicName: 'قاعدة حلوان الجوية',
      englishName: 'Helwan Air Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HE13',
      arabicName: 'مطار وادي الجندلي',
      englishName: 'Wadi El Gandali Airport',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HE25',
      arabicName: 'قاعدة إنشاص الجوية',
      englishName: 'Inshas Air Base',
      category: EgyptAirportCategory.military,
    ),
    EgyptAirportEntry(
      icaoCode: 'HE75',
      arabicName: 'قاعدة كبريت الجوية',
      englishName: 'Kabrit Air Base',
      category: EgyptAirportCategory.military,
    ),

    // ─────────────────────────────────────────────────────────────────
    //  مطارات محلية / أخرى
    // ─────────────────────────────────────────────────────────────────
    EgyptAirportEntry(
      icaoCode: 'HESD',
      arabicName: 'مطار رأس سدر',
      englishName: 'Ras Sedr Airport',
      category: EgyptAirportCategory.local,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEKO',
      arabicName: 'مطار كوم أمبو',
      englishName: 'Kom Ombo Airport',
      category: EgyptAirportCategory.local,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEBR',
      arabicName: 'مطار برنيس الدولي',
      englishName: 'Berenice International Airport',
      category: EgyptAirportCategory.civil,
    ),
    EgyptAirportEntry(
      icaoCode: 'HEEK',
      arabicName: 'مطار شرق القاهرة',
      englishName: 'East Cairo Airport',
      category: EgyptAirportCategory.mixed,
    ),
  ];

  /// المطارات المدنية فقط
  static List<EgyptAirportEntry> get civil =>
      all.where((e) => e.category == EgyptAirportCategory.civil).toList();

  /// القواعد العسكرية فقط
  static List<EgyptAirportEntry> get military =>
      all.where((e) => e.category == EgyptAirportCategory.military).toList();

  /// المطارات المختلطة
  static List<EgyptAirportEntry> get mixed =>
      all.where((e) => e.category == EgyptAirportCategory.mixed).toList();

  /// المطارات المحلية
  static List<EgyptAirportEntry> get local =>
      all.where((e) => e.category == EgyptAirportCategory.local).toList();

  /// البحث بالكود أو الاسم
  static EgyptAirportEntry? findByIcao(String icao) {
    try {
      return all.firstWhere(
        (e) => e.icaoCode.toLowerCase() == icao.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

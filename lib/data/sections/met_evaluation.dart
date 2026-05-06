// lib/data/models/met_evaluation.dart

import 'package:hive/hive.dart';
import 'met_element_score.dart';

part 'met_evaluation.g.dart';

/// نموذج التقييم الكامل لخدمات الأرصاد الجوية (MET)
/// أقصى درجة = 6 عناصر × 10 = 60
@HiveType(typeId: 10)
class MetEvaluation extends HiveObject {
  /// 1. توفر التقارير الجوية
  @HiveField(0)
  MetElementScore aviationReports;

  /// 2. معدات القياس الأساسية
  @HiveField(1)
  MetElementScore basicEquipment;

  /// 3. معدات متقدمة (حسب الحاجة)
  @HiveField(2)
  MetElementScore advancedEquipment;

  /// 4. نقل المعلومات للمستخدمين
  @HiveField(3)
  MetElementScore informationTransfer;

  /// 5. الصيانة والمعايرة
  @HiveField(4)
  MetElementScore maintenanceCalibration;

  /// 6. الأرصاد الجوية للطيران – التوقعات
  @HiveField(5)
  MetElementScore aviationForecasts;

  MetEvaluation({
    MetElementScore? aviationReports,
    MetElementScore? basicEquipment,
    MetElementScore? advancedEquipment,
    MetElementScore? informationTransfer,
    MetElementScore? maintenanceCalibration,
    MetElementScore? aviationForecasts,
  }) : aviationReports =
           aviationReports ??
           MetElementScore(
             key: 'aviation_reports',
             subCriteriaChecked: {
               'metar_available': false,
               'speci_issued': false,
               'taf_available': false,
               'reports_reach_tower': false,
             },
           ),
       basicEquipment =
           basicEquipment ??
           MetElementScore(
             key: 'basic_equipment',
             subCriteriaChecked: {
               'rvr_3_sensors': false,
               'anemometer_both_ends': false,
               'temp_humidity_qnh': false,
               'ceilometer': false,
             },
           ),
       advancedEquipment =
           advancedEquipment ??
           MetElementScore(
             key: 'advanced_equipment',
             subCriteriaChecked: {
               'weather_radar': false,
               'lightning_detection': false,
               'forward_scatter': false,
               'upper_wind_system': false,
             },
           ),
       informationTransfer =
           informationTransfer ??
           MetElementScore(
             key: 'information_transfer',
             subCriteriaChecked: {
               'display_in_tower_rffs': false,
               'rvr_via_atis_radio': false,
               'aftn_or_secure_net': false,
             },
           ),
       maintenanceCalibration =
           maintenanceCalibration ??
           MetElementScore(
             key: 'maintenance_calibration',
             subCriteriaChecked: {
               'rvr_calibrated_12m': false,
               'maintenance_records': false,
             },
           ),
       aviationForecasts =
           aviationForecasts ??
           MetElementScore(
             key: 'aviation_forecasts',
             subCriteriaChecked: {
               'crosswind_headwind_forecast': false,
               'storm_sand_ice_warnings': false,
               'turbulence_approach': false,
             },
           );

  // ─── الدرجة الإجمالية والنسبة المئوية ──────────────────────────────────

  /// مجموع الدرجات (أقصى = 60)
  int get totalScore =>
      aviationReports.score +
      basicEquipment.score +
      advancedEquipment.score +
      informationTransfer.score +
      maintenanceCalibration.score +
      aviationForecasts.score;

  /// النسبة المئوية
  double get percentage => (totalScore / 60.0) * 100.0;

  /// التصنيف النصي
  String get grade {
    final p = percentage;
    if (p >= 90) return 'ممتاز';
    if (p >= 75) return 'جيد';
    if (p >= 60) return 'مقبول';
    return 'خطر';
  }

  /// مفتاح التصنيف للألوان
  String get gradeKey {
    final p = percentage;
    if (p >= 90) return 'excellent';
    if (p >= 75) return 'good';
    if (p >= 60) return 'acceptable';
    return 'hazardous';
  }

  /// قائمة العناصر الحرجة (درجة ≤ 3)
  List<MetElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

  /// جميع العناصر
  List<MetElementScore> get allElements => [
    aviationReports,
    basicEquipment,
    advancedEquipment,
    informationTransfer,
    maintenanceCalibration,
    aviationForecasts,
  ];

  /// تحويل للتوافق مع EvaluationReport الحالي
  Map<String, dynamic> toCompatibilityMap() {
    final result = <String, dynamic>{};
    for (final e in allElements) {
      result[e.key] = {
        'score': e.score.toDouble(),
        'note': e.notes,
        'subCriteria': e.subCriteriaChecked,
      };
    }
    return result;
  }

  /// إنشاء من Map<String, dynamic>
  factory MetEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    MetElementScore _parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null) {
        return MetElementScore(key: key, subCriteriaChecked: defaultSub);
      }
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return MetElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return MetEvaluation(
      aviationReports: _parse('aviation_reports', {
        'metar_available': false,
        'speci_issued': false,
        'taf_available': false,
        'reports_reach_tower': false,
      }),
      basicEquipment: _parse('basic_equipment', {
        'rvr_3_sensors': false,
        'anemometer_both_ends': false,
        'temp_humidity_qnh': false,
        'ceilometer': false,
      }),
      advancedEquipment: _parse('advanced_equipment', {
        'weather_radar': false,
        'lightning_detection': false,
        'forward_scatter': false,
        'upper_wind_system': false,
      }),
      informationTransfer: _parse('information_transfer', {
        'display_in_tower_rffs': false,
        'rvr_via_atis_radio': false,
        'aftn_or_secure_net': false,
      }),
      maintenanceCalibration: _parse('maintenance_calibration', {
        'rvr_calibrated_12m': false,
        'maintenance_records': false,
      }),
      aviationForecasts: _parse('aviation_forecasts', {
        'crosswind_headwind_forecast': false,
        'storm_sand_ice_warnings': false,
        'turbulence_approach': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ────────────────────────────────────────────────────

class MetElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<MetSubCriteriaMeta> subCriteria;

  const MetElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class MetSubCriteriaMeta {
  final String key;
  final String labelAr;

  const MetSubCriteriaMeta({required this.key, required this.labelAr});
}

/// جميع بيانات عرض عناصر خدمات الأرصاد الجوية (ICAO Annex 3)
const List<MetElementMeta> kMetElementsMeta = [
  MetElementMeta(
    key: 'aviation_reports',
    titleAr: 'توفر التقارير الجوية',
    subtitleAr: 'Aviation Weather Reports Availability',
    icaoRef: 'ICAO Annex 3 §4.1',
    safetyNoteAr: '⚠️ غياب METAR لمدة أكثر من ساعة = تقييم 3 كحد أقصى',
    subCriteria: [
      MetSubCriteriaMeta(
        key: 'metar_available',
        labelAr: 'METAR يُصدَر كل 30 دقيقة أو ساعة (حسب حجم المطار)',
      ),
      MetSubCriteriaMeta(
        key: 'speci_issued',
        labelAr: 'SPECI يُصدَر فور حدوث تغيّر كبير وجذري بالطقس',
      ),
      MetSubCriteriaMeta(
        key: 'taf_available',
        labelAr: 'TAF يُصدَر كل 6 ساعات (توقعات 24 أو 30 ساعة)',
      ),
      MetSubCriteriaMeta(
        key: 'reports_reach_tower',
        labelAr: 'التقارير تصل فورياً إلى برج المراقبة والمركز التنبؤي',
      ),
    ],
  ),
  MetElementMeta(
    key: 'basic_equipment',
    titleAr: 'معدات القياس الأساسية',
    subtitleAr: 'Basic Measurement Equipment',
    icaoRef: 'ICAO Annex 3 §2.4 / Doc 8896',
    safetyNoteAr:
        '🔴 عطل RVR في مطار ضبابي = إغلاق المدرج فعلياً — أولوية إصلاح قصوى',
    subCriteria: [
      MetSubCriteriaMeta(
        key: 'rvr_3_sensors',
        labelAr:
            'RVR (مدى الرؤية على المدرج) — حساسات في 3 مواقع: بداية، وسط، نهاية المدرج',
      ),
      MetSubCriteriaMeta(
        key: 'anemometer_both_ends',
        labelAr: 'أنيمومتر (سرعة واتجاه الريح) عند طرفَي المدرج',
      ),
      MetSubCriteriaMeta(
        key: 'temp_humidity_qnh',
        labelAr: 'مقياس درجة الحرارة والرطوبة والضغط الجوي QNH يعمل',
      ),
      MetSubCriteriaMeta(
        key: 'ceilometer',
        labelAr: 'Ceilometer (قياس ارتفاع قاعدة السحب) يعمل بشكل سليم',
      ),
    ],
  ),
  MetElementMeta(
    key: 'advanced_equipment',
    titleAr: 'معدات متقدمة',
    subtitleAr: 'Advanced Equipment (As Required)',
    icaoRef: 'ICAO Annex 3 §3.7',
    safetyNoteAr:
        '⛅ غياب رادار الطقس في منطقة معروفة بالعواصف الرعدية = خصم إلزامي',
    subCriteria: [
      MetSubCriteriaMeta(
        key: 'weather_radar',
        labelAr: 'رادار الطقس يعمل لتوقع العواصف الرعدية في نطاق المطار',
      ),
      MetSubCriteriaMeta(
        key: 'lightning_detection',
        labelAr: 'كاشف البرق (Lightning Detection) يعمل ويُصدر تنبيهات',
      ),
      MetSubCriteriaMeta(
        key: 'forward_scatter',
        labelAr: 'مقياس رؤية أمامية (Forward Scatter Meter) مُثبَّت ومُعاير',
      ),
      MetSubCriteriaMeta(
        key: 'upper_wind_system',
        labelAr: 'نظام قياس طبقات الرياح العلوية متوفر (عند الحاجة)',
      ),
    ],
  ),
  MetElementMeta(
    key: 'information_transfer',
    titleAr: 'نقل المعلومات للمستخدمين',
    subtitleAr: 'Information Transfer to Users',
    icaoRef: 'ICAO Annex 3 §5.1 / ICAO Doc 9328',
    safetyNoteAr:
        '✈️ تأخر وصول بيانات RVR للطيار أثناء الاقتراب قد يسبب هبوطاً خطراً',
    subCriteria: [
      MetSubCriteriaMeta(
        key: 'display_in_tower_rffs',
        labelAr: 'لوحة معلومات (Display) في برج المراقبة ومركز RFFS تعمل',
      ),
      MetSubCriteriaMeta(
        key: 'rvr_via_atis_radio',
        labelAr: 'بيانات RVR الفورية تصل لقائد الطائرة عبر ATIS أو الراديو',
      ),
      MetSubCriteriaMeta(
        key: 'aftn_or_secure_net',
        labelAr: 'البيانات متاحة للملاحين عبر AFTN أو إنترنت آمن',
      ),
    ],
  ),
  MetElementMeta(
    key: 'maintenance_calibration',
    titleAr: 'الصيانة والمعايرة',
    subtitleAr: 'Maintenance & Calibration',
    icaoRef: 'ICAO Doc 8896 §6.4',
    safetyNoteAr:
        '🔧 انتهاء شهادة المعايرة = بيانات غير موثوقة وغير معترف بها رسمياً',
    subCriteria: [
      MetSubCriteriaMeta(
        key: 'rvr_calibrated_12m',
        labelAr: 'أجهزة RVR مُعايَرة كل 12 شهراً بشهادة هيئة معتمدة',
      ),
      MetSubCriteriaMeta(
        key: 'maintenance_records',
        labelAr: 'سجلات الصيانة محدَّثة وواضحة وسهلة المراجعة',
      ),
    ],
  ),
  MetElementMeta(
    key: 'aviation_forecasts',
    titleAr: 'الأرصاد الجوية للطيران – التوقعات',
    subtitleAr: 'Aviation Weather Forecasts',
    icaoRef: 'ICAO Annex 3 §6.2',
    safetyNoteAr:
        '🚨 عدم إصدار تحذير عاصفة رعدية = مسؤولية مباشرة على مزود الخدمة الأرصادية',
    subCriteria: [
      MetSubCriteriaMeta(
        key: 'crosswind_headwind_forecast',
        labelAr: 'توقعات الرياح العكسية والجانبية لأوقات الذروة محدَّثة',
      ),
      MetSubCriteriaMeta(
        key: 'storm_sand_ice_warnings',
        labelAr:
            'تحذيرات المطار من العواصف الرملية أو الجليد أو البرق تُصدَر في الوقت المناسب',
      ),
      MetSubCriteriaMeta(
        key: 'turbulence_approach',
        labelAr: 'توقعات الاضطراب (Turbulence) على ارتفاعات الاقتراب متوفرة',
      ),
    ],
  ),
];

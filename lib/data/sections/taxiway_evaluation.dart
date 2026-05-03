import 'package:hive/hive.dart';
import 'taxiway_element_score.dart';

part 'taxiway_evaluation.g.dart';

/// نموذج التقييم الكامل لممرات التاكسي
/// أقصى درجة = 7 عناصر × 10 = 70
@HiveType(typeId: 8)
class TaxiwayEvaluation extends HiveObject {
  /// 1. العرض والمسافات الجانبية
  @HiveField(0)
  TaxiwayElementScore widthClearances;

  /// 2. العلامات الأرضية
  @HiveField(1)
  TaxiwayElementScore groundMarkings;

  /// 3. الإضاءة
  @HiveField(2)
  TaxiwayElementScore lighting;

  /// 4. حالة السطح
  @HiveField(3)
  TaxiwayElementScore surfaceCondition;

  /// 5. اللافتات الإرشادية
  @HiveField(4)
  TaxiwayElementScore directionalSigns;

  /// 6. مناطق العزل الجانبي
  @HiveField(5)
  TaxiwayElementScore lateralStrip;

  /// 7. الصرف
  @HiveField(6)
  TaxiwayElementScore drainage;

  TaxiwayEvaluation({
    TaxiwayElementScore? widthClearances,
    TaxiwayElementScore? groundMarkings,
    TaxiwayElementScore? lighting,
    TaxiwayElementScore? surfaceCondition,
    TaxiwayElementScore? directionalSigns,
    TaxiwayElementScore? lateralStrip,
    TaxiwayElementScore? drainage,
  }) : widthClearances =
           widthClearances ??
           TaxiwayElementScore(
             key: 'width_clearances',
             subCriteriaChecked: {
               'nominal_width': false,
               'parallel_spacing': false,
               'paved_shoulders': false,
               'aircraft_clearance': false,
             },
           ),
       groundMarkings =
           groundMarkings ??
           TaxiwayElementScore(
             key: 'ground_markings',
             subCriteriaChecked: {
               'centerline': false,
               'edge_lines': false,
               'intersection_marks': false,
               'holding_marks': false,
             },
           ),
       lighting =
           lighting ??
           TaxiwayElementScore(
             key: 'lighting',
             subCriteriaChecked: {
               'centerline_lights': false,
               'edge_lights': false,
               'sign_illumination': false,
               'intersection_guidance': false,
               'stop_bars': false,
             },
           ),
       surfaceCondition =
           surfaceCondition ??
           TaxiwayElementScore(
             key: 'surface_condition',
             subCriteriaChecked: {
               'no_cracks': false,
               'no_fluid_pools': false,
               'level_surface': false,
               'friction_coeff': false,
               'no_fod': false,
             },
           ),
       directionalSigns =
           directionalSigns ??
           TaxiwayElementScore(
             key: 'directional_signs',
             subCriteriaChecked: {
               'mandatory_signs': false,
               'info_signs': false,
               'legibility': false,
               'night_illumination': false,
             },
           ),
       lateralStrip =
           lateralStrip ??
           TaxiwayElementScore(
             key: 'lateral_strip',
             subCriteriaChecked: {
               'obstacle_free': false,
               'wingtip_clearance': false,
               'rescue_shoulders': false,
             },
           ),
       drainage =
           drainage ??
           TaxiwayElementScore(
             key: 'drainage',
             subCriteriaChecked: {
               'surface_gradient': false,
               'unblocked_drains': false,
               'no_centerline_pools': false,
             },
           );

  // ─── الدرجة الإجمالية والنسبة المئوية ──────────────────────────────────

  /// مجموع الدرجات (أقصى = 70)
  int get totalScore =>
      widthClearances.score +
      groundMarkings.score +
      lighting.score +
      surfaceCondition.score +
      directionalSigns.score +
      lateralStrip.score +
      drainage.score;

  /// النسبة المئوية من 0 إلى 100
  double get percentage => (totalScore / 70.0) * 100.0;

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

  /// قائمة العناصر ذات الدرجات الحرجة (≤ 3)
  List<TaxiwayElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

  /// جميع العناصر كقائمة
  List<TaxiwayElementScore> get allElements => [
    widthClearances,
    groundMarkings,
    lighting,
    surfaceCondition,
    directionalSigns,
    lateralStrip,
    drainage,
  ];

  /// تحويل إلى Map<String, dynamic> للتوافق مع EvaluationReport الحالي
  Map<String, dynamic> toCompatibilityMap() {
    Map<String, dynamic> result = {};
    for (final e in allElements) {
      result[e.key] = {
        'score': e.score.toDouble(),
        'note': e.notes,
        'subCriteria': e.subCriteriaChecked,
      };
    }
    return result;
  }

  /// إنشاء من Map<String, dynamic> (للتوافق مع البيانات القديمة)
  factory TaxiwayEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    TaxiwayElementScore _parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null) {
        return TaxiwayElementScore(key: key, subCriteriaChecked: defaultSub);
      }
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return TaxiwayElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return TaxiwayEvaluation(
      widthClearances: _parse('width_clearances', {
        'nominal_width': false,
        'parallel_spacing': false,
        'paved_shoulders': false,
        'aircraft_clearance': false,
      }),
      groundMarkings: _parse('ground_markings', {
        'centerline': false,
        'edge_lines': false,
        'intersection_marks': false,
        'holding_marks': false,
      }),
      lighting: _parse('lighting', {
        'centerline_lights': false,
        'edge_lights': false,
        'sign_illumination': false,
        'intersection_guidance': false,
        'stop_bars': false,
      }),
      surfaceCondition: _parse('surface_condition', {
        'no_cracks': false,
        'no_fluid_pools': false,
        'level_surface': false,
        'friction_coeff': false,
        'no_fod': false,
      }),
      directionalSigns: _parse('directional_signs', {
        'mandatory_signs': false,
        'info_signs': false,
        'legibility': false,
        'night_illumination': false,
      }),
      lateralStrip: _parse('lateral_strip', {
        'obstacle_free': false,
        'wingtip_clearance': false,
        'rescue_shoulders': false,
      }),
      drainage: _parse('drainage', {
        'surface_gradient': false,
        'unblocked_drains': false,
        'no_centerline_pools': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة (لا تُخزَّن في Hive) ─────────────────────────────

class TaxiwayElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<SubCriteriaMeta> subCriteria;

  const TaxiwayElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class SubCriteriaMeta {
  final String key;
  final String labelAr;

  const SubCriteriaMeta({required this.key, required this.labelAr});
}

/// جميع بيانات عرض عناصر ممرات التاكسي (ICAO Annex 14)
const List<TaxiwayElementMeta> kTaxiwayElementsMeta = [
  TaxiwayElementMeta(
    key: 'width_clearances',
    titleAr: 'العرض والمسافات الجانبية',
    subtitleAr: 'Width & Lateral Clearances',
    icaoRef: 'ICAO Annex 14 §3.9',
    safetyNoteAr: '⚠️ العرض الناقص يمنع تلاقي طائرتين كبيرتين في نفس الوقت',
    subCriteria: [
      SubCriteriaMeta(
        key: 'nominal_width',
        labelAr: 'العرض الاسمي مطابق للكود: 4C (23م) ← 4F (30م)',
      ),
      SubCriteriaMeta(
        key: 'parallel_spacing',
        labelAr: 'المسافة بين الممرات المتوازية كافية',
      ),
      SubCriteriaMeta(
        key: 'paved_shoulders',
        labelAr: 'أكتاف جانبية معبدة أو مضغوطة',
      ),
      SubCriteriaMeta(
        key: 'aircraft_clearance',
        labelAr: 'مسافة الاّمان بين الطائرة وحافة الممر (Clearance) كافية',
      ),
    ],
  ),
  TaxiwayElementMeta(
    key: 'ground_markings',
    titleAr: 'العلامات الأرضية',
    subtitleAr: 'Ground Markings',
    icaoRef: 'ICAO Annex 14 §5.2',
    safetyNoteAr:
        '⛔ أي علامة مفقودة أو غير واضحة = خطر دخول خاطئ للمدرج (Runway Incursion)',
    subCriteria: [
      SubCriteriaMeta(
        key: 'centerline',
        labelAr: 'خط الوسط الأصفر المتصل واضح وغير متقطع',
      ),
      SubCriteriaMeta(
        key: 'edge_lines',
        labelAr: 'خطوط الحواف الصفراء المزدوجة مطابقة للمواصفة',
      ),
      SubCriteriaMeta(
        key: 'intersection_marks',
        labelAr: 'علامات التوجيه عند التقاطعات واضحة',
      ),
      SubCriteriaMeta(
        key: 'holding_marks',
        labelAr: 'علامات موقع التوقف (Holding Positions) عند المدرج مرئية',
      ),
      SubCriteriaMeta(
        key: 'holding_marks',
        labelAr: 'كل العلامات واضحة وغير متلاشيه',
      ),
    ],
  ),
  TaxiwayElementMeta(
    key: 'lighting',
    titleAr: 'الإضاءة',
    subtitleAr: 'Lighting',
    icaoRef: 'ICAO Annex 14 §5.3',
    safetyNoteAr:
        '🔴 خلل في أضواء Stop Bars قد يسبب اقتحام المدرج (Runway Incursion)',
    subCriteria: [
      SubCriteriaMeta(
        key: 'centerline_lights',
        labelAr: 'أضواء خط الوسط: أخضر (Taxi) / أخضر / أصفر (تقاطعات)',
      ),
      SubCriteriaMeta(
        key: 'edge_lights',
        labelAr: 'أضواء الحواف الزرقاء (Optional) تعمل بشكل صحيح',
      ),
      SubCriteriaMeta(
        key: 'sign_illumination',
        labelAr: 'إضاءة اللافتات الإرشادية تعمل ليلاً',
      ),
      SubCriteriaMeta(
        key: 'intersection_guidance',
        labelAr: 'أضواء الإرشاد عند التقاطعات شغالة',
      ),
      SubCriteriaMeta(
        key: 'stop_bars',
        labelAr: 'أضواء نقاط التوقف عند المدرج (Stop Bars – أحمر) تعمل',
      ),
    ],
  ),
  TaxiwayElementMeta(
    key: 'surface_condition',
    titleAr: 'حالة السطح',
    subtitleAr: 'Surface Condition',
    icaoRef: 'ICAO Annex 14 §3.11',
    safetyNoteAr:
        '⚠️ السطح غير المستوي يسبب اهتزازاً شديداً وتعب الطيار والركاب',
    subCriteria: [
      SubCriteriaMeta(
        key: 'no_cracks',
        labelAr: 'لا توجد تشققات أو تآكل ظاهر في السطح',
      ),
      SubCriteriaMeta(
        key: 'no_fluid_pools',
        labelAr: 'لا يوجد تجمع سوائل (زيت / ماء / وقود) على السطح',
      ),
      SubCriteriaMeta(
        key: 'level_surface',
        labelAr: 'لا توجد هبوطات أو ارتفاعات تؤثر على سلامة العجلات',
      ),
      SubCriteriaMeta(
        key: 'friction_coeff',
        labelAr: 'معامل الاحتكاك (Friction Coefficient) ضمن الحد المقبول',
      ),
      SubCriteriaMeta(
        key: 'no_fod',
        labelAr: 'لا يوجد تراكم حصى أو أجزاء معدنية (FOD)',
      ),
    ],
  ),
  TaxiwayElementMeta(
    key: 'directional_signs',
    titleAr: 'اللافتات الإرشادية',
    subtitleAr: 'Mandatory & Information Signs',
    icaoRef: 'ICAO Annex 14 §5.4',
    safetyNoteAr: '🚨 لافتة حمراء مطفأة = خطر مميت على قائد الطائرة',
    subCriteria: [
      SubCriteriaMeta(
        key: 'mandatory_signs',
        labelAr: 'لافتات إلزامية (خلفية حمراء): مؤشر المدرج + علامة التوقف',
      ),
      SubCriteriaMeta(
        key: 'info_signs',
        labelAr: 'لافتات معلومات (خلفية صفراء): اتجاه الممرات + أرقام التاكسي',
      ),
      SubCriteriaMeta(
        key: 'legibility',
        labelAr: 'الكتابة مقروءة بوضوح من مسافة بعيدة',
      ),
      SubCriteriaMeta(
        key: 'night_illumination',
        labelAr: 'إضاءة داخلية للافتات تعمل في الليل',
      ),
    ],
  ),
  TaxiwayElementMeta(
    key: 'lateral_strip',
    titleAr: 'مناطق العزل الجانبي',
    subtitleAr: 'Lateral Strip & Clearway',
    icaoRef: 'ICAO Annex 14 §3.10',
    safetyNoteAr:
        '⚠️ المنحنيات الضيقة تسبب خروج عجلة الطائرة الجانبية عن الممر',
    subCriteria: [
      SubCriteriaMeta(
        key: 'obstacle_free',
        labelAr: 'المنطقة المجاورة للممر خالية من العوائق الثابتة',
      ),
      SubCriteriaMeta(
        key: 'wingtip_clearance',
        labelAr: 'خلوص أطراف الأجنحة عند المنحنيات (Fillet) كافٍ',
      ),
      SubCriteriaMeta(
        key: 'rescue_shoulders',
        labelAr: 'أكتاف معبدة تتحمل عربات الإنقاذ والإطفاء',
      ),
    ],
  ),
  TaxiwayElementMeta(
    key: 'drainage',
    titleAr: 'الصرف',
    subtitleAr: 'Drainage',
    icaoRef: 'ICAO Annex 14 §3.11',
    safetyNoteAr:
        '💧 بركة ماء على خط وسط التاكسي = خطر انزلاق أثناء المناورة (Aquaplaning)',
    subCriteria: [
      SubCriteriaMeta(
        key: 'surface_gradient',
        labelAr: 'الميل السطحي مناسب لتصريف المياه (1-1.5%)',
      ),
      SubCriteriaMeta(
        key: 'unblocked_drains',
        labelAr: 'البالوعات غير مسدودة وتعمل بشكل سليم',
      ),
      SubCriteriaMeta(
        key: 'no_centerline_pools',
        labelAr: 'لا تشكل برك مياه على خط الوسط أو عند نقاط التوقف',
      ),
    ],
  ),
];

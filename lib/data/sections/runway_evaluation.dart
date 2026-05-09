// lib/data/models/runway_evaluation.dart

import 'package:hive/hive.dart';
import 'runway_element_score.dart';

part 'runway_evaluation.g.dart';

/// نموذج التقييم الكامل لحالة المدرج
/// أقصى درجة = 12 عنصر × 10 = 120
@HiveType(typeId: 20)
class RunwayEvaluation extends HiveObject {
  /// 1. طول المدرج
  @HiveField(0)
  RunwayElementScore runwayLength;

  /// 2. عرض المدرج
  @HiveField(1)
  RunwayElementScore runwayWidth;

  /// 3. حالة السطح
  @HiveField(2)
  RunwayElementScore surfaceCondition;

  /// 4. منطقة أمان نهاية المدرج (RESA)
  @HiveField(3)
  RunwayElementScore resa;

  /// 5. العلامات الأرضية
  @HiveField(4)
  RunwayElementScore markings;

  /// 6. إضاءة المدرج
  @HiveField(5)
  RunwayElementScore lighting;

  /// 7.1 مناطق خلو العوائق (OFZ)
  @HiveField(6)
  RunwayElementScore ofz;

  /// 8. قدرة تحمل المدرج (PCN)
  @HiveField(7)
  RunwayElementScore pcn;

  /// 9. نظام الصرف
  @HiveField(8)
  RunwayElementScore drainage;

  /// 10. اللافتات
  @HiveField(9)
  RunwayElementScore signs;

  /// 11. نظام تصريف الوقود الطارئ (إن وجد)
  @HiveField(10)
  RunwayElementScore fuelDrainage;

  /// 12. حالة الحواف والكتف
  @HiveField(11)
  RunwayElementScore edgesShoulders;

  RunwayEvaluation({
    RunwayElementScore? runwayLength,
    RunwayElementScore? runwayWidth,
    RunwayElementScore? surfaceCondition,
    RunwayElementScore? resa,
    RunwayElementScore? markings,
    RunwayElementScore? lighting,
    RunwayElementScore? ofz,
    RunwayElementScore? pcn,
    RunwayElementScore? drainage,
    RunwayElementScore? signs,
    RunwayElementScore? fuelDrainage,
    RunwayElementScore? edgesShoulders,
  }) : runwayLength =
           runwayLength ??
           RunwayElementScore(
             key: 'runway_length',
             subCriteriaChecked: {
               'code_number_letter': false,
               'toda_adequate': false,
               'lda_adequate': false,
             },
           ),
       runwayWidth =
           runwayWidth ??
           RunwayElementScore(
             key: 'runway_width',
             subCriteriaChecked: {
               'width_meets_standard': false,
               'shoulders_present': false,
               'lateral_strips_present': false,
             },
           ),
       surfaceCondition =
           surfaceCondition ??
           RunwayElementScore(
             key: 'surface_condition',
             subCriteriaChecked: {
               'no_cracks': false,
               'no_fluid_pooling': false,
               'no_spalling': false,
               'no_rubber_buildup': false,
               'friction_coeff_ok': false,
             },
           ),
       resa =
           resa ??
           RunwayElementScore(
             key: 'resa',
             subCriteriaChecked: {
               'length_240m': false,
               'width_adequate': false,
               'no_obstacles': false,
               'surface_can_stop_ac': false,
             },
           ),
       markings =
           markings ??
           RunwayElementScore(
             key: 'markings',
             subCriteriaChecked: {
               'runway_numbers_clear': false,
               'centerline_clear': false,
               'edge_lines_clear': false,
               'touchdown_zone_clear': false,
               'aiming_point_clear': false,
               'holding_position_clear': false,
             },
           ),
       lighting =
           lighting ??
           RunwayElementScore(
             key: 'lighting',
             subCriteriaChecked: {
               'edge_lights_working': false,
               'threshold_end_lights': false,
               'centerline_lights': false,
               'als_approach_lights': false,
               'touchdown_zone_lights': false,
               'dimming_control': false,
             },
           ),
       ofz =
           ofz ??
           RunwayElementScore(
             key: 'ofz',
             subCriteriaChecked: {
               'no_vegetation_rocks_animals': false,
               'wingtip_clearance_ok': false,
               'bird_hazard_report': false,
             },
           ),
       pcn =
           pcn ??
           RunwayElementScore(
             key: 'pcn',
             subCriteriaChecked: {
               'pcn_matches_acn': false,
               'no_settlements': false,
               'structural_records': false,
             },
           ),
       drainage =
           drainage ??
           RunwayElementScore(
             key: 'drainage',
             subCriteriaChecked: {
               'cross_slope_1_1_5': false,
               'longitudinal_slope_ok': false,
               'catch_basins_clear': false,
               'no_water_pooling': false,
             },
           ),
       signs =
           signs ??
           RunwayElementScore(
             key: 'signs',
             subCriteriaChecked: {
               'designation_signs': false,
               'exit_signs': false,
               'distance_remaining': false,
               'sign_illumination': false,
             },
           ),
       fuelDrainage =
           fuelDrainage ??
           RunwayElementScore(
             key: 'fuel_drainage',
             subCriteriaChecked: {
               'pipes_pumps_ok': false,
               'no_leaks': false,
               'safe_zone_compatible': false,
             },
           ),
       edgesShoulders =
           edgesShoulders ??
           RunwayElementScore(
             key: 'edges_shoulders',
             subCriteriaChecked: {
               'no_blast_erosion': false,
               'shoulder_flush_max_3cm': false,
               'fod_free': false,
             },
           );

  // ─── الدرجة والنسبة ───────────────────────────────────────────────────────

  int get totalScore =>
      runwayLength.score +
      runwayWidth.score +
      surfaceCondition.score +
      resa.score +
      markings.score +
      lighting.score +
      ofz.score +
      pcn.score +
      drainage.score +
      signs.score +
      fuelDrainage.score +
      edgesShoulders.score;

  int get maxScore => 120;

  double get percentage => (totalScore / 120.0) * 100.0;

  String get grade {
    final p = percentage;
    if (p >= 90) return 'ممتاز';
    if (p >= 75) return 'جيد';
    if (p >= 60) return 'مقبول';
    return 'غير آمن';
  }

  String get gradeKey {
    final p = percentage;
    if (p >= 90) return 'excellent';
    if (p >= 75) return 'good';
    if (p >= 60) return 'acceptable';
    return 'hazardous';
  }

  List<RunwayElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

  List<RunwayElementScore> get allElements => [
    runwayLength,
    runwayWidth,
    surfaceCondition,
    resa,
    markings,
    lighting,
    ofz,
    pcn,
    drainage,
    signs,
    fuelDrainage,
    edgesShoulders,
  ];

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

  factory RunwayEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    RunwayElementScore _parse(String key, Map<String, bool> def) {
      final raw = map[key];
      if (raw == null)
        return RunwayElementScore(key: key, subCriteriaChecked: def);
      final m = raw as Map<String, dynamic>;
      final sub = m['subCriteria'] as Map? ?? {};
      return RunwayElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          def.map((k, v) => MapEntry(k, (sub[k] as bool?) ?? false)),
        ),
      );
    }

    return RunwayEvaluation(
      runwayLength: _parse('runway_length', {
        'code_number_letter': false,
        'toda_adequate': false,
        'lda_adequate': false,
      }),
      runwayWidth: _parse('runway_width', {
        'width_meets_standard': false,
        'shoulders_present': false,
        'lateral_strips_present': false,
      }),
      surfaceCondition: _parse('surface_condition', {
        'no_cracks': false,
        'no_fluid_pooling': false,
        'no_spalling': false,
        'no_rubber_buildup': false,
        'friction_coeff_ok': false,
      }),
      resa: _parse('resa', {
        'length_240m': false,
        'width_adequate': false,
        'no_obstacles': false,
        'surface_can_stop_ac': false,
      }),
      markings: _parse('markings', {
        'runway_numbers_clear': false,
        'centerline_clear': false,
        'edge_lines_clear': false,
        'touchdown_zone_clear': false,
        'aiming_point_clear': false,
        'holding_position_clear': false,
      }),
      lighting: _parse('lighting', {
        'edge_lights_working': false,
        'threshold_end_lights': false,
        'centerline_lights': false,
        'als_approach_lights': false,
        'touchdown_zone_lights': false,
        'dimming_control': false,
      }),
      ofz: _parse('ofz', {
        'no_vegetation_rocks_animals': false,
        'wingtip_clearance_ok': false,
        'bird_hazard_report': false,
      }),
      pcn: _parse('pcn', {
        'pcn_matches_acn': false,
        'no_settlements': false,
        'structural_records': false,
      }),
      drainage: _parse('drainage', {
        'cross_slope_1_1_5': false,
        'longitudinal_slope_ok': false,
        'catch_basins_clear': false,
        'no_water_pooling': false,
      }),
      signs: _parse('signs', {
        'designation_signs': false,
        'exit_signs': false,
        'distance_remaining': false,
        'sign_illumination': false,
      }),
      fuelDrainage: _parse('fuel_drainage', {
        'pipes_pumps_ok': false,
        'no_leaks': false,
        'safe_zone_compatible': false,
      }),
      edgesShoulders: _parse('edges_shoulders', {
        'no_blast_erosion': false,
        'shoulder_flush_max_3cm': false,
        'fod_free': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ──────────────────────────────────────────────────────

class RunwayElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final bool isCritical;
  final List<RunwaySubCriteriaMeta> subCriteria;

  const RunwayElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    this.isCritical = false,
    required this.subCriteria,
  });
}

class RunwaySubCriteriaMeta {
  final String key;
  final String labelAr;
  const RunwaySubCriteriaMeta({required this.key, required this.labelAr});
}

const List<RunwayElementMeta> kRunwayElementsMeta = [
  RunwayElementMeta(
    key: 'runway_length',
    titleAr: 'طول المدرج',
    subtitleAr: 'Runway Length',
    icaoRef: 'ICAO Annex 14 §3.1',
    safetyNoteAr:
        '⚠️ نقص طول المدرج مشاكل خطيرة — خصم 4 إلى 5 درجات حسب الفجوة',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'code_number_letter',
        labelAr:
            'رمز المدرج (Code Number & Code Letter) مطابق للطائرات المستخدمة',
      ),
      RunwaySubCriteriaMeta(
        key: 'toda_adequate',
        labelAr:
            'المسافة المتاحة للإقلاع TODA (Take-Off Distance Available) كافية',
      ),
      RunwaySubCriteriaMeta(
        key: 'lda_adequate',
        labelAr:
            'المسافة المتاحة للهبوط LDA (Landing Distance Available) كافية',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'runway_width',
    titleAr: 'عرض المدرج',
    subtitleAr: 'Runway Width',
    icaoRef: 'ICAO Annex 14 §3.2',
    safetyNoteAr:
        '📏 العرض الأقل من المعيار يمنع مناورة الطائرات الكبيرة — تحقق من كود المدرج',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'width_meets_standard',
        labelAr: 'العرض مطابق للمعيار وفق كود المدرج (Code 4F: 60م كحد أدنى)',
      ),
      RunwaySubCriteriaMeta(
        key: 'shoulders_present',
        labelAr: 'الأكتاف الجانبية (Shoulders) موجودة ومعبَّدة أو مضغوطة',
      ),
      RunwaySubCriteriaMeta(
        key: 'lateral_strips_present',
        labelAr:
            'الممرات المعيدة الجانبية (Lateral Strips) موجودة إن اقتضت المواصفة',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'surface_condition',
    titleAr: 'حالة السطح',
    subtitleAr: 'Surface Condition',
    icaoRef: 'ICAO Annex 14 §3.11',
    safetyNoteAr:
        '🔴 كل عيب رئيسي = خصم درجتين — الهدف: 8 من 10 كحد أدنى للتشغيل الآمن',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'no_cracks',
        labelAr: 'لا توجد تشققات (Cracks) ظاهرة أو تفككات في السطح',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_fluid_pooling',
        labelAr: 'لا يوجد تجمع سوائل أو برك مياه على السطح',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_spalling',
        labelAr: 'لا يوجد تآكل أو تفكك (Spalling) في طبقة الإسفلت أو الخرسانة',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_rubber_buildup',
        labelAr:
            'لا يوجد تراكم مطاط (Rubber Buildup) في منطقة اللمس — يُزال دورياً',
      ),
      RunwaySubCriteriaMeta(
        key: 'friction_coeff_ok',
        labelAr:
            'معامل احتكاك السطح (Friction Coefficient) ضمن الحد المقبول (≥ 0.50)',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'resa',
    titleAr: 'منطقة أمان نهاية المدرج',
    subtitleAr: 'Runway End Safety Area (RESA)',
    icaoRef: 'ICAO Annex 14 §3.12',
    isCritical: true,
    safetyNoteAr:
        '🚨 غياب RESA أو قصورها يهدد حياة الركاب مباشرةً — تقييم 3 إلى 0',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'length_240m',
        labelAr:
            'الطول المطلوب: 240م عادةً أو حسب السلطة المحلية (90م كحد أدنى)',
      ),
      RunwaySubCriteriaMeta(
        key: 'width_adequate',
        labelAr: 'العرض المناسب: عرض المدرج + 2×60م على الأقل',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_obstacles',
        labelAr: 'منطقة RESA خالية تماماً من الحواجق والعوائق الثابتة',
      ),
      RunwaySubCriteriaMeta(
        key: 'surface_can_stop_ac',
        labelAr: 'قدرة تحمل السطح تسمح بإيقاف الطائرة بأمان في حالة الطوارئ',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'markings',
    titleAr: 'العلامات الأرضية',
    subtitleAr: 'Runway Markings',
    icaoRef: 'ICAO Annex 14 §5.2',
    safetyNoteAr:
        '✍️ كل علامة غامضة أو تالفة = خصم 1 درجة — مراجعة شاملة كل 6 أشهر',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'runway_numbers_clear',
        labelAr:
            'أرقام المدرج واضحة مع الاتجاه الصحيح (Runway Designation) مرئية',
      ),
      RunwaySubCriteriaMeta(
        key: 'centerline_clear',
        labelAr: 'خط الوسط (Centerline) واضح ومستمر على طول المدرج',
      ),
      RunwaySubCriteriaMeta(
        key: 'edge_lines_clear',
        labelAr: 'خطوط الحواف واضحة وغير متقطعة على كلا الجانبين',
      ),
      RunwaySubCriteriaMeta(
        key: 'touchdown_zone_clear',
        labelAr: 'منطقة اللمس (Touchdown Zone Markings) واضحة ومطابقة للمواصفة',
      ),
      RunwaySubCriteriaMeta(
        key: 'aiming_point_clear',
        labelAr: 'نقطة الهدف (Aiming Point) واضحة ومرئية من مسافة كافية',
      ),
      RunwaySubCriteriaMeta(
        key: 'holding_position_clear',
        labelAr:
            'خط التوقف (Holding Position) واضح إذا كان متصلاً بساحة انتظار',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'lighting',
    titleAr: 'إضاءة المدرج',
    subtitleAr: 'Runway Lighting',
    icaoRef: 'ICAO Annex 14 §5.3',
    isCritical: true,
    safetyNoteAr:
        '🔦 أي خلل في أضواء الاقتراب أو خط الوسط يسبب هبوطاً خطراً — إصلاح فوري',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'edge_lights_working',
        labelAr: 'أضواء حافة المدرج (Edge Lights) تعمل — كثافة عالية/متوسطة',
      ),
      RunwaySubCriteriaMeta(
        key: 'threshold_end_lights',
        labelAr: 'أضواء نهاية المدرج (Threshold / End Lights) تعمل بشكل سليم',
      ),
      RunwaySubCriteriaMeta(
        key: 'centerline_lights',
        labelAr: 'أضواء خط الوسط تعمل (إذا كانت الفئة عالية — CAT II/III)',
      ),
      RunwaySubCriteriaMeta(
        key: 'als_approach_lights',
        labelAr: 'أضواء الاقتراب (Approach Lighting System – ALS) تعمل بالكامل',
      ),
      RunwaySubCriteriaMeta(
        key: 'touchdown_zone_lights',
        labelAr: 'أضواء منطقة اللمس (Touchdown Zone Lights) تعمل',
      ),
      RunwaySubCriteriaMeta(
        key: 'dimming_control',
        labelAr: 'مخففات الإضاءة (Dimming Control) تعمل لضبط الشدة حسب الظروف',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'ofz',
    titleAr: 'مناطق خلو العوائق (OFZ)',
    subtitleAr: 'Obstacle Free Zone',
    icaoRef: 'ICAO Annex 14 §4.3',
    isCritical: true,
    safetyNoteAr:
        '⛔ وجود أي عائق في OFZ = تقييم فوري = صفر حتى إزالته — لا تفاوض',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'no_vegetation_rocks_animals',
        labelAr: 'لا توجد أعشاب طويلة أو حجارة أو حيوانات في نطاق OFZ',
      ),
      RunwaySubCriteriaMeta(
        key: 'wingtip_clearance_ok',
        labelAr: 'خلوص أطراف الأجنحة (Wing Tip Clearance) مطابق للمواصفة',
      ),
      RunwaySubCriteriaMeta(
        key: 'bird_hazard_report',
        labelAr:
            'تقارير خطر الطيور (Bird Hazard Report) محدَّثة وإجراءات الطرد فعّالة',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'pcn',
    titleAr: 'قدرة تحمل المدرج (PCN)',
    subtitleAr: 'Pavement Classification Number',
    icaoRef: 'ICAO Annex 14 §2.6',
    isCritical: true,
    safetyNoteAr:
        '🏗️ عدم تطابق PCN مع ACN للطائرة قد يُغلق المدرج أمام هذه الفئة',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'pcn_matches_acn',
        labelAr: 'PCN المُعلَن مطابق أو أعلى من ACN للطائرات المستخدمة',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_settlements',
        labelAr: 'لا تظهر هبوطات (Settlements) أو تشوهات أو فشل هيكلي',
      ),
      RunwaySubCriteriaMeta(
        key: 'structural_records',
        labelAr: 'سجلات الصيانة الإنشائية محدَّثة وموثَّقة وسهلة المراجعة',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'drainage',
    titleAr: 'نظام الصرف',
    subtitleAr: 'Drainage System',
    icaoRef: 'ICAO Annex 14 §3.11',
    safetyNoteAr:
        '💧 تجمع الماء على السطح = خطر التزلق المائي (Hydroplaning) عند الهبوط',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'cross_slope_1_1_5',
        labelAr: 'ميل السطح العرضي (Cross Slope) بين 1% و1.5% لتصريف الماء',
      ),
      RunwaySubCriteriaMeta(
        key: 'longitudinal_slope_ok',
        labelAr: 'الميل الطولي (Longitudinal Slope) ضمن الحدود المسموح بها',
      ),
      RunwaySubCriteriaMeta(
        key: 'catch_basins_clear',
        labelAr: 'البالوعات (Catch Basins) غير مسدودة وتُفحَص أسبوعياً',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_water_pooling',
        labelAr: 'لا يوجد تجمع مياه في مناطق التلامس أو خط الوسط بعد الأمطار',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'signs',
    titleAr: 'اللافتات',
    subtitleAr: 'Runway Signs',
    icaoRef: 'ICAO Annex 14 §5.4',
    safetyNoteAr:
        '🚦 لافتة مفقودة أو معتمة = خطر دخول خاطئ للمدرج (Runway Incursion)',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'designation_signs',
        labelAr:
            'لافتات تحديد المدرج (Runway Designation Signs) واضحة وغير معتمة',
      ),
      RunwaySubCriteriaMeta(
        key: 'exit_signs',
        labelAr: 'لافتات اتجاه الخروج (Exit Signs) في مواضعها الصحيحة',
      ),
      RunwaySubCriteriaMeta(
        key: 'distance_remaining',
        labelAr:
            'لافتات المسافة المتبقية (Distance Remaining) واضحة على الجانبين',
      ),
      RunwaySubCriteriaMeta(
        key: 'sign_illumination',
        labelAr: 'إضاءة داخلية للافتات تعمل ليلاً وفي ظروف الرؤية المنخفضة',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'fuel_drainage',
    titleAr: 'نظام تصريف الوقود الطارئ',
    subtitleAr: 'Emergency Fuel Drainage System (if present)',
    icaoRef: 'ICAO Annex 14 §9.4',
    safetyNoteAr: '⛽ نادر لكن عطله يؤثر على الاستخدام الطارئ — فحص دوري ضروري',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'pipes_pumps_ok',
        labelAr: 'صلاحية الأنابيب والمضخات وتوثيق آخر فحص',
      ),
      RunwaySubCriteriaMeta(
        key: 'no_leaks',
        labelAr: 'خلوّ النظام من أي تسريب ظاهر أو مخفي',
      ),
      RunwaySubCriteriaMeta(
        key: 'safe_zone_compatible',
        labelAr: 'توافق مواضع الأنابيب مع المنطقة الآمنة (OFZ)',
      ),
    ],
  ),
  RunwayElementMeta(
    key: 'edges_shoulders',
    titleAr: 'حالة الحواف والكتف',
    subtitleAr: 'Edges & Shoulders Condition',
    icaoRef: 'ICAO Annex 14 §3.10',
    safetyNoteAr:
        '🪨 الحصى السائب (FOD) على الكتف قد يُمتَص بالمحركات ويسبب أضراراً بالغة',
    subCriteria: [
      RunwaySubCriteriaMeta(
        key: 'no_blast_erosion',
        labelAr: 'لا يوجد تآكل للحواف بسبب نفاثات المحركات (Jet Blast Erosion)',
      ),
      RunwaySubCriteriaMeta(
        key: 'shoulder_flush_max_3cm',
        labelAr: 'مستوى الكتف مقارناً بسطح المدرج — لا يزيد الفرق عن 3 سم',
      ),
      RunwaySubCriteriaMeta(
        key: 'fod_free',
        labelAr: 'الكتف خالٍ من الحصى السائب والأجسام الغريبة (FOD)',
      ),
    ],
  ),
];

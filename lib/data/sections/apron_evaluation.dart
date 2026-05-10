// lib/data/models/apron_evaluation.dart

import 'package:hive/hive.dart';
import 'apron_element_score.dart';

part 'apron_evaluation.g.dart';

/// نموذج التقييم الكامل لساحات الوقوف (Apron / Ramp)
/// أقصى درجة = 8 عناصر × 10 = 80
@HiveType(typeId: 14)
class ApronEvaluation extends HiveObject {
  /// 1. تنظيم المواقف
  @HiveField(0)
  ApronElementScore parkingStands;

  /// 2. سلامة الحركة
  @HiveField(1)
  ApronElementScore vehicleMovement;

  /// 3. معدات الإرشاد والتوجيه
  @HiveField(2)
  ApronElementScore guidanceSystems;

  /// 4. إنارة ساحة الوقوف
  @HiveField(3)
  ApronElementScore floodLighting;

  /// 5. حالة سطح ساحة الوقوف
  @HiveField(4)
  ApronElementScore surfaceCondition;

  /// 6. مرافق دعم الطائرة
  @HiveField(5)
  ApronElementScore supportFacilities;

  /// 7. تصريف المياه في الساحة
  @HiveField(6)
  ApronElementScore waterDrainage;

  /// 8. عدم تداخل المسارات
  @HiveField(7)
  ApronElementScore conflictPoints;

  ApronEvaluation({
    ApronElementScore? parkingStands,
    ApronElementScore? vehicleMovement,
    ApronElementScore? guidanceSystems,
    ApronElementScore? floodLighting,
    ApronElementScore? surfaceCondition,
    ApronElementScore? supportFacilities,
    ApronElementScore? waterDrainage,
    ApronElementScore? conflictPoints,
  }) : parkingStands =
           parkingStands ??
           ApronElementScore(
             key: 'parking_stands',
             subCriteriaChecked: {
               'stand_lines_clear': false,
               'stand_numbers_visible': false,
               'wingtip_fuselage_clearance': false,
               'entry_exit_no_reverse': false,
             },
           ),
       vehicleMovement =
           vehicleMovement ??
           ApronElementScore(
             key: 'vehicle_movement',
             subCriteriaChecked: {
               'service_lanes_parallel': false,
               'safe_crossing_behind_ac': false,
               'apron_control_present': false,
               'speed_limits_stop_zones': false,
             },
           ),
       guidanceSystems =
           guidanceSystems ??
           ApronElementScore(
             key: 'guidance_systems',
             subCriteriaChecked: {
               'agnis_installed': false,
               'vdgs_installed': false,
               'stop_position_markers': false,
               'lead_in_centerline': false,
               'night_stand_lighting': false,
             },
           ),
       floodLighting =
           floodLighting ??
           ApronElementScore(
             key: 'flood_lighting',
             subCriteriaChecked: {
               'full_coverage_no_shadows': false,
               'lux_20_remote_50_main': false,
               'non_frangible_towers': false,
             },
           ),
       surfaceCondition =
           surfaceCondition ??
           ApronElementScore(
             key: 'surface_condition',
             subCriteriaChecked: {
               'no_depressions_nosegear': false,
               'no_oil_fuel_stains': false,
               'no_cracks_disintegration': false,
               'anti_skid_wet': false,
               'fod_free': false,
             },
           ),
       supportFacilities =
           supportFacilities ??
           ApronElementScore(
             key: 'support_facilities',
             subCriteriaChecked: {
               'gpu_good_condition': false,
               'ground_ac_available': false,
               'fuel_pipes_or_tanker_safe': false,
               'fire_extinguishers_sand': false,
             },
           ),
       waterDrainage =
           waterDrainage ??
           ApronElementScore(
             key: 'water_drainage',
             subCriteriaChecked: {
               'no_large_puddles': false,
               'unblocked_drains': false,
               'drainage_away_from_stands': false,
             },
           ),
       conflictPoints =
           conflictPoints ??
           ApronElementScore(
             key: 'conflict_points',
             subCriteriaChecked: {
               'inbound_outbound_separated': false,
               'conflict_points_marked': false,
               'lights_or_guards_at_nodes': false,
             },
           );

  // ─── الدرجة الإجمالية والنسبة المئوية ──────────────────────────────────

  /// مجموع الدرجات (أقصى = 80)
  int get totalScore =>
      parkingStands.score +
      vehicleMovement.score +
      guidanceSystems.score +
      floodLighting.score +
      surfaceCondition.score +
      supportFacilities.score +
      waterDrainage.score +
      conflictPoints.score;

  double get percentage => (totalScore / 80.0) * 100.0;

  String get grade {
    final p = percentage;
    if (p >= 90) return 'ممتاز';
    if (p >= 75) return 'جيد';
    if (p >= 60) return 'مقبول';
    return 'خطر';
  }

  String get gradeKey {
    final p = percentage;
    if (p >= 90) return 'excellent';
    if (p >= 75) return 'good';
    if (p >= 60) return 'acceptable';
    return 'hazardous';
  }

  List<ApronElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

  List<ApronElementScore> get allElements => [
    parkingStands,
    vehicleMovement,
    guidanceSystems,
    floodLighting,
    surfaceCondition,
    supportFacilities,
    waterDrainage,
    conflictPoints,
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

  factory ApronEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    ApronElementScore parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null) {
        return ApronElementScore(key: key, subCriteriaChecked: defaultSub);
      }
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return ApronElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return ApronEvaluation(
      parkingStands: parse('parking_stands', {
        'stand_lines_clear': false,
        'stand_numbers_visible': false,
        'wingtip_fuselage_clearance': false,
        'entry_exit_no_reverse': false,
      }),
      vehicleMovement: parse('vehicle_movement', {
        'service_lanes_parallel': false,
        'safe_crossing_behind_ac': false,
        'apron_control_present': false,
        'speed_limits_stop_zones': false,
      }),
      guidanceSystems: parse('guidance_systems', {
        'agnis_installed': false,
        'vdgs_installed': false,
        'stop_position_markers': false,
        'lead_in_centerline': false,
        'night_stand_lighting': false,
      }),
      floodLighting: parse('flood_lighting', {
        'full_coverage_no_shadows': false,
        'lux_20_remote_50_main': false,
        'non_frangible_towers': false,
      }),
      surfaceCondition: parse('surface_condition', {
        'no_depressions_nosegear': false,
        'no_oil_fuel_stains': false,
        'no_cracks_disintegration': false,
        'anti_skid_wet': false,
        'fod_free': false,
      }),
      supportFacilities: parse('support_facilities', {
        'gpu_good_condition': false,
        'ground_ac_available': false,
        'fuel_pipes_or_tanker_safe': false,
        'fire_extinguishers_sand': false,
      }),
      waterDrainage: parse('water_drainage', {
        'no_large_puddles': false,
        'unblocked_drains': false,
        'drainage_away_from_stands': false,
      }),
      conflictPoints: parse('conflict_points', {
        'inbound_outbound_separated': false,
        'conflict_points_marked': false,
        'lights_or_guards_at_nodes': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ────────────────────────────────────────────────────

class ApronElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<ApronSubCriteriaMeta> subCriteria;

  const ApronElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class ApronSubCriteriaMeta {
  final String key;
  final String labelAr;
  const ApronSubCriteriaMeta({required this.key, required this.labelAr});
}

/// جميع بيانات عرض عناصر ساحات الوقوف
const List<ApronElementMeta> kApronElementsMeta = [
  ApronElementMeta(
    key: 'parking_stands',
    titleAr: 'تنظيم المواقف',
    subtitleAr: 'Parking Stands Organization',
    icaoRef: 'ICAO Annex 14 §3.14 / ICAO Doc 9157 Part 2',
    safetyNoteAr:
        '✈️ تطابق سيئ بين خط الوقوف ونوع الطائرة = تصادم جناح مع طائرة مجاورة',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'stand_lines_clear',
        labelAr:
            'خطوط تحديد موقف الطائرة واضحة ومتوافقة مع نوع الطائرة (كود A–F)',
      ),
      ApronSubCriteriaMeta(
        key: 'stand_numbers_visible',
        labelAr: 'أرقام المواقف واضحة ومقروءة من جهة قائد الطائرة في الكابينة',
      ),
      ApronSubCriteriaMeta(
        key: 'wingtip_fuselage_clearance',
        labelAr:
            'مسافة الأمان بين الطائرات المتجاورة (Wing tip to wing tip / fuselage) كافية',
      ),
      ApronSubCriteriaMeta(
        key: 'entry_exit_no_reverse',
        labelAr:
            'مسارات دخول وخروج الطائرة محددة بدون مناورة عكسية خطيرة (Push-back آمن)',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'vehicle_movement',
    titleAr: 'سلامة الحركة',
    subtitleAr: 'Vehicle & Aircraft Movement Safety',
    icaoRef: 'ICAO Annex 14 §3.15 / ICAO Doc 9476',
    safetyNoteAr:
        '🚨 أي منطقة عبور غير منظمة بين المركبات والطائرات تهدد حياة عمال الأرض مباشرةً',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'service_lanes_parallel',
        labelAr: 'ممرات خدمة للمركبات موازية لحركة الطائرات ومحددة بخطوط صفراء',
      ),
      ApronSubCriteriaMeta(
        key: 'safe_crossing_behind_ac',
        labelAr: 'نقاط عبور آمنة ومحددة للمركبات خلف الطائرات — لا عبور عشوائي',
      ),
      ApronSubCriteriaMeta(
        key: 'apron_control_present',
        labelAr:
            'وجود مراقبة الحركة الأرضية (Apron Control) أو إشارات واضحة للتنظيم',
      ),
      ApronSubCriteriaMeta(
        key: 'speed_limits_stop_zones',
        labelAr:
            'سرعات محددة للمركبات (عادة 25 كم/ساعة) ومناطق توقف إلزامية مُعلَّمة',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'guidance_systems',
    titleAr: 'معدات الإرشاد والتوجيه',
    subtitleAr: 'Guidance & Docking Systems',
    icaoRef: 'ICAO Annex 14 §5.3.19 / ICAO Doc 9157 Part 4',
    safetyNoteAr:
        '🌙 غياب AGNIS/VDGS في مطار ليلي كثيف الحركة = تقييم هذا العنصر لا يتجاوز 5',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'agnis_installed',
        labelAr:
            'AGNIS (Azimuth Guidance for Nose-In Stand) مُثبَّت ويُصحِّح زاوية دخول الطائرة',
      ),
      ApronSubCriteriaMeta(
        key: 'vdgs_installed',
        labelAr:
            'VDGS (Visual Docking Guidance System) — شاشة رقمية تُظهر المسافة المتبقية للتوقف',
      ),
      ApronSubCriteriaMeta(
        key: 'stop_position_markers',
        labelAr:
            'علامات التوقف الأرضية (Stop Position Markers) واضحة على جميع المواقف',
      ),
      ApronSubCriteriaMeta(
        key: 'lead_in_centerline',
        labelAr: 'خط الوسط المؤدي لموقف الوقوف مستمر أو منقط وواضح للطيار',
      ),
      ApronSubCriteriaMeta(
        key: 'night_stand_lighting',
        labelAr:
            'إضاءة المواقف الليلية (كاشفات Floodlights) تُغطي جميع مواقف الوقوف',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'flood_lighting',
    titleAr: 'إنارة ساحة الوقوف',
    subtitleAr: 'Apron Flood Lighting',
    icaoRef: 'ICAO Annex 14 §5.3.17 / ICAO Doc 9157',
    safetyNoteAr:
        '💡 وجود بقعة مظلمة في منطقة عجلة القيادة الأمامية أثناء الدخول = خطر اصطدام مباشر',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'full_coverage_no_shadows',
        labelAr: 'تغطية كاملة بدون ظلال حرجة على منطقة الدخول إلى الموقف',
      ),
      ApronSubCriteriaMeta(
        key: 'lux_20_remote_50_main',
        labelAr:
            'استواء شدة الإضاءة: 20 lux للمواقف البعيدة / +50 lux للمواقف الرئيسية',
      ),
      ApronSubCriteriaMeta(
        key: 'non_frangible_towers',
        labelAr:
            'أبراج الإنارة غير قابلة للاصطدام بالطائرات (Non-Frangible) ومُؤمَّنة',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'surface_condition',
    titleAr: 'حالة سطح ساحة الوقوف',
    subtitleAr: 'Apron Surface Condition',
    icaoRef: 'ICAO Annex 14 §3.11 / ICAO Doc 9157 Part 2',
    safetyNoteAr:
        '⚠️ أي هبوط موضعي أمام العجلة الأمامية للطائرة قد يكسر محورها عند توقفها',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'no_depressions_nosegear',
        labelAr:
            'لا توجد هبوطات موضعية أمام مسار عجلات الطائرة (خاصة العجلة الأمامية)',
      ),
      ApronSubCriteriaMeta(
        key: 'no_oil_fuel_stains',
        labelAr:
            'لا توجد بقع زيتية أو وقودية تُشكّل خطر انزلاق لعمال الأرض والمركبات',
      ),
      ApronSubCriteriaMeta(
        key: 'no_cracks_disintegration',
        labelAr: 'لا توجد تشققات أو تفتت في السطح بسبب تسرب الوقود أو التآكل',
      ),
      ApronSubCriteriaMeta(
        key: 'anti_skid_wet',
        labelAr:
            'مقاومة السطح للانزلاق ضمن المعايير المقبولة — خاصة في حالة المطر',
      ),
      ApronSubCriteriaMeta(
        key: 'fod_free',
        labelAr:
            'الساحة خالية من الأجسام الغريبة FOD (مسامير، حصى، أدوات، أجزاء معدنية)',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'support_facilities',
    titleAr: 'مرافق دعم الطائرة',
    subtitleAr: 'Aircraft Support Facilities',
    icaoRef: 'ICAO Annex 14 §9.4 / ICAO Doc 9137',
    safetyNoteAr:
        '🔥 عدم توفر نقاط إطفاء في ساحة الوقوف = مخالفة خطيرة — التقييم 0 مؤقتاً حتى الإصلاح',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'gpu_good_condition',
        labelAr:
            'نقاط الكهرباء الأرضية GPU (Ground Power Units) بحالة جيدة وجاهزة للاستخدام',
      ),
      ApronSubCriteriaMeta(
        key: 'ground_ac_available',
        labelAr:
            'خدمة التكييف الأرضي (Pre-Conditioned Air) متوفرة لتقليل تشغيل APU',
      ),
      ApronSubCriteriaMeta(
        key: 'fuel_pipes_or_tanker_safe',
        labelAr:
            'مواسير الوقود تحت الأرض أو عربات التموين تتبع إجراءات السلامة المعتمدة',
      ),
      ApronSubCriteriaMeta(
        key: 'fire_extinguishers_sand',
        labelAr:
            'أعمدة إطفاء وموزعات رمل قريبة من مواقف الوقوف — كل موقف في نطاق 50 متر',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'water_drainage',
    titleAr: 'تصريف المياه في الساحة',
    subtitleAr: 'Apron Water Drainage',
    icaoRef: 'ICAO Annex 14 §3.11',
    safetyNoteAr:
        '💧 بركة ماء في موقع صعود ونزول المسافرين = سقوط ركاب وإصابات — مسؤولية قانونية',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'no_large_puddles',
        labelAr:
            'لا تشكُّل برك كبيرة على خطوط السير بعد الأمطار أو عمليات التنظيف',
      ),
      ApronSubCriteriaMeta(
        key: 'unblocked_drains',
        labelAr:
            'البالوعات غير مسدودة بحطام أو وقود أو رواسب — تُفحَص أسبوعياً',
      ),
      ApronSubCriteriaMeta(
        key: 'drainage_away_from_stands',
        labelAr:
            'اتجاه التصريف يُبعد السوائل عن مواقف الطائرات ومناطق توقف المسافرين',
      ),
    ],
  ),
  ApronElementMeta(
    key: 'conflict_points',
    titleAr: 'عدم تداخل المسارات',
    subtitleAr: 'Conflict Points Management',
    icaoRef: 'ICAO Annex 14 §3.14 / ICAO Doc 9476',
    safetyNoteAr:
        '🚗✈️ تداخل مسارات مركبات وطائرات بدون مراقبة = حادث كبير محتمل في أي لحظة',
    subCriteria: [
      ApronSubCriteriaMeta(
        key: 'inbound_outbound_separated',
        labelAr:
            'مسارات الطائرات الداخلة (Arriving) مفصولة عن الخارجة (Departing) بوضوح',
      ),
      ApronSubCriteriaMeta(
        key: 'conflict_points_marked',
        labelAr:
            'نقاط تلاقي المركبات والطائرات محددة بوضوح بعلامات أرضية وأسهم توجيهية',
      ),
      ApronSubCriteriaMeta(
        key: 'lights_or_guards_at_nodes',
        labelAr:
            'إشارات ضوئية أو حراس أرضيون (Marshallers) عند النقاط الحرجة دائماً',
      ),
    ],
  ),
];

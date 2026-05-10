// lib/data/sections/operational_evaluation.dart

import 'package:hive/hive.dart';
import 'operational_element_score.dart';

part 'operational_evaluation.g.dart';

/// نموذج التقييم الكامل للإجراءات التشغيلية
/// أقصى درجة = 6 عناصر × 10 = 60
@HiveType(typeId: 22)
class OperationalEvaluation extends HiveObject {
  /// 1. خطة إدارة الحركة الأرضية
  @HiveField(0)
  OperationalElementScore groundMovement;

  /// 2. تنظيم حركة الطائرات
  @HiveField(1)
  OperationalElementScore aircraftMovement;

  /// 3. تنظيم حركة المركبات
  @HiveField(2)
  OperationalElementScore vehicleMovement;

  /// 4. خطة الطوارئ (Aerodrome Emergency Plan)
  @HiveField(3)
  OperationalElementScore emergencyPlan;

  /// 5. التدريبات الدورية
  @HiveField(4)
  OperationalElementScore periodicDrills;

  /// 6. إدارة الحياة البرية (Wildlife Hazard Management)
  @HiveField(5)
  OperationalElementScore wildlifeManagement;

  OperationalEvaluation({
    OperationalElementScore? groundMovement,
    OperationalElementScore? aircraftMovement,
    OperationalElementScore? vehicleMovement,
    OperationalElementScore? emergencyPlan,
    OperationalElementScore? periodicDrills,
    OperationalElementScore? wildlifeManagement,
  }) : groundMovement =
           groundMovement ??
           OperationalElementScore(
             key: 'ground_movement',
             subCriteriaChecked: {
               'approved_document': false,
               'vehicle_aircraft_maps': false,
               'peak_congestion_procedures': false,
               'towing_procedures': false,
               'tower_coordination': false,
             },
           ),
       aircraftMovement =
           aircraftMovement ??
           OperationalElementScore(
             key: 'aircraft_movement',
             subCriteriaChecked: {
               'parking_separation': false,
               'ground_control_radio': false,
               'holding_points': false,
               'night_low_visibility': false,
             },
           ),
       vehicleMovement =
           vehicleMovement ??
           OperationalElementScore(
             key: 'vehicle_movement',
             subCriteriaChecked: {
               'valid_driving_permits': false,
               'zone_speed_limits': false,
               'warning_lights_radio': false,
               'no_phone_in_movement_areas': false,
               'periodic_vehicle_inspection': false,
             },
           ),
       emergencyPlan =
           emergencyPlan ??
           OperationalElementScore(
             key: 'emergency_plan',
             subCriteriaChecked: {
               'updated_within_12_months': false,
               'roles_defined': false,
               'quick_access_maps': false,
               'incident_commander': false,
               'evacuation_procedure': false,
             },
           ),
       periodicDrills =
           periodicDrills ??
           OperationalElementScore(
             key: 'periodic_drills',
             subCriteriaChecked: {
               'full_scale_biennial': false,
               'tabletop_biannual': false,
               'drill_report_recorded': false,
               'recommendations_applied': false,
               'all_parties_participated': false,
             },
           ),
       wildlifeManagement =
           wildlifeManagement ??
           OperationalElementScore(
             key: 'wildlife_management',
             subCriteriaChecked: {
               'written_approved_program': false,
               'monthly_survey': false,
               'deterrent_methods': false,
               'bird_strike_log': false,
               'municipality_coordination': false,
             },
           );

  // ─── الدرجة الإجمالية ──────────────────────────────────────────────────

  int get totalScore =>
      groundMovement.score +
      aircraftMovement.score +
      vehicleMovement.score +
      emergencyPlan.score +
      periodicDrills.score +
      wildlifeManagement.score;

  int get maxScore => 60;

  double get percentage => (totalScore / maxScore) * 100.0;

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

  List<OperationalElementScore> get allElements => [
    groundMovement,
    aircraftMovement,
    vehicleMovement,
    emergencyPlan,
    periodicDrills,
    wildlifeManagement,
  ];

  List<OperationalElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

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

  factory OperationalEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    OperationalElementScore parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null) {
        return OperationalElementScore(
          key: key,
          subCriteriaChecked: defaultSub,
        );
      }
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return OperationalElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return OperationalEvaluation(
      groundMovement: parse('ground_movement', {
        'approved_document': false,
        'vehicle_aircraft_maps': false,
        'peak_congestion_procedures': false,
        'towing_procedures': false,
        'tower_coordination': false,
      }),
      aircraftMovement: parse('aircraft_movement', {
        'parking_separation': false,
        'ground_control_radio': false,
        'holding_points': false,
        'night_low_visibility': false,
      }),
      vehicleMovement: parse('vehicle_movement', {
        'valid_driving_permits': false,
        'zone_speed_limits': false,
        'warning_lights_radio': false,
        'no_phone_in_movement_areas': false,
        'periodic_vehicle_inspection': false,
      }),
      emergencyPlan: parse('emergency_plan', {
        'updated_within_12_months': false,
        'roles_defined': false,
        'quick_access_maps': false,
        'incident_commander': false,
        'evacuation_procedure': false,
      }),
      periodicDrills: parse('periodic_drills', {
        'full_scale_biennial': false,
        'tabletop_biannual': false,
        'drill_report_recorded': false,
        'recommendations_applied': false,
        'all_parties_participated': false,
      }),
      wildlifeManagement: parse('wildlife_management', {
        'written_approved_program': false,
        'monthly_survey': false,
        'deterrent_methods': false,
        'bird_strike_log': false,
        'municipality_coordination': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ───────────────────────────────────────────────────

class OperationalElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<OperationalSubCriteriaMeta> subCriteria;

  const OperationalElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class OperationalSubCriteriaMeta {
  final String key;
  final String labelAr;
  const OperationalSubCriteriaMeta({required this.key, required this.labelAr});
}

const List<OperationalElementMeta> kOperationalElementsMeta = [
  OperationalElementMeta(
    key: 'ground_movement',
    titleAr: 'خطة إدارة الحركة الأرضية',
    subtitleAr: 'Ground Movement Management Plan',
    icaoRef: 'ICAO Annex 14 §3.11 / ICAO Doc 9157',
    safetyNoteAr:
        '🗺️ عدم وجود خريطة مسارات مركبات مُعتمدة = خطر تصادم يومي في مناطق الحركة',
    subCriteria: [
      OperationalSubCriteriaMeta(
        key: 'approved_document',
        labelAr: 'وثيقة مكتوبة معتمدة من سلطة الطيران — مراجعة سنوية إلزامية',
      ),
      OperationalSubCriteriaMeta(
        key: 'vehicle_aircraft_maps',
        labelAr: 'خرائط توضح مسارات الطائرات والمركبات بوضوح داخل منطقة الحركة',
      ),
      OperationalSubCriteriaMeta(
        key: 'peak_congestion_procedures',
        labelAr: 'إجراءات منع الازدحام في أوقات الذروة وتحديد أولويات الحركة',
      ),
      OperationalSubCriteriaMeta(
        key: 'towing_procedures',
        labelAr:
            'إجراءات نقل الطائرة خارج الخدمة (Towing) — موثَّقة ومُدرَّب عليها',
      ),
      OperationalSubCriteriaMeta(
        key: 'tower_coordination',
        labelAr:
            'تنسيق فعّال مع برج المراقبة والمناورة — بروتوكولات اتصال محددة',
      ),
    ],
  ),
  OperationalElementMeta(
    key: 'aircraft_movement',
    titleAr: 'تنظيم حركة الطائرات',
    subtitleAr: 'Aircraft Movement Control',
    icaoRef: 'ICAO Annex 2 §3 / ICAO Doc 4444 §12',
    safetyNoteAr:
        '⚠️ أي ازدحام غير منظَّم بين الطائرات الداخلة والخارجة = تأخيرات متسلسلة وخطر اصطدام أرضي',
    subCriteria: [
      OperationalSubCriteriaMeta(
        key: 'parking_separation',
        labelAr:
            'فصل واضح بين الطائرات الداخلة والخارجة من المواقف — تسلسل منظَّم',
      ),
      OperationalSubCriteriaMeta(
        key: 'ground_control_radio',
        labelAr:
            'استخدام قنوات راديو مخصصة لحركة التاكسي (Ground Control) بشكل دائم',
      ),
      OperationalSubCriteriaMeta(
        key: 'holding_points',
        labelAr:
            'نقاط توقف إجبارية (Holding Points) قبل تقاطعات المدرج — مُعلَّمة ومُضاءة',
      ),
      OperationalSubCriteriaMeta(
        key: 'night_low_visibility',
        labelAr:
            'إجراءات ليلية وفي ظروف الضباب الكثيف (LVP) موثَّقة ومُفعَّلة تلقائياً',
      ),
    ],
  ),
  OperationalElementMeta(
    key: 'vehicle_movement',
    titleAr: 'تنظيم حركة المركبات',
    subtitleAr: 'Vehicle Movement Control',
    icaoRef: 'ICAO Annex 14 §9.4 / ICAO Doc 9157 Part 1',
    safetyNoteAr:
        '🚗 مركبة بدون راديو في منطقة العمليات = كارثة محتملة — سحب الترخيص فوراً',
    subCriteria: [
      OperationalSubCriteriaMeta(
        key: 'valid_driving_permits',
        labelAr:
            'تراخيص قيادة داخل المطار سارية الصلاحية لجميع السائقين — تجديد سنوي',
      ),
      OperationalSubCriteriaMeta(
        key: 'zone_speed_limits',
        labelAr:
            'سرعات محددة لكل منطقة (مثلاً ≤ 20 كم/س في ساحة الوقوف) — لافتات واضحة',
      ),
      OperationalSubCriteriaMeta(
        key: 'warning_lights_radio',
        labelAr:
            'جميع مركبات الخدمة مزودة بأضواء تحذيرية وراديو عامل في جميع الأوقات',
      ),
      OperationalSubCriteriaMeta(
        key: 'no_phone_in_movement_areas',
        labelAr:
            'حظر مطلق لاستخدام الهاتف أثناء القيادة في مناطق الحركة — مُطبَّق فعلياً',
      ),
      OperationalSubCriteriaMeta(
        key: 'periodic_vehicle_inspection',
        labelAr:
            'تفتيش دوري لحالة المركبات (مكابح، إطارات، أضواء) — سجل موثَّق',
      ),
    ],
  ),
  OperationalElementMeta(
    key: 'emergency_plan',
    titleAr: 'خطة الطوارئ',
    subtitleAr: 'Aerodrome Emergency Plan (AEP)',
    icaoRef: 'ICAO Annex 14 §9.1 / ICAO Doc 9137 Part 7',
    safetyNoteAr:
        '🚨 خطة طوارئ قديمة أكثر من 18 شهراً = تقييم ≥ 5 تلقائياً — تحديث فوري إلزامي',
    subCriteria: [
      OperationalSubCriteriaMeta(
        key: 'updated_within_12_months',
        labelAr:
            'وثيقة محدَّثة خلال آخر 12 شهراً — تاريخ المراجعة مُثبَّت على الغلاف',
      ),
      OperationalSubCriteriaMeta(
        key: 'roles_defined',
        labelAr:
            'تحدد أدوار كل جهة بوضوح: إطفاء، إسعاف، شرطة، برج مراقبة، شركة الطيران',
      ),
      OperationalSubCriteriaMeta(
        key: 'quick_access_maps',
        labelAr:
            'خرائط وصول سريع لجميع مواقع الحوادث المحتملة — متاحة لجميع الفِرَق',
      ),
      OperationalSubCriteriaMeta(
        key: 'incident_commander',
        labelAr:
            'جهة قيادة موحدة (Incident Commander) محددة باسم ومنصب — خلفاء معروفون',
      ),
      OperationalSubCriteriaMeta(
        key: 'evacuation_procedure',
        labelAr:
            'آلية إخلاء الركاب وتجميعهم موثَّقة — نقاط تجمُّع مُعلَّمة على أرض الواقع',
      ),
    ],
  ),
  OperationalElementMeta(
    key: 'periodic_drills',
    titleAr: 'التدريبات الدورية',
    subtitleAr: 'Periodic Emergency Drills',
    icaoRef: 'ICAO Annex 14 §9.1.10 / ICAO Doc 9137 Part 7 §7.5',
    safetyNoteAr:
        '🛑 عدم إجراء تمرين كامل منذ أكثر من 3 سنوات = تقييم 0 فوراً — تمرين إلزامي خلال 60 يوماً',
    subCriteria: [
      OperationalSubCriteriaMeta(
        key: 'full_scale_biennial',
        labelAr:
            'تمرين كامل الحجم (Full-scale) كل سنتين كحد أدنى — يُغطي سيناريو حادثة حقيقية',
      ),
      OperationalSubCriteriaMeta(
        key: 'tabletop_biannual',
        labelAr:
            'تمرين جزئي مكتبي (Tabletop) كل 6 أشهر على الأقل — يشمل جميع الأطراف',
      ),
      OperationalSubCriteriaMeta(
        key: 'drill_report_recorded',
        labelAr:
            'تسجيل بالفيديو أو تقرير مفصَّل عن كل تمرين — محفوظ ومتاح للمراجعة',
      ),
      OperationalSubCriteriaMeta(
        key: 'recommendations_applied',
        labelAr:
            'تحليل نقاط الضعف وتطبيق التوصيات — تحقق موثَّق من تنفيذ كل توصية',
      ),
      OperationalSubCriteriaMeta(
        key: 'all_parties_participated',
        labelAr:
            'مشاركة جميع الأطراف: RFFS، طبي، أمن، مراقبة جوية، شركات الطيران',
      ),
    ],
  ),
  OperationalElementMeta(
    key: 'wildlife_management',
    titleAr: 'إدارة الحياة البرية',
    subtitleAr: 'Wildlife Hazard Management',
    icaoRef: 'ICAO Annex 14 §9.4 / ICAO Doc 9137 Part 3',
    safetyNoteAr:
        '🦅 عدم وجود سجل لحوادث اصطدام الطيور = إهمال تشغيلي — الدرجة تُثبَّت عند 3 كحد أقصى',
    subCriteria: [
      OperationalSubCriteriaMeta(
        key: 'written_approved_program',
        labelAr:
            'برنامج مكتوب ومعتمد من سلطة الطيران — يشمل خطة سنوية للسيطرة على الحياة البرية',
      ),
      OperationalSubCriteriaMeta(
        key: 'monthly_survey',
        labelAr:
            'مسح شهري لمناطق تجمع الطيور: مستنقعات، مكبات نفايات، حقول قريبة',
      ),
      OperationalSubCriteriaMeta(
        key: 'deterrent_methods',
        labelAr:
            'وسائل ردع فعّالة: مفرقعات صوتية، صقور مُدرَّبة، شبكات حماية — مُشغَّلة يومياً',
      ),
      OperationalSubCriteriaMeta(
        key: 'bird_strike_log',
        labelAr:
            'سجل موثَّق لجميع حوادث اصطدام الطيور (Bird Strikes) — يُرفع للسلطة المختصة',
      ),
      OperationalSubCriteriaMeta(
        key: 'municipality_coordination',
        labelAr:
            'تنسيق مع البلدية لمعالجة مصادر الجذب خارج المطار — اتفاقية موثَّقة',
      ),
    ],
  ),
];

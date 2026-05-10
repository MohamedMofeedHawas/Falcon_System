// lib/data/models/rffs_evaluation.dart

import 'package:hive/hive.dart';
import 'rffs_element_score.dart';

part 'rffs_evaluation.g.dart';

/// نموذج التقييم الكامل لخدمات الإطفاء والإنقاذ (RFFS)
/// أقصى درجة = 7 عناصر × 10 = 70
@HiveType(typeId: 12)
class RffsEvaluation extends HiveObject {
  /// 1. الفئة (ICAO Category)
  @HiveField(0)
  RffsElementScore icaoCategory;

  /// 2. مركبات الإطفاء
  @HiveField(1)
  RffsElementScore fireVehicles;

  /// 3. مواد الإطفاء
  @HiveField(2)
  RffsElementScore extinguishingAgents;

  /// 4. جاهزية الطواقم
  @HiveField(3)
  RffsElementScore crewReadiness;

  /// 5. زمن الاستجابة
  @HiveField(4)
  RffsElementScore responseTime;

  /// 6. نظام الاتصالات
  @HiveField(5)
  RffsElementScore communicationSystem;

  /// 7. التدريبات والتنسيق
  @HiveField(6)
  RffsElementScore trainingCoordination;

  RffsEvaluation({
    RffsElementScore? icaoCategory,
    RffsElementScore? fireVehicles,
    RffsElementScore? extinguishingAgents,
    RffsElementScore? crewReadiness,
    RffsElementScore? responseTime,
    RffsElementScore? communicationSystem,
    RffsElementScore? trainingCoordination,
  }) : icaoCategory =
           icaoCategory ??
           RffsElementScore(
             key: 'icao_category',
             subCriteriaChecked: {
               'declared_category_matches': false,
               'civil_authority_doc': false,
               'periodic_review': false,
             },
           ),
       fireVehicles =
           fireVehicles ??
           RffsElementScore(
             key: 'fire_vehicles',
             subCriteriaChecked: {
               'vehicle_count_per_category': false,
               'discharge_rate_adequate': false,
               'response_3min': false,
               'daily_operational_check': false,
               'foam_proportioning_system': false,
             },
           ),
       extinguishingAgents =
           extinguishingAgents ??
           RffsElementScore(
             key: 'extinguishing_agents',
             subCriteriaChecked: {
               'water_volume_per_category': false,
               'afff_quantity': false,
               'agents_within_expiry': false,
               'dry_chemical_powder': false,
             },
           ),
       crewReadiness =
           crewReadiness ??
           RffsElementScore(
             key: 'crew_readiness',
             subCriteriaChecked: {
               'minimum_manning_per_shift': false,
               'icao_doc9137_certificates': false,
               'annual_fitness_test': false,
               'airport_layout_knowledge': false,
               'weekly_live_fire_drill': false,
             },
           ),
       responseTime =
           responseTime ??
           RffsElementScore(
             key: 'response_time',
             subCriteriaChecked: {
               'cat6_below_2min': false,
               'cat7_above_3min_midpoint': false,
               'gps_documented': false,
               'alert_under_45sec': false,
             },
           ),
       communicationSystem =
           communicationSystem ??
           RffsElementScore(
             key: 'communication_system',
             subCriteriaChecked: {
               'tower_radio_coordinated': false,
               'backup_channels': false,
               'daily_comm_test': false,
               'full_airport_coverage': false,
             },
           ),
       trainingCoordination =
           trainingCoordination ??
           RffsElementScore(
             key: 'training_coordination',
             subCriteriaChecked: {
               'emergency_plan_updated': false,
               'joint_drill_every_3months': false,
               'ambulance_hospital_coordination': false,
             },
           );

  // ─── الدرجة الإجمالية والنسبة المئوية ──────────────────────────────────

  int get totalScore =>
      icaoCategory.score +
      fireVehicles.score +
      extinguishingAgents.score +
      crewReadiness.score +
      responseTime.score +
      communicationSystem.score +
      trainingCoordination.score;

  double get percentage => (totalScore / 70.0) * 100.0;

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

  List<RffsElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

  List<RffsElementScore> get allElements => [
    icaoCategory,
    fireVehicles,
    extinguishingAgents,
    crewReadiness,
    responseTime,
    communicationSystem,
    trainingCoordination,
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

  factory RffsEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    RffsElementScore parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null) {
        return RffsElementScore(key: key, subCriteriaChecked: defaultSub);
      }
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return RffsElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return RffsEvaluation(
      icaoCategory: parse('icao_category', {
        'declared_category_matches': false,
        'civil_authority_doc': false,
        'periodic_review': false,
      }),
      fireVehicles: parse('fire_vehicles', {
        'vehicle_count_per_category': false,
        'discharge_rate_adequate': false,
        'response_3min': false,
        'daily_operational_check': false,
        'foam_proportioning_system': false,
      }),
      extinguishingAgents: parse('extinguishing_agents', {
        'water_volume_per_category': false,
        'afff_quantity': false,
        'agents_within_expiry': false,
        'dry_chemical_powder': false,
      }),
      crewReadiness: parse('crew_readiness', {
        'minimum_manning_per_shift': false,
        'icao_doc9137_certificates': false,
        'annual_fitness_test': false,
        'airport_layout_knowledge': false,
        'weekly_live_fire_drill': false,
      }),
      responseTime: parse('response_time', {
        'cat6_below_2min': false,
        'cat7_above_3min_midpoint': false,
        'gps_documented': false,
        'alert_under_45sec': false,
      }),
      communicationSystem: parse('communication_system', {
        'tower_radio_coordinated': false,
        'backup_channels': false,
        'daily_comm_test': false,
        'full_airport_coverage': false,
      }),
      trainingCoordination: parse('training_coordination', {
        'emergency_plan_updated': false,
        'joint_drill_every_3months': false,
        'ambulance_hospital_coordination': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ────────────────────────────────────────────────────

class RffsElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<RffsSubCriteriaMeta> subCriteria;

  const RffsElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class RffsSubCriteriaMeta {
  final String key;
  final String labelAr;
  const RffsSubCriteriaMeta({required this.key, required this.labelAr});
}

/// جميع بيانات عرض عناصر خدمات الإطفاء والإنقاذ
const List<RffsElementMeta> kRffsElementsMeta = [
  RffsElementMeta(
    key: 'icao_category',
    titleAr: 'الفئة (ICAO Category)',
    subtitleAr: 'ICAO Aerodrome Category',
    icaoRef: 'ICAO Annex 14 §9.2 / Doc 9137 Part 1',
    safetyNoteAr:
        '🚫 فئة أقل من المطلوب = إغلاق المطار أمام الطائرات الكبيرة فوراً',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'declared_category_matches',
        labelAr:
            'الفئة المعلنة رسمياً (من 1 إلى 10) تتوافق مع أطول طائرة تربط المطار',
      ),
      RffsSubCriteriaMeta(
        key: 'civil_authority_doc',
        labelAr: 'توثيق الفئة معتمد من سلطة الطيران المدني',
      ),
      RffsSubCriteriaMeta(
        key: 'periodic_review',
        labelAr: 'مراجعة دورية للفئة عند تغيّر نوع الطائرات المستخدمة',
      ),
    ],
  ),
  RffsElementMeta(
    key: 'fire_vehicles',
    titleAr: 'مركبات الإطفاء',
    subtitleAr: 'Fire Fighting Vehicles',
    icaoRef: 'ICAO Doc 9137 Part 1 §2.3',
    safetyNoteAr: '🚒 أي مركبة معطلة تُخفّض الفئة الفعلية للمطار تلقائياً',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'vehicle_count_per_category',
        labelAr: 'عدد المركبات مناسب للفئة (فئة 7 تحتاج 3 مركبات على الأقل)',
      ),
      RffsSubCriteriaMeta(
        key: 'discharge_rate_adequate',
        labelAr: 'قدرة الرش كافية (معدل تدفق الماء/الرغوة باللتر/الدقيقة)',
      ),
      RffsSubCriteriaMeta(
        key: 'response_3min',
        labelAr: 'سرعة الوصول: أي نقطة في المدرج خلال 3 دقائق كحد أقصى',
      ),
      RffsSubCriteriaMeta(
        key: 'daily_operational_check',
        labelAr: 'صيانة المركبات وصلاحيتها التشغيلية مُوثَّقة يومياً',
      ),
      RffsSubCriteriaMeta(
        key: 'foam_proportioning_system',
        labelAr: 'تجهيزات نظام الرغوة (Foam Proportioning System) تعمل',
      ),
    ],
  ),
  RffsElementMeta(
    key: 'extinguishing_agents',
    titleAr: 'مواد الإطفاء',
    subtitleAr: 'Extinguishing Agents',
    icaoRef: 'ICAO Doc 9137 Part 1 §2.6',
    safetyNoteAr: '⛔ نقص المياه أو رغوة منتهية الصلاحية = تقييم 0 مباشرةً',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'water_volume_per_category',
        labelAr:
            'كمية المياه المخزنة تتناسب مع الفئة (فئة 7: 38,200 لتر على الأقل)',
      ),
      RffsSubCriteriaMeta(
        key: 'afff_quantity',
        labelAr: 'كمية الرغوة (AFFF) المخزنة كافية وفقاً للفئة',
      ),
      RffsSubCriteriaMeta(
        key: 'agents_within_expiry',
        labelAr: 'جميع مواد الإطفاء ضمن تاريخ الصلاحية وتُفحص بانتظام',
      ),
      RffsSubCriteriaMeta(
        key: 'dry_chemical_powder',
        labelAr:
            'مواد إضافية متوفرة: مسحوق كيميائي جاف للحرائق الكهربائية (Class C)',
      ),
    ],
  ),
  RffsElementMeta(
    key: 'crew_readiness',
    titleAr: 'جاهزية الطواقم',
    subtitleAr: 'Crew Readiness & Manning',
    icaoRef: 'ICAO Doc 9137 Part 1 §3.1',
    safetyNoteAr: '👨‍🚒 نقص فرد واحد مؤهل يُخفّض الفئة الفعلية بمستوى كامل',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'minimum_manning_per_shift',
        labelAr: 'العدد الأدنى من أفراد الإطفاء المدربين متوفر في كل وردية',
      ),
      RffsSubCriteriaMeta(
        key: 'icao_doc9137_certificates',
        labelAr: 'شهادات تدريب معتمدة لكل الأفراد وفق ICAO Doc 9137',
      ),
      RffsSubCriteriaMeta(
        key: 'annual_fitness_test',
        labelAr: 'اختبار لياقة بدنية سنوي مُنجَز ومُوثَّق لجميع الأفراد',
      ),
      RffsSubCriteriaMeta(
        key: 'airport_layout_knowledge',
        labelAr: 'الأفراد يعرفون توزيع المطار وممرات الوصول السريع جيداً',
      ),
      RffsSubCriteriaMeta(
        key: 'weekly_live_fire_drill',
        labelAr: 'تدريبات عملية أسبوعية بمحاكاة حريق طائرة فعلية',
      ),
    ],
  ),
  RffsElementMeta(
    key: 'response_time',
    titleAr: 'زمن الاستجابة',
    subtitleAr: 'Response Time',
    icaoRef: 'ICAO Annex 14 §9.2.34 / Doc 9137 Part 1 §2.2',
    safetyNoteAr:
        '⏱️ أي تأخير فوق 3 دقائق = تقييم ≥ 4 (غير مقبول) — ICAO إلزامي',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'cat6_below_2min',
        labelAr: 'الوصول إلى أي نقطة في المدرج خلال دقيقتين (للفئة 6 فأقل)',
      ),
      RffsSubCriteriaMeta(
        key: 'cat7_above_3min_midpoint',
        labelAr: 'الوصول إلى منتصف المدرج البعيد خلال 3 دقائق (للفئة 7 فأعلى)',
      ),
      RffsSubCriteriaMeta(
        key: 'gps_documented',
        labelAr: 'زمن الاستجابة مُوثَّق بنظام GPS أو مراقب مستقل',
      ),
      RffsSubCriteriaMeta(
        key: 'alert_under_45sec',
        labelAr: 'وقت انطلاق صفارة الإنذار بعد تلقي البلاغ أقل من 45 ثانية',
      ),
    ],
  ),
  RffsElementMeta(
    key: 'communication_system',
    titleAr: 'نظام الاتصالات',
    subtitleAr: 'Communication System',
    icaoRef: 'ICAO Doc 9137 Part 1 §4.1',
    safetyNoteAr:
        '📡 انقطاع الاتصال أثناء حريق طائرة = كارثة — لا بديل عن التغطية الكاملة',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'tower_radio_coordinated',
        labelAr: 'راديو منسق ومختبر مع برج المراقبة (Tower) يومياً',
      ),
      RffsSubCriteriaMeta(
        key: 'backup_channels',
        labelAr: 'قنوات احتياطية وبدائل: موبايل / لاسلكي مشفر جاهزة',
      ),
      RffsSubCriteriaMeta(
        key: 'daily_comm_test',
        labelAr: 'اختبار يومي لجميع منظومات الاتصال مُوثَّق في السجل',
      ),
      RffsSubCriteriaMeta(
        key: 'full_airport_coverage',
        labelAr: 'تغطية كاملة لكل مناطق المطار — لا توجد نقاط ميتة',
      ),
    ],
  ),
  RffsElementMeta(
    key: 'training_coordination',
    titleAr: 'التدريبات والتنسيق',
    subtitleAr: 'Training & Coordination',
    icaoRef: 'ICAO Doc 9137 Part 1 §5.2 / ICAO Doc 9137 Part 7',
    safetyNoteAr:
        '🗓️ عدم وجود تمرين منذ 6 أشهر = خصم إلزامي 3 درجات من هذا العنصر',
    subCriteria: [
      RffsSubCriteriaMeta(
        key: 'emergency_plan_updated',
        labelAr:
            'خطة الاستجابة لحالات الطوارئ (Emergency Plan) محدَّثة وموزَّعة',
      ),
      RffsSubCriteriaMeta(
        key: 'joint_drill_every_3months',
        labelAr: 'تمرين مشترك كامل مع برج المراقبة وخدمات الطوارئ كل 3 أشهر',
      ),
      RffsSubCriteriaMeta(
        key: 'ambulance_hospital_coordination',
        labelAr: 'تنسيق فعّال مع إسعاف المطار والمستشفيات القريبة',
      ),
    ],
  ),
];

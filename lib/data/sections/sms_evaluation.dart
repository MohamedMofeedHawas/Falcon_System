// lib/data/models/sms_evaluation.dart

import 'package:hive/hive.dart';
import 'sms_element_score.dart';

part 'sms_evaluation.g.dart';

/// نموذج التقييم الكامل لنظام إدارة السلامة (SMS – Annex 19)
/// أقصى درجة = 5 عناصر × 10 = 50
@HiveType(typeId: 16)
class SmsEvaluation extends HiveObject {
  /// 1. سياسة السلامة
  @HiveField(0)
  SmsElementScore safetyPolicy;

  /// 2. تقييم المخاطر
  @HiveField(1)
  SmsElementScore riskAssessment;

  /// 3. نظام الإبلاغ
  @HiveField(2)
  SmsElementScore reportingSystem;

  /// 4. مراجعة الأداء
  @HiveField(3)
  SmsElementScore safetyPerformance;

  /// 5. التدريب على SMS
  @HiveField(4)
  SmsElementScore smsTraining;

  SmsEvaluation({
    SmsElementScore? safetyPolicy,
    SmsElementScore? riskAssessment,
    SmsElementScore? reportingSystem,
    SmsElementScore? safetyPerformance,
    SmsElementScore? smsTraining,
  }) : safetyPolicy =
           safetyPolicy ??
           SmsElementScore(
             key: 'safety_policy',
             subCriteriaChecked: {
               'signed_policy_top_mgmt': false,
               'safety_manager_committee': false,
               'safety_budget_allocated': false,
               'just_culture_declared': false,
             },
           ),
       riskAssessment =
           riskAssessment ??
           SmsElementScore(
             key: 'risk_assessment',
             subCriteriaChecked: {
               'risk_matrix_5x5': false,
               'hazard_id_all_areas': false,
               'risk_register_monthly': false,
               'controls_implemented': false,
             },
           ),
       reportingSystem =
           reportingSystem ??
           SmsElementScore(
             key: 'reporting_system',
             subCriteriaChecked: {
               'confidential_24_7': false,
               'simple_form_paper_digital': false,
               'reporter_protection': false,
               'feedback_within_2_weeks': false,
             },
           ),
       safetyPerformance =
           safetyPerformance ??
           SmsElementScore(
             key: 'safety_performance',
             subCriteriaChecked: {
               'spis_defined': false,
               'quarterly_targets': false,
               'monthly_safety_report': false,
               'internal_audit_6m': false,
               'corrective_actions_tracked': false,
             },
           ),
       smsTraining =
           smsTraining ??
           SmsElementScore(
             key: 'sms_training',
             subCriteriaChecked: {
               'all_staff_mandatory': false,
               'advanced_mgmt_training': false,
               'training_records_updated': false,
               'comprehension_test': false,
             },
           );

  // ─── الدرجة الإجمالية والنسبة المئوية ──────────────────────────────────

  /// مجموع الدرجات (أقصى = 50)
  int get totalScore =>
      safetyPolicy.score +
      riskAssessment.score +
      reportingSystem.score +
      safetyPerformance.score +
      smsTraining.score;

  double get percentage => (totalScore / 50.0) * 100.0;

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

  List<SmsElementScore> get criticalElements =>
      allElements.where((e) => e.score <= 3).toList();

  List<SmsElementScore> get allElements => [
    safetyPolicy,
    riskAssessment,
    reportingSystem,
    safetyPerformance,
    smsTraining,
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

  factory SmsEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    SmsElementScore _parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null) {
        return SmsElementScore(key: key, subCriteriaChecked: defaultSub);
      }
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return SmsElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return SmsEvaluation(
      safetyPolicy: _parse('safety_policy', {
        'signed_policy_top_mgmt': false,
        'safety_manager_committee': false,
        'safety_budget_allocated': false,
        'just_culture_declared': false,
      }),
      riskAssessment: _parse('risk_assessment', {
        'risk_matrix_5x5': false,
        'hazard_id_all_areas': false,
        'risk_register_monthly': false,
        'controls_implemented': false,
      }),
      reportingSystem: _parse('reporting_system', {
        'confidential_24_7': false,
        'simple_form_paper_digital': false,
        'reporter_protection': false,
        'feedback_within_2_weeks': false,
      }),
      safetyPerformance: _parse('safety_performance', {
        'spis_defined': false,
        'quarterly_targets': false,
        'monthly_safety_report': false,
        'internal_audit_6m': false,
        'corrective_actions_tracked': false,
      }),
      smsTraining: _parse('sms_training', {
        'all_staff_mandatory': false,
        'advanced_mgmt_training': false,
        'training_records_updated': false,
        'comprehension_test': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ────────────────────────────────────────────────────

class SmsElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<SmsSubCriteriaMeta> subCriteria;

  const SmsElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class SmsSubCriteriaMeta {
  final String key;
  final String labelAr;
  const SmsSubCriteriaMeta({required this.key, required this.labelAr});
}

/// جميع بيانات عرض عناصر نظام إدارة السلامة (ICAO Annex 19)
const List<SmsElementMeta> kSmsElementsMeta = [
  SmsElementMeta(
    key: 'safety_policy',
    titleAr: 'سياسة السلامة',
    subtitleAr: 'Safety Policy',
    icaoRef: 'ICAO Annex 19 §3.1 / ICAO Doc 9859 §2.2',
    safetyNoteAr:
        '📋 غياب سياسة سلامة موقَّعة = لا يوجد التزام فعلي — الـ SMS لا يُطبَّق على أرض الواقع',
    subCriteria: [
      SmsSubCriteriaMeta(
        key: 'signed_policy_top_mgmt',
        labelAr:
            'وثيقة سياسة سلامة موقَّعة من الإدارة العليا (CEO / مدير المطار)',
      ),
      SmsSubCriteriaMeta(
        key: 'safety_manager_committee',
        labelAr:
            'توزيع المسؤوليات بوضوح: Safety Manager معيَّن + لجنة السلامة تعمل',
      ),
      SmsSubCriteriaMeta(
        key: 'safety_budget_allocated',
        labelAr:
            'ميزانية مخصَّصة لأنشطة السلامة (تدريب، أدوات، تحقيقات) ومعتمدة',
      ),
      SmsSubCriteriaMeta(
        key: 'just_culture_declared',
        labelAr:
            'ثقافة سلامة غير لومية (Just Culture) مُعلَنة ومفهومة لجميع الموظفين',
      ),
    ],
  ),
  SmsElementMeta(
    key: 'risk_assessment',
    titleAr: 'تقييم المخاطر',
    subtitleAr: 'Risk Assessment',
    icaoRef: 'ICAO Annex 19 §3.2 / ICAO Doc 9859 §3.3',
    safetyNoteAr:
        '⚠️ عدم وجود سجل مخاطر = تقييم 0 — المطار يعمل بدون إدارة مخاطر موثَّقة',
    subCriteria: [
      SmsSubCriteriaMeta(
        key: 'risk_matrix_5x5',
        labelAr:
            'منهجية معتمدة لتقييم المخاطر (مصفوفة 5×5 أو ما يعادلها) مطبَّقة',
      ),
      SmsSubCriteriaMeta(
        key: 'hazard_id_all_areas',
        labelAr: 'تحديد المخاطر في كل منطقة تشغيلية: مدرج، تاكسي، أبرون، ورش',
      ),
      SmsSubCriteriaMeta(
        key: 'risk_register_monthly',
        labelAr:
            'سجل المخاطر (Risk Register) مُحدَّث شهرياً ومراجَع من لجنة السلامة',
      ),
      SmsSubCriteriaMeta(
        key: 'controls_implemented',
        labelAr: 'ضوابط تحكم مُنفَّذة لكل خطر (متوسط/مرتفع) مع متابعة الفاعلية',
      ),
    ],
  ),
  SmsElementMeta(
    key: 'reporting_system',
    titleAr: 'نظام الإبلاغ',
    subtitleAr: 'Safety Reporting System',
    icaoRef: 'ICAO Annex 19 §3.3 / ICAO Doc 9859 §4.2',
    safetyNoteAr:
        '🔒 عدم وجود حماية للمبلِّغين = صفر بلاغات حقيقية — النظام يعمل ظاهرياً فقط',
    subCriteria: [
      SmsSubCriteriaMeta(
        key: 'confidential_24_7',
        labelAr:
            'قناة إبلاغ سرية ومتاحة 24/7 (صندوق ورقي + بريد إلكتروني + تطبيق)',
      ),
      SmsSubCriteriaMeta(
        key: 'simple_form_paper_digital',
        labelAr: 'نموذج إبلاغ مبسَّط (ورقي أو إلكتروني) لا يتجاوز صفحة واحدة',
      ),
      SmsSubCriteriaMeta(
        key: 'reporter_protection',
        labelAr:
            'حماية المبلِّغين من العقاب في الإبلاغ غير المتعمَّد مضمونة بسياسة رسمية',
      ),
      SmsSubCriteriaMeta(
        key: 'feedback_within_2_weeks',
        labelAr:
            'تغذية راجعة للمبلِّغ خلال أسبوعين باتخاذ الإجراء أو سبب التأجيل',
      ),
    ],
  ),
  SmsElementMeta(
    key: 'safety_performance',
    titleAr: 'مراجعة الأداء',
    subtitleAr: 'Safety Performance Review',
    icaoRef: 'ICAO Annex 19 §3.4 / ICAO Doc 9859 §5.1',
    safetyNoteAr:
        '📊 عدم وجود مؤشرات SPIs = لا يمكن قياس التحسن — الـ SMS عاجز عن الإثبات',
    subCriteria: [
      SmsSubCriteriaMeta(
        key: 'spis_defined',
        labelAr:
            'مؤشرات أداء السلامة (SPIs) محدَّدة: عدد حوادث الاقتراب من المدرج، Runway Incursions...',
      ),
      SmsSubCriteriaMeta(
        key: 'quarterly_targets',
        labelAr:
            'أهداف ربع سنوية قابلة للقياس مرتبطة بمؤشرات الـ SPIs ومتابَعة',
      ),
      SmsSubCriteriaMeta(
        key: 'monthly_safety_report',
        labelAr:
            'تقرير شهري للجنة السلامة يتضمن الإحصاءات والاتجاهات والإجراءات',
      ),
      SmsSubCriteriaMeta(
        key: 'internal_audit_6m',
        labelAr: 'مراجعة داخلية (Internal Audit) كل 6 أشهر بفريق مستقل موثَّقة',
      ),
      SmsSubCriteriaMeta(
        key: 'corrective_actions_tracked',
        labelAr: 'إجراءات تصحيحية لكل نتيجة تدقيق مع متابعة الإغلاق الفعلي',
      ),
    ],
  ),
  SmsElementMeta(
    key: 'sms_training',
    titleAr: 'التدريب على SMS',
    subtitleAr: 'SMS Training',
    icaoRef: 'ICAO Annex 19 §3.5 / ICAO Doc 9859 §6.2',
    safetyNoteAr:
        '👥 10% فقط من الموظفين تدرَّبوا = نظام SMS وهمي — لا تطبيق حقيقي على أرض الواقع',
    subCriteria: [
      SmsSubCriteriaMeta(
        key: 'all_staff_mandatory',
        labelAr:
            'تدريب إلزامي لجميع الموظفين (مقدمي خدمات، مراقبين، مناوبين) بدون استثناء',
      ),
      SmsSubCriteriaMeta(
        key: 'advanced_mgmt_training',
        labelAr:
            'تدريب متقدِّم لمدير السلامة ورؤساء الأقسام يشمل تقييم المخاطر والتحقيق',
      ),
      SmsSubCriteriaMeta(
        key: 'training_records_updated',
        labelAr:
            'سجلات تدريب محدَّثة لكل موظف تتضمن تاريخ التدريب وصلاحية الشهادة',
      ),
      SmsSubCriteriaMeta(
        key: 'comprehension_test',
        labelAr:
            'اختبار فهم وتطبيق بعد كل دورة تدريبية — الحد الأدنى للنجاح 70%',
      ),
    ],
  ),
];

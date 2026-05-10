// lib/data/sections/documents_evaluation.dart

import 'package:hive/hive.dart';
import 'documents_element_score.dart';

part 'documents_evaluation.g.dart';

/// نموذج التقييم الكامل للوثائق والتصاريح
/// أقصى درجة = 3 عناصر × 10 = 30
@HiveType(typeId: 24)
class DocumentsEvaluation extends HiveObject {
  /// 1. وجود دليل مكتوب (Aerodrome Manual)
  @HiveField(0)
  DocumentsElementScore aerodromeManual;

  /// 2. تحديثات منتظمة
  @HiveField(1)
  DocumentsElementScore regularUpdates;

  /// 3. صلاحية التصاريح والرخص
  @HiveField(2)
  DocumentsElementScore licensesValidity;

  DocumentsEvaluation({
    DocumentsElementScore? aerodromeManual,
    DocumentsElementScore? regularUpdates,
    DocumentsElementScore? licensesValidity,
  }) : aerodromeManual =
           aerodromeManual ??
           DocumentsElementScore(
             key: 'aerodrome_manual',
             subCriteriaChecked: {
               'annex14_compliant': false,
               'all_sections_covered': false,
               'updated_maps_drawings': false,
               'normal_emergency_procedures': false,
             },
           ),
       regularUpdates =
           regularUpdates ??
           DocumentsElementScore(
             key: 'regular_updates',
             subCriteriaChecked: {
               'annual_full_review': false,
               'partial_updates_on_change': false,
               'amendment_log': false,
               'authority_approval': false,
             },
           ),
       licensesValidity =
           licensesValidity ??
           DocumentsElementScore(
             key: 'licenses_validity',
             subCriteriaChecked: {
               'aerodrome_certificate_valid': false,
               'annual_permits_rffs_vehicles': false,
               'navaids_met_calibration': false,
               'notam_issued_for_defects': false,
             },
           );

  // ─── الدرجة الإجمالية ──────────────────────────────────────────────────

  int get totalScore =>
      aerodromeManual.score + regularUpdates.score + licensesValidity.score;

  int get maxScore => 30;

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

  List<DocumentsElementScore> get allElements => [
    aerodromeManual,
    regularUpdates,
    licensesValidity,
  ];

  List<DocumentsElementScore> get criticalElements =>
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

  factory DocumentsEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    DocumentsElementScore _parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null)
        return DocumentsElementScore(key: key, subCriteriaChecked: defaultSub);
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return DocumentsElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return DocumentsEvaluation(
      aerodromeManual: _parse('aerodrome_manual', {
        'annex14_compliant': false,
        'all_sections_covered': false,
        'updated_maps_drawings': false,
        'normal_emergency_procedures': false,
      }),
      regularUpdates: _parse('regular_updates', {
        'annual_full_review': false,
        'partial_updates_on_change': false,
        'amendment_log': false,
        'authority_approval': false,
      }),
      licensesValidity: _parse('licenses_validity', {
        'aerodrome_certificate_valid': false,
        'annual_permits_rffs_vehicles': false,
        'navaids_met_calibration': false,
        'notam_issued_for_defects': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ───────────────────────────────────────────────────

class DocumentsElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final List<DocumentsSubCriteriaMeta> subCriteria;

  const DocumentsElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    required this.subCriteria,
  });
}

class DocumentsSubCriteriaMeta {
  final String key;
  final String labelAr;
  const DocumentsSubCriteriaMeta({required this.key, required this.labelAr});
}

const List<DocumentsElementMeta> kDocumentsElementsMeta = [
  DocumentsElementMeta(
    key: 'aerodrome_manual',
    titleAr: 'وجود دليل المطار المكتوب',
    subtitleAr: 'Aerodrome Manual',
    icaoRef: 'ICAO Annex 14 §2.9 / ICAO Doc 9774',
    safetyNoteAr:
        '📋 غياب الدليل = لا يمكن منح شهادة تشغيل مطار — الدرجة 0 تلقائياً ويُوقَف التشغيل',
    subCriteria: [
      DocumentsSubCriteriaMeta(
        key: 'annex14_compliant',
        labelAr:
            'دليل شامل مُعدّ وفق متطلبات ICAO Annex 14 — يشمل جميع الأقسام الإلزامية',
      ),
      DocumentsSubCriteriaMeta(
        key: 'all_sections_covered',
        labelAr:
            'فصول تغطي: المدرج، التاكسي، الأبرون، الإطفاء، الأرصاد، السلامة، الملاحة',
      ),
      DocumentsSubCriteriaMeta(
        key: 'updated_maps_drawings',
        labelAr:
            'خرائط ورسومات محدَّثة تعكس الوضع الحالي للبنية التحتية للمطار',
      ),
      DocumentsSubCriteriaMeta(
        key: 'normal_emergency_procedures',
        labelAr:
            'إجراءات التشغيل العادية والطارئة موثَّقة بوضوح ومتاحة لجميع المعنيين',
      ),
    ],
  ),
  DocumentsElementMeta(
    key: 'regular_updates',
    titleAr: 'التحديثات المنتظمة',
    subtitleAr: 'Regular Manual Updates',
    icaoRef: 'ICAO Annex 14 §2.9.3 / ICAO Doc 9774 §4',
    safetyNoteAr:
        '⚠️ دليل غير محدَّث منذ أكثر من سنتين = قد يحتوي معلومات خاطئة وخطيرة على السلامة',
    subCriteria: [
      DocumentsSubCriteriaMeta(
        key: 'annual_full_review',
        labelAr:
            'مراجعة سنوية كاملة للدليل — تاريخ المراجعة مُثبَّت ومعتمد من الإدارة',
      ),
      DocumentsSubCriteriaMeta(
        key: 'partial_updates_on_change',
        labelAr:
            'تحديثات جزئية فورية عند أي تغيير: إغلاق ممر، تركيب جهاز ILS، تعديل إجراء',
      ),
      DocumentsSubCriteriaMeta(
        key: 'amendment_log',
        labelAr:
            'سجل تعديلات (Amendment Log) موثَّق يتضمن رقم التعديل والتاريخ والموضوع',
      ),
      DocumentsSubCriteriaMeta(
        key: 'authority_approval',
        labelAr:
            'موافقة سلطة الطيران المدني على التحديثات الرئيسية قبل تفعيلها رسمياً',
      ),
    ],
  ),
  DocumentsElementMeta(
    key: 'licenses_validity',
    titleAr: 'صلاحية التصاريح والرخص',
    subtitleAr: 'Licenses & Permits Validity',
    icaoRef: 'ICAO Annex 14 §1.4 / ICAO Doc 9774 §3',
    safetyNoteAr:
        '🚫 رخصة تشغيل المطار منتهية = إيقاف المطار فوراً — لا تشغيل قانوني بدون شهادة سارية',
    subCriteria: [
      DocumentsSubCriteriaMeta(
        key: 'aerodrome_certificate_valid',
        labelAr:
            'رخصة تشغيل المطار (Aerodrome Certificate) سارية المفعول — تجديد سنوي مُدار',
      ),
      DocumentsSubCriteriaMeta(
        key: 'annual_permits_rffs_vehicles',
        labelAr:
            'تصاريح سنوية سارية لأنظمة الإطفاء والإنقاذ (RFFS) وجميع مركبات التشغيل',
      ),
      DocumentsSubCriteriaMeta(
        key: 'navaids_met_calibration',
        labelAr:
            'شهادات معايرة سارية لجميع أجهزة NAVAIDs وأجهزة الأرصاد الجوية (MET)',
      ),
      DocumentsSubCriteriaMeta(
        key: 'notam_issued_for_defects',
        labelAr:
            'إخطارات NOTAM مُصدَرة لأي عطل مؤثر على السلامة — نظام إصدار فوري مُفعَّل',
      ),
    ],
  ),
];

// lib/data/models/navaids_evaluation.dart

import 'package:hive/hive.dart';
import 'navaids_element_score.dart';

part 'navaids_evaluation.g.dart';

/// نموذج التقييم الكامل للمساعدات الملاحية (NAVAIDs)
/// أقصى درجة = 6 عناصر × 10 = 60
/// ملاحظة: إذا لم يكن المطار مزوَّداً بـ ILS يمكن استثناء العنصر 4
/// فيصبح الأقصى = 5 × 10 = 50
@HiveType(typeId: 18)
class NavaidsEvaluation extends HiveObject {
  /// 1. نظام PAPI / VASI
  @HiveField(0)
  NavaidsElementScore papiVasi;

  /// 2. جهاز VOR
  @HiveField(1)
  NavaidsElementScore vor;

  /// 3. نظام DME
  @HiveField(2)
  NavaidsElementScore dme;

  /// 4. نظام ILS (إن وجد)
  @HiveField(3)
  NavaidsElementScore ils;

  /// 5. خدمات المعلومات ATIS / VOLMET / D-ATIS
  @HiveField(4)
  NavaidsElementScore atisVolmet;

  /// 6. فحوصات الطيران (Flight Inspection)
  @HiveField(5)
  NavaidsElementScore flightInspection;

  /// هل المطار مزوَّد بـ ILS؟ (يؤثر على الحساب)
  @HiveField(6)
  bool hasILS;

  NavaidsEvaluation({
    NavaidsElementScore? papiVasi,
    NavaidsElementScore? vor,
    NavaidsElementScore? dme,
    NavaidsElementScore? ils,
    NavaidsElementScore? atisVolmet,
    NavaidsElementScore? flightInspection,
    this.hasILS = true,
  }) : papiVasi =
           papiVasi ??
           NavaidsElementScore(
             key: 'papi_vasi',
             subCriteriaChecked: {
               'unit_count_4': false,
               'glide_angle_correct': false,
               'visible_day_night': false,
               'no_obstacles_5miles': false,
             },
           ),
       vor =
           vor ??
           NavaidsElementScore(
             key: 'vor',
             subCriteriaChecked: {
               'coverage_25nm': false,
               'no_interference': false,
               'flight_inspection_18m': false,
               'dme_collocated': false,
             },
           ),
       dme =
           dme ??
           NavaidsElementScore(
             key: 'dme',
             subCriteriaChecked: {
               'accuracy_0_1nm': false,
               'no_query_dropout': false,
               'backup_device': false,
             },
           ),
       ils =
           ils ??
           NavaidsElementScore(
             key: 'ils',
             subCriteriaChecked: {
               'llz_on_centerline': false,
               'gp_3_degrees': false,
               'markers_working': false,
               'signal_stable_fi_match': false,
               'rnav_backup': false,
             },
           ),
       atisVolmet =
           atisVolmet ??
           NavaidsElementScore(
             key: 'atis_volmet',
             subCriteriaChecked: {
               'atis_updated_metar': false,
               'd_atis_digital': false,
               'volmet_if_international': false,
             },
           ),
       flightInspection =
           flightInspection ??
           NavaidsElementScore(
             key: 'flight_inspection',
             subCriteriaChecked: {
               'schedule_all_navaids': false,
               'tolerances_met': false,
               'authority_approved_reports': false,
             },
           );

  // ─── الدرجة الإجمالية والنسبة المئوية ──────────────────────────────────

  /// مجموع الدرجات
  int get totalScore {
    int sum =
        papiVasi.score +
        vor.score +
        dme.score +
        atisVolmet.score +
        flightInspection.score;
    if (hasILS) sum += ils.score;
    return sum;
  }

  /// أقصى درجة (60 مع ILS، 50 بدونه)
  int get maxScore => hasILS ? 60 : 50;

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

  List<NavaidsElementScore> get criticalElements =>
      allActiveElements.where((e) => e.score <= 3).toList();

  /// العناصر الفعّالة (بدون ILS إذا لم يوجد)
  List<NavaidsElementScore> get allActiveElements {
    final list = [papiVasi, vor, dme, atisVolmet, flightInspection];
    if (hasILS) list.insert(3, ils);
    return list;
  }

  Map<String, dynamic> toCompatibilityMap() {
    final result = <String, dynamic>{};
    for (final e in allActiveElements) {
      result[e.key] = {
        'score': e.score.toDouble(),
        'note': e.notes,
        'subCriteria': e.subCriteriaChecked,
      };
    }
    result['has_ils'] = hasILS;
    return result;
  }

  factory NavaidsEvaluation.fromCompatibilityMap(Map<String, dynamic> map) {
    NavaidsElementScore _parse(String key, Map<String, bool> defaultSub) {
      final raw = map[key];
      if (raw == null)
        return NavaidsElementScore(key: key, subCriteriaChecked: defaultSub);
      final m = raw as Map<String, dynamic>;
      final subRaw = m['subCriteria'] as Map? ?? {};
      return NavaidsElementScore(
        key: key,
        score: ((m['score'] as num?) ?? 5).toInt(),
        notes: (m['note'] as String?) ?? '',
        subCriteriaChecked: Map<String, bool>.from(
          defaultSub.map((k, v) => MapEntry(k, (subRaw[k] as bool?) ?? false)),
        ),
      );
    }

    return NavaidsEvaluation(
      hasILS: (map['has_ils'] as bool?) ?? true,
      papiVasi: _parse('papi_vasi', {
        'unit_count_4': false,
        'glide_angle_correct': false,
        'visible_day_night': false,
        'no_obstacles_5miles': false,
      }),
      vor: _parse('vor', {
        'coverage_25nm': false,
        'no_interference': false,
        'flight_inspection_18m': false,
        'dme_collocated': false,
      }),
      dme: _parse('dme', {
        'accuracy_0_1nm': false,
        'no_query_dropout': false,
        'backup_device': false,
      }),
      ils: _parse('ils', {
        'llz_on_centerline': false,
        'gp_3_degrees': false,
        'markers_working': false,
        'signal_stable_fi_match': false,
        'rnav_backup': false,
      }),
      atisVolmet: _parse('atis_volmet', {
        'atis_updated_metar': false,
        'd_atis_digital': false,
        'volmet_if_international': false,
      }),
      flightInspection: _parse('flight_inspection', {
        'schedule_all_navaids': false,
        'tolerances_met': false,
        'authority_approved_reports': false,
      }),
    );
  }
}

// ── بيانات العرض الثابتة ──────────────────────────────────────────────────────

class NavaidsElementMeta {
  final String key;
  final String titleAr;
  final String subtitleAr;
  final String safetyNoteAr;
  final String icaoRef;
  final bool isOptional; // ILS فقط
  final List<NavaidsSubCriteriaMeta> subCriteria;

  const NavaidsElementMeta({
    required this.key,
    required this.titleAr,
    required this.subtitleAr,
    required this.safetyNoteAr,
    required this.icaoRef,
    this.isOptional = false,
    required this.subCriteria,
  });
}

class NavaidsSubCriteriaMeta {
  final String key;
  final String labelAr;
  const NavaidsSubCriteriaMeta({required this.key, required this.labelAr});
}

const List<NavaidsElementMeta> kNavaidsElementsMeta = [
  NavaidsElementMeta(
    key: 'papi_vasi',
    titleAr: 'نظام PAPI / VASI',
    subtitleAr: 'Precision Approach Path Indicator',
    icaoRef: 'ICAO Annex 14 §5.3.5',
    safetyNoteAr:
        '🔴 أي وحدة PAPI معطَّلة = نشر NOTAM فوراً وتقييم هذا العنصر ≥ 5',
    subCriteria: [
      NavaidsSubCriteriaMeta(
        key: 'unit_count_4',
        labelAr: 'عدد الوحدات مناسب (عادة 4 وحدات على الجانب الأيسر للمدرج)',
      ),
      NavaidsSubCriteriaMeta(
        key: 'glide_angle_correct',
        labelAr: 'زاوية الميلان الصحيحة تتناسب مع منحدر الاقتراب المُعلَن',
      ),
      NavaidsSubCriteriaMeta(
        key: 'visible_day_night',
        labelAr: 'وضوح الأضواء نهاراً وليلاً — قابلة للتحكم بالشدة',
      ),
      NavaidsSubCriteriaMeta(
        key: 'no_obstacles_5miles',
        labelAr: 'لا توجد عوائق تحجب الرؤية عند القيادة من مسافة 5 أميال',
      ),
    ],
  ),
  NavaidsElementMeta(
    key: 'vor',
    titleAr: 'جهاز VOR',
    subtitleAr: 'VHF Omnidirectional Range',
    icaoRef: 'ICAO Annex 10 Vol. I §3.3',
    safetyNoteAr:
        '📡 انقطاع VOR = الكثير من الإجراءات الملاحية غير متاحة — تحويل فوري لـ GPS/RNAV',
    subCriteria: [
      NavaidsSubCriteriaMeta(
        key: 'coverage_25nm',
        labelAr: 'تغطية المجال الجوي ضمن 25 ميلاً للمطار على الأقل',
      ),
      NavaidsSubCriteriaMeta(
        key: 'no_interference',
        labelAr: 'إشارة مستقرة بدون تداخل (Interference) مع أجهزة أخرى',
      ),
      NavaidsSubCriteriaMeta(
        key: 'flight_inspection_18m',
        labelAr: 'فحوصات هوائية دورية (Flight Inspection) كل 18 شهراً كحد أقصى',
      ),
      NavaidsSubCriteriaMeta(
        key: 'dme_collocated',
        labelAr: 'توفر جهاز DME مدمج أو منفصل مع VOR لقياس المسافة',
      ),
    ],
  ),
  NavaidsElementMeta(
    key: 'dme',
    titleAr: 'نظام DME',
    subtitleAr: 'Distance Measuring Equipment',
    icaoRef: 'ICAO Annex 10 Vol. I §3.5',
    safetyNoteAr:
        '📏 عطل DME الوحيد = فقدان خاصية تحديد المسافة بدقة — خطر على مناورات الاقتراب',
    subCriteria: [
      NavaidsSubCriteriaMeta(
        key: 'accuracy_0_1nm',
        labelAr: 'دقة المسافة المُعلَنة ±0.1 ميل أو أفضل وفق المعايير',
      ),
      NavaidsSubCriteriaMeta(
        key: 'no_query_dropout',
        labelAr: 'عدم انقطاع استجابة استسارات الطائرات — التزامن مع VOR',
      ),
      NavaidsSubCriteriaMeta(
        key: 'backup_device',
        labelAr: 'جهاز احتياطي في الحالات الحرجة أو خطة بديلة موثَّقة',
      ),
    ],
  ),
  NavaidsElementMeta(
    key: 'ils',
    titleAr: 'نظام ILS (إن وجد)',
    subtitleAr: 'Instrument Landing System',
    icaoRef: 'ICAO Annex 10 Vol. I §3.1',
    isOptional: true,
    safetyNoteAr:
        '🌫️ عطل ILS مع ضعف الرؤية = تحويل الرحلات لمطار بديل فوراً — لا هبوط CAT II/III',
    subCriteria: [
      NavaidsSubCriteriaMeta(
        key: 'llz_on_centerline',
        labelAr: 'LLZ (Localizer) على محور المدرج — انحراف جانبي دقيق كحد أقصى',
      ),
      NavaidsSubCriteriaMeta(
        key: 'gp_3_degrees',
        labelAr: 'GP (Glide Path) بزاوية اقتراب صحيحة (عادة 3 درجات) إن وُجد',
      ),
      NavaidsSubCriteriaMeta(
        key: 'markers_working',
        labelAr: 'أضواء الممرات (Markers) تعمل: Outer / Middle / Inner Marker',
      ),
      NavaidsSubCriteriaMeta(
        key: 'signal_stable_fi_match',
        labelAr:
            'استقرار الإشارة وتوافقها مع تقارير فحص الطيران الأخيرة (Flight Inspection)',
      ),
      NavaidsSubCriteriaMeta(
        key: 'rnav_backup',
        labelAr: 'توفر إجراءات بديلة (ILS backup) مثل RNAV/GPS عند انقطاع ILS',
      ),
    ],
  ),
  NavaidsElementMeta(
    key: 'atis_volmet',
    titleAr: 'خدمات المعلومات',
    subtitleAr: 'ATIS / VOLMET / D-ATIS',
    icaoRef: 'ICAO Annex 11 §4.3 / ICAO Doc 8168',
    safetyNoteAr:
        '⏰ ATIS قديم أكثر من ساعة = معلومات مضلِّلة للطيارين — تحديث فوري إلزامي',
    subCriteria: [
      NavaidsSubCriteriaMeta(
        key: 'atis_updated_metar',
        labelAr:
            'ATIS محدَّث بأحدث METAR ورونق المطار — تحديث تلقائي كل 30 دقيقة',
      ),
      NavaidsSubCriteriaMeta(
        key: 'd_atis_digital',
        labelAr: 'D-ATIS (رقمي) متاح للطائرات الحديثة عبر ACARS أو VHF data',
      ),
      NavaidsSubCriteriaMeta(
        key: 'volmet_if_international',
        labelAr:
            'بث VOLMET للمنطقة متاح إن كان المطار دولياً كبيراً (ICAO إلزامي)',
      ),
    ],
  ),
  NavaidsElementMeta(
    key: 'flight_inspection',
    titleAr: 'فحوصات الطيران',
    subtitleAr: 'Flight Inspection',
    icaoRef: 'ICAO Doc 8071 / ICAO Annex 10',
    safetyNoteAr:
        '🛩️ تجاوز موعد الفحص بأكثر من شهرين = يُغلَق النظام المتأخر فوراً لحين الفحص',
    subCriteria: [
      NavaidsSubCriteriaMeta(
        key: 'schedule_all_navaids',
        labelAr: 'جدول زمني معتمد لفحص كل NAVAID حسب ترددات ICAO Doc 8071',
      ),
      NavaidsSubCriteriaMeta(
        key: 'tolerances_met',
        labelAr:
            'جميع الأجهزة مطابقة ضمن التفاوتات المطلوبة (Tolerances) في آخر فحص',
      ),
      NavaidsSubCriteriaMeta(
        key: 'authority_approved_reports',
        labelAr:
            'تقارير الفحص موثَّقة ومعتمدة من سلطة الطيران المدني ومتاحة للمراجعة',
      ),
    ],
  ),
];

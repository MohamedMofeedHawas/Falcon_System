// lib/features/inspection/widgets/sms_section_widget.dart

import 'package:falcon_system/data/sections/sms_element_score.dart';
import 'package:falcon_system/data/sections/sms_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

import 'sms_element_card_1.dart';

/// القسم الكامل لتقييم نظام إدارة السلامة (SMS – Annex 19)
/// يُستخدم داخل _buildSMSStep() في EvaluationFormScreen
class SmsSectionWidget extends StatelessWidget {
  final SmsEvaluation evaluation;
  final ValueChanged<SmsEvaluation> onChanged;

  const SmsSectionWidget({
    super.key,
    required this.evaluation,
    required this.onChanged,
  });

  SmsEvaluation _updateElement(String key, SmsElementScore updated) {
    final e = evaluation;
    return SmsEvaluation(
      safetyPolicy: key == 'safety_policy' ? updated : e.safetyPolicy,
      riskAssessment: key == 'risk_assessment' ? updated : e.riskAssessment,
      reportingSystem: key == 'reporting_system' ? updated : e.reportingSystem,
      safetyPerformance: key == 'safety_performance'
          ? updated
          : e.safetyPerformance,
      smsTraining: key == 'sms_training' ? updated : e.smsTraining,
    );
  }

  SmsElementScore _scoreFor(String key) {
    return switch (key) {
      'safety_policy' => evaluation.safetyPolicy,
      'risk_assessment' => evaluation.riskAssessment,
      'reporting_system' => evaluation.reportingSystem,
      'safety_performance' => evaluation.safetyPerformance,
      'sms_training' => evaluation.smsTraining,
      _ => SmsElementScore(key: key),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SmsHeaderCard(evaluation: evaluation),
        const SizedBox(height: 16),

        _SmsJustCultureBanner(),
        const SizedBox(height: 16),

        ...kSmsElementsMeta.asMap().entries.map((entry) {
          final i = entry.key;
          final meta = entry.value;
          final score = _scoreFor(meta.key);
          return SmsElementCard(
            elementIndex: i,
            meta: meta,
            score: score,
            onChanged: (updated) =>
                onChanged(_updateElement(meta.key, updated)),
          );
        }),

        const SizedBox(height: 8),

        if (evaluation.criticalElements.isNotEmpty) ...[
          _SmsCriticalFindingsPanel(
            elements: evaluation.criticalElements,
            meta: kSmsElementsMeta,
          ),
          const SizedBox(height: 16),
        ],

        const _SmsGradeReferencePanel(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── بطاقة الرأس ─────────────────────────────────────────────────────────────

class _SmsHeaderCard extends StatelessWidget {
  final SmsEvaluation evaluation;
  const _SmsHeaderCard({required this.evaluation});

  Color _gradeColor(String key) => switch (key) {
    'excellent' => AppColors.excellent,
    'good' => AppColors.good,
    'acceptable' => AppColors.acceptable,
    _ => AppColors.unsafe,
  };

  // لون مميز لـ SMS — بنفسجي داكن
  
   static const Color _smsAccent = Color(0xFF37474F);
  static const Color _smsAccent2 = Color(0xFF102027);

  @override
  Widget build(BuildContext context) {
    final pct = evaluation.percentage;
    final gradeColor = _gradeColor(evaluation.gradeKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_smsAccent2, _smsAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _smsAccent.withOpacity(0.40),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نظام إدارة السلامة',
                    style: AppFonts.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    'Safety Management System (SMS – Annex 19)',
                    style: AppFonts.labelSmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              _GradePill(grade: evaluation.grade, color: gradeColor),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(
                label: 'الدرجة الكلية',
                value: '${evaluation.totalScore} / 50',
                color: Colors.white,
              ),
              _StatChip(
                label: 'النسبة المئوية',
                value: '${pct.toStringAsFixed(1)}%',
                color: gradeColor,
              ),
              _StatChip(
                label: 'العناصر الحرجة',
                value: '${evaluation.criticalElements.length}',
                color: evaluation.criticalElements.isEmpty
                    ? AppColors.excellent
                    : AppColors.unsafe,
              ),
            ],
          ),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: AppFonts.labelSmall.copyWith(color: Colors.white60),
              ),
              Text(
                'أقصى درجة = 5 × 10 = 50',
                style: AppFonts.labelSmall.copyWith(color: Colors.white60),
              ),
              Text(
                '100%',
                style: AppFonts.labelSmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── بنر ثقافة Just Culture ──────────────────────────────────────────────────

class _SmsJustCultureBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF7B1FA2).withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.balance_rounded, size: 18, color: Color(0xFF6A1B9A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppFonts.bodySmall.copyWith(
                  color: const Color(0xFF4A148C),
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'مبدأ Just Culture: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'الموظف الذي يُبلِّغ عن خطأ غير متعمَّد يُحمَى من العقوبة — هذا أساس نظام الإبلاغ الفعّال.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── لوحة العناصر الحرجة ─────────────────────────────────────────────────────

class _SmsCriticalFindingsPanel extends StatelessWidget {
  final List<SmsElementScore> elements;
  final List<SmsElementMeta> meta;

  const _SmsCriticalFindingsPanel({required this.elements, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.unsafe.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: AppColors.unsafe, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⛔ عناصر تحتاج تدخلاً عاجلاً (درجة ≤ 3)',
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.unsafe,
                    fontWeight: AppFonts.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...elements.map((el) {
            final elementMeta = meta.firstWhere((m) => m.key == el.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.unsafe,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${el.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          elementMeta.titleAr,
                          style: AppFonts.bodySmall.copyWith(
                            color: const Color(0xFFB71C1C),
                            fontWeight: AppFonts.semiBold,
                          ),
                        ),
                        Text(
                          elementMeta.safetyNoteAr,
                          style: AppFonts.labelSmall.copyWith(
                            color: const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── جدول مرجع التصنيف ────────────────────────────────────────────────────────

class _SmsGradeReferencePanel extends StatelessWidget {
  const _SmsGradeReferencePanel();

  static const Color _purple = Color(0xFF6A1B9A);
  static const Color _purpleDark = Color(0xFF4A148C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _purple.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined, size: 18, color: _purpleDark),
                const SizedBox(width: 8),
                Text(
                  'مرجع تصنيف نظام إدارة السلامة',
                  style: AppFonts.labelLarge.copyWith(
                    color: _purpleDark,
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ICAO Annex 19',
                    style: AppFonts.labelSmall.copyWith(
                      color: _purpleDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // رأس الأعمدة
          _TableHeaderRow(),

          // صفوف البيانات
          const _GradeRow(
            range: '≥ 90%',
            gradeAr: 'ممتاز',
            action: 'SMS فعّال وشامل — لا يتطلب تدخلاً',
            color: AppColors.excellent,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '75% – 89%',
            gradeAr: 'جيد',
            action: 'مقبول — يحتاج تطوير في بعض الجوانب',
            color: AppColors.good,
            isAlternate: true,
          ),
          const _GradeRow(
            range: '60% – 74%',
            gradeAr: 'مقبول',
            action: 'SMS جزئي — خطة تحسين خلال 3 أشهر إلزامية',
            color: AppColors.acceptable,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '< 60%',
            gradeAr: 'خطر',
            action: '⛔ SMS غير فعّال — مخالفة ICAO Annex 19',
            color: AppColors.unsafe,
            isAlternate: true,
            isLast: true,
          ),

          // الصيغة الحسابية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.functions, size: 16, color: Color(0xFF546E7A)),
                const SizedBox(width: 6),
                Text(
                  'النسبة = (المجموع ÷ 50) × 100',
                  style: AppFonts.labelMedium.copyWith(
                    color: const Color(0xFF455A64),
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 14,
                  color: const Color(0xFF546E7A).withOpacity(0.3),
                ),
                const SizedBox(width: 16),
                Text(
                  'أقصى درجة = 5 × 10 = 50',
                  style: AppFonts.labelMedium.copyWith(
                    color: const Color(0xFF455A64),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.textSecondary.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'النسبة',
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'التصنيف',
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'الإجراء المطلوب',
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  final String range;
  final String gradeAr;
  final String action;
  final Color color;
  final bool isAlternate;
  final bool isLast;

  const _GradeRow({
    required this.range,
    required this.gradeAr,
    required this.action,
    required this.color,
    required this.isAlternate,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAlternate
            ? AppColors.background.withOpacity(0.25)
            : Colors.transparent,
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.08),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              range,
              style: AppFonts.labelMedium.copyWith(
                color: color,
                fontWeight: AppFonts.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(
                  gradeAr,
                  style: AppFonts.labelSmall.copyWith(
                    color: color,
                    fontWeight: AppFonts.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              action,
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradePill extends StatelessWidget {
  final String grade;
  final Color color;
  const _GradePill({required this.grade, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Text(
      grade,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: AppFonts.labelSmall.copyWith(color: Colors.white60)),
    ],
  );
}

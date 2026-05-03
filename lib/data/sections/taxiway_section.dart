// lib/features/inspection/widgets/taxiway_section_widget.dart

import 'package:falcon_system/data/sections/taxiway_element_score.dart';
import 'package:falcon_system/data/sections/taxiway_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

import 'taxiway_element_card.dart';

/// القسم الكامل لتقييم ممرات التاكسي
/// يُستخدم داخل _buildTaxiwayStep() في EvaluationFormScreen
class TaxiwaySectionWidget extends StatefulWidget {
  final TaxiwayEvaluation evaluation;
  final ValueChanged<TaxiwayEvaluation> onChanged;

  const TaxiwaySectionWidget({
    super.key,
    required this.evaluation,
    required this.onChanged,
  });

  @override
  State<TaxiwaySectionWidget> createState() => _TaxiwaySectionWidgetState();
}

class _TaxiwaySectionWidgetState extends State<TaxiwaySectionWidget> {
  // ─── تحديث عنصر بعينه ─────────────────────────────────────────────────────

  TaxiwayEvaluation _updateElement(String key, TaxiwayElementScore updated) {
    final e = widget.evaluation;
    return TaxiwayEvaluation(
      widthClearances: key == 'width_clearances' ? updated : e.widthClearances,
      groundMarkings: key == 'ground_markings' ? updated : e.groundMarkings,
      lighting: key == 'lighting' ? updated : e.lighting,
      surfaceCondition: key == 'surface_condition'
          ? updated
          : e.surfaceCondition,
      directionalSigns: key == 'directional_signs'
          ? updated
          : e.directionalSigns,
      lateralStrip: key == 'lateral_strip' ? updated : e.lateralStrip,
      drainage: key == 'drainage' ? updated : e.drainage,
    );
  }

  TaxiwayElementScore _scoreFor(String key) {
    final e = widget.evaluation;
    return switch (key) {
      'width_clearances' => e.widthClearances,
      'ground_markings' => e.groundMarkings,
      'lighting' => e.lighting,
      'surface_condition' => e.surfaceCondition,
      'directional_signs' => e.directionalSigns,
      'lateral_strip' => e.lateralStrip,
      'drainage' => e.drainage,
      _ => TaxiwayElementScore(key: key),
    };
  }

  // ─── بناء الواجهة ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final eval = widget.evaluation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── بطاقة الرأس ─────────────────────────────────────────────────
        _TaxiwayHeaderCard(evaluation: eval),
        const SizedBox(height: 20),

        // ── عناصر التقييم السبعة ─────────────────────────────────────────
        ...kTaxiwayElementsMeta.asMap().entries.map((entry) {
          final i = entry.key;
          final meta = entry.value;
          final score = _scoreFor(meta.key);

          return TaxiwayElementCard(
            elementIndex: i,
            meta: meta,
            score: score,
            onChanged: (updated) {
              final newEval = _updateElement(meta.key, updated);
              widget.onChanged(newEval);
            },
          );
        }),

        const SizedBox(height: 8),

        // ── العناصر الحرجة ───────────────────────────────────────────────
        if (eval.criticalElements.isNotEmpty) ...[
          _CriticalFindingsPanel(
            elements: eval.criticalElements,
            meta: kTaxiwayElementsMeta,
          ),
          const SizedBox(height: 16),
        ],

        // ── جدول مرجع التصنيف (يظهر دائماً تحت الممرات) ────────────────
        const _TaxiwayGradeReferencePanel(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── بطاقة الرأس مع شريط التقدم ──────────────────────────────────────────────

class _TaxiwayHeaderCard extends StatelessWidget {
  final TaxiwayEvaluation evaluation;

  const _TaxiwayHeaderCard({required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final pct = evaluation.percentage;
    final color = _gradeColor(evaluation.gradeKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withOpacity(0.9),
            AppColors.primary.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان + أيقونة
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.airplanemode_active,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تقييم ممرات التاكسي',
                    style: AppFonts.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    'Taxiways Evaluation',
                    style: AppFonts.labelSmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              // التقدير الكلي
              _GradePill(grade: evaluation.grade, color: color),
            ],
          ),
          const SizedBox(height: 18),

          // الدرجة والنسبة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(
                label: 'الدرجة الكلية',
                value: '${evaluation.totalScore} / 70',
                color: Colors.white,
              ),
              _StatChip(
                label: 'النسبة المئوية',
                value: '${pct.toStringAsFixed(1)}%',
                color: color,
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

          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
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
                'أقصى درجة = 7 × 10 = 70',
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

  Color _gradeColor(String key) {
    return switch (key) {
      'excellent' => AppColors.excellent,
      'good' => AppColors.good,
      'acceptable' => AppColors.acceptable,
      _ => AppColors.unsafe,
    };
  }
}

class _GradePill extends StatelessWidget {
  final String grade;
  final Color color;

  const _GradePill({required this.grade, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
  Widget build(BuildContext context) {
    return Column(
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
}

// ─── لوحة العناصر الحرجة ─────────────────────────────────────────────────────

class _CriticalFindingsPanel extends StatelessWidget {
  final List<TaxiwayElementScore> elements;
  final List<TaxiwayElementMeta> meta;

  const _CriticalFindingsPanel({required this.elements, required this.meta});

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
              Text(
                '⛔ عناصر تحتاج تدخلاً عاجلاً (درجة ≤ 3)',
                style: AppFonts.labelMedium.copyWith(
                  color: AppColors.unsafe,
                  fontWeight: AppFonts.bold,
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

// ─── جدول مرجع التصنيف (يظهر دائماً تحت قسم ممرات التاكسي) ──────────────────

class _TaxiwayGradeReferencePanel extends StatelessWidget {
  const _TaxiwayGradeReferencePanel();

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
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'مرجع تصنيف ممرات التاكسي',
                  style: AppFonts.labelLarge.copyWith(
                    color: AppColors.primary,
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
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ICAO Annex 14',
                    style: AppFonts.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // رأس أعمدة الجدول
          _TableHeaderRow(),

          // صفوف البيانات
          _GradeRow(
            range: '≥ 90%',
            gradeAr: 'ممتاز',
            action: '— لا يتطلب تدخلاً',
            color: AppColors.excellent,
            isAlternate: false,
          ),
          _GradeRow(
            range: '75% – 89%',
            gradeAr: 'جيد',
            action: 'مراقبة دورية',
            color: AppColors.good,
            isAlternate: true,
          ),
          _GradeRow(
            range: '60% – 74%',
            gradeAr: 'مقبول',
            action: 'صيانة خلال 3 أشهر',
            color: AppColors.acceptable,
            isAlternate: false,
          ),
          _GradeRow(
            range: '< 60%',
            gradeAr: 'خطر',
            action: 'خطر على الحركة الأرضية — تدخل فوري',
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
                Icon(Icons.functions, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'النسبة = (المجموع ÷ 70) × 100',
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppFonts.semiBold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 14,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(width: 16),
                Text(
                  'أقصى درجة = 7 × 10 = 70',
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.textSecondary,
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
          // النسبة
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
          // التصنيف (شيب ملون)
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
          // الإجراء
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

// lib/features/inspection/widgets/apron_section_widget.dart

import 'package:falcon_system/data/sections/apron_element_score.dart';
import 'package:falcon_system/data/sections/apron_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

import 'apron_element_card.dart';

/// القسم الكامل لتقييم ساحات الوقوف (Apron / Ramp)
/// يُستخدم داخل _buildApronStep() في EvaluationFormScreen
class ApronSectionWidget extends StatelessWidget {
  final ApronEvaluation evaluation;
  final ValueChanged<ApronEvaluation> onChanged;

  const ApronSectionWidget({
    super.key,
    required this.evaluation,
    required this.onChanged,
  });

  // ─── تحديث عنصر بعينه ─────────────────────────────────────────────────────

  ApronEvaluation _updateElement(String key, ApronElementScore updated) {
    final e = evaluation;
    return ApronEvaluation(
      parkingStands: key == 'parking_stands' ? updated : e.parkingStands,
      vehicleMovement: key == 'vehicle_movement' ? updated : e.vehicleMovement,
      guidanceSystems: key == 'guidance_systems' ? updated : e.guidanceSystems,
      floodLighting: key == 'flood_lighting' ? updated : e.floodLighting,
      surfaceCondition: key == 'surface_condition'
          ? updated
          : e.surfaceCondition,
      supportFacilities: key == 'support_facilities'
          ? updated
          : e.supportFacilities,
      waterDrainage: key == 'water_drainage' ? updated : e.waterDrainage,
      conflictPoints: key == 'conflict_points' ? updated : e.conflictPoints,
    );
  }

  ApronElementScore _scoreFor(String key) {
    return switch (key) {
      'parking_stands' => evaluation.parkingStands,
      'vehicle_movement' => evaluation.vehicleMovement,
      'guidance_systems' => evaluation.guidanceSystems,
      'flood_lighting' => evaluation.floodLighting,
      'surface_condition' => evaluation.surfaceCondition,
      'support_facilities' => evaluation.supportFacilities,
      'water_drainage' => evaluation.waterDrainage,
      'conflict_points' => evaluation.conflictPoints,
      _ => ApronElementScore(key: key),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── بطاقة الرأس ─────────────────────────────────────────────────
        _ApronHeaderCard(evaluation: evaluation),
        const SizedBox(height: 16),

        // ── تحذير نقل العمليات ───────────────────────────────────────────
        _ApronRelocationWarning(percentage: evaluation.percentage),
        const SizedBox(height: 16),

        // ── عناصر التقييم الثمانية ───────────────────────────────────────
        ...kApronElementsMeta.asMap().entries.map((entry) {
          final i = entry.key;
          final meta = entry.value;
          final score = _scoreFor(meta.key);

          return ApronElementCard(
            elementIndex: i,
            meta: meta,
            score: score,
            onChanged: (updated) =>
                onChanged(_updateElement(meta.key, updated)),
          );
        }),

        const SizedBox(height: 8),

        // ── العناصر الحرجة ───────────────────────────────────────────────
        if (evaluation.criticalElements.isNotEmpty) ...[
          _ApronCriticalFindingsPanel(
            elements: evaluation.criticalElements,
            meta: kApronElementsMeta,
          ),
          const SizedBox(height: 16),
        ],

        // ── جدول مرجع التصنيف ────────────────────────────────────────────
        const _ApronGradeReferencePanel(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── بطاقة الرأس ─────────────────────────────────────────────────────────────

class _ApronHeaderCard extends StatelessWidget {
  final ApronEvaluation evaluation;
  const _ApronHeaderCard({required this.evaluation});

  Color _gradeColor(String key) => switch (key) {
    'excellent' => AppColors.excellent,
    'good' => AppColors.good,
    'acceptable' => AppColors.acceptable,
    _ => AppColors.unsafe,
  };

  // لون مميز لساحات الوقوف — أخضر مزرق (Teal)

   static const Color _apronAccent = Color(0xFF37474F);
  static const Color _apronAccent2 = Color(0xFF102027);

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
          colors: [_apronAccent2, _apronAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _apronAccent.withOpacity(0.40),
            blurRadius: 14,
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
                  Icons.flight_land_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ساحات الوقوف',
                    style: AppFonts.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    'Apron / Ramp Evaluation',
                    style: AppFonts.labelSmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              _GradePill(grade: evaluation.grade, color: gradeColor),
            ],
          ),
          const SizedBox(height: 18),

          // إحصائيات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(
                label: 'الدرجة الكلية',
                value: '${evaluation.totalScore} / 80',
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

          // شريط التقدم
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
                'أقصى درجة = 8 × 10 = 80',
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

// ─── تحذير نقل العمليات ──────────────────────────────────────────────────────

class _ApronRelocationWarning extends StatelessWidget {
  final double percentage;
  const _ApronRelocationWarning({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final isDanger = percentage < 60;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDanger ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDanger
              ? AppColors.unsafe.withOpacity(0.55)
              : AppColors.excellent.withOpacity(0.5),
          width: isDanger ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDanger ? Icons.swap_horiz_rounded : Icons.info_outline_rounded,
            size: 18,
            color: isDanger ? AppColors.unsafe : AppColors.excellent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppFonts.bodySmall.copyWith(height: 1.5),
                children: [
                  TextSpan(
                    text: isDanger ? '⛔ توصية ICAO: ' : '📋 تذكير: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDanger
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                  TextSpan(
                    text: isDanger
                        ? 'النسبة أقل من 60% → يُوصى بنقل العمليات إلى ساحة وقوف أخرى إن أمكن.'
                        : 'الساحة تعمل بكفاءة — تأكد من فحص FOD يومياً وإضاءة المواقف الليلية.',
                    style: TextStyle(
                      color: isDanger
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFF1B5E20),
                    ),
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

class _ApronCriticalFindingsPanel extends StatelessWidget {
  final List<ApronElementScore> elements;
  final List<ApronElementMeta> meta;

  const _ApronCriticalFindingsPanel({
    required this.elements,
    required this.meta,
  });

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

class _ApronGradeReferencePanel extends StatelessWidget {
  const _ApronGradeReferencePanel();

  static const Color _teal = Color(0xFF00796B);
  static const Color _tealDark = Color(0xFF004D40);

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
              color: _teal.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined, size: 18, color: _tealDark),
                const SizedBox(width: 8),
                Text(
                  'مرجع تصنيف ساحات الوقوف',
                  style: AppFonts.labelLarge.copyWith(
                    color: _tealDark,
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
                    color: _teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ICAO Annex 14',
                    style: AppFonts.labelSmall.copyWith(
                      color: _tealDark,
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
            action: 'آمن لجميع العمليات — لا يتطلب تدخلاً',
            color: AppColors.excellent,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '75% – 89%',
            gradeAr: 'جيد',
            action: 'متابعة دورية وصيانة وقائية',
            color: AppColors.good,
            isAlternate: true,
          ),
          const _GradeRow(
            range: '60% – 74%',
            gradeAr: 'مقبول',
            action: 'يحتاج مراقبة لصيقة — إصلاح خلال شهر',
            color: AppColors.acceptable,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '< 60%',
            gradeAr: 'خطر',
            action: 'يُوصى بنقل العمليات إلى ساحة أخرى إن أمكن',
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
                  'النسبة = (المجموع ÷ 80) × 100',
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
                  'أقصى درجة = 8 × 10 = 80',
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

// ─── مكونات الجدول ────────────────────────────────────────────────────────────

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

// ─── مساعدات مشتركة ───────────────────────────────────────────────────────────

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

// lib/features/inspection/widgets/runway_section_widget.dart

import 'package:falcon_system/data/sections/runway_element_score.dart';
import 'package:falcon_system/data/sections/runway_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';

import 'runway_element_card.dart';

/// القسم الكامل لتقييم حالة المدرج (Runway Inspection & Evaluation)
/// يُستخدم داخل _buildRunwayStep() في EvaluationFormScreen
class RunwaySectionWidget extends StatelessWidget {
  final RunwayEvaluation evaluation;
  final ValueChanged<RunwayEvaluation> onChanged;

  const RunwaySectionWidget({
    super.key,
    required this.evaluation,
    required this.onChanged,
  });

  RunwayEvaluation _updateElement(String key, RunwayElementScore updated) {
    final e = evaluation;
    return RunwayEvaluation(
      runwayLength: key == 'runway_length' ? updated : e.runwayLength,
      runwayWidth: key == 'runway_width' ? updated : e.runwayWidth,
      surfaceCondition: key == 'surface_condition'
          ? updated
          : e.surfaceCondition,
      resa: key == 'resa' ? updated : e.resa,
      markings: key == 'markings' ? updated : e.markings,
      lighting: key == 'lighting' ? updated : e.lighting,
      ofz: key == 'ofz' ? updated : e.ofz,
      pcn: key == 'pcn' ? updated : e.pcn,
      drainage: key == 'drainage' ? updated : e.drainage,
      signs: key == 'signs' ? updated : e.signs,
      fuelDrainage: key == 'fuel_drainage' ? updated : e.fuelDrainage,
      edgesShoulders: key == 'edges_shoulders' ? updated : e.edgesShoulders,
    );
  }

  RunwayElementScore _scoreFor(String key) => switch (key) {
    'runway_length' => evaluation.runwayLength,
    'runway_width' => evaluation.runwayWidth,
    'surface_condition' => evaluation.surfaceCondition,
    'resa' => evaluation.resa,
    'markings' => evaluation.markings,
    'lighting' => evaluation.lighting,
    'ofz' => evaluation.ofz,
    'pcn' => evaluation.pcn,
    'drainage' => evaluation.drainage,
    'signs' => evaluation.signs,
    'fuel_drainage' => evaluation.fuelDrainage,
    'edges_shoulders' => evaluation.edgesShoulders,
    _ => RunwayElementScore(key: key),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RunwayHeaderCard(evaluation: evaluation),
        const SizedBox(height: 16),

        // تحذير الإغلاق
        _RunwayClosureWarning(percentage: evaluation.percentage),
        const SizedBox(height: 16),

        // العناصر الـ 12
        ...kRunwayElementsMeta.asMap().entries.map((entry) {
          final i = entry.key;
          final meta = entry.value;
          return RunwayElementCard(
            elementIndex: i,
            meta: meta,
            score: _scoreFor(meta.key),
            onChanged: (updated) =>
                onChanged(_updateElement(meta.key, updated)),
          );
        }),

        const SizedBox(height: 8),

        if (evaluation.criticalElements.isNotEmpty) ...[
          _RunwayCriticalPanel(
            elements: evaluation.criticalElements,
            meta: kRunwayElementsMeta,
          ),
          const SizedBox(height: 16),
        ],

        const _RunwayGradeReferencePanel(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── بطاقة الرأس ─────────────────────────────────────────────────────────────

class _RunwayHeaderCard extends StatelessWidget {
  final RunwayEvaluation evaluation;
  const _RunwayHeaderCard({required this.evaluation});

  Color _gradeColor(String key) => switch (key) {
    'excellent' => AppColors.excellent,
    'good' => AppColors.good,
    'acceptable' => AppColors.acceptable,
    _ => AppColors.unsafe,
  };

  // لون مميز للمدرج — رمادي معدني داكن
  static const Color _rwyAccent = Color(0xFF37474F);
  static const Color _rwyAccent2 = Color(0xFF102027);

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
          colors: [_rwyAccent2, _rwyAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _rwyAccent.withOpacity(0.50),
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
                  Icons.flight_takeoff_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تدقيق وتقييم حالة المدرج',
                    style: AppFonts.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    'Runway Inspection & Evaluation',
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
                value: '${evaluation.totalScore} / 120',
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
                'أقصى درجة = 12 × 10 = 120',
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

// ─── تحذير الإغلاق ───────────────────────────────────────────────────────────

class _RunwayClosureWarning extends StatelessWidget {
  final double percentage;
  const _RunwayClosureWarning({required this.percentage});

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
              : AppColors.excellent.withOpacity(0.4),
          width: isDanger ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDanger ? Icons.do_not_disturb_on : Icons.check_circle_outline,
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
                    text: isDanger ? '⛔ توصية: ' : '✅ وضع المدرج: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDanger
                          ? const Color(0xFFB71C1C)
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                  TextSpan(
                    text: isDanger
                        ? 'النسبة أقل من 60% → يُوصى بإغلاق المدرج حتى الإصلاح'
                        : 'المدرج في حالة مقبولة — تابع باقي العناصر للحصول على تقييم شامل',
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

class _RunwayCriticalPanel extends StatelessWidget {
  final List<RunwayElementScore> elements;
  final List<RunwayElementMeta> meta;
  const _RunwayCriticalPanel({required this.elements, required this.meta});

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

class _RunwayGradeReferencePanel extends StatelessWidget {
  const _RunwayGradeReferencePanel();

  static const Color _steel = Color(0xFF37474F);
  static const Color _steelDark = Color(0xFF102027);

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
              color: _steel.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined, size: 18, color: _steelDark),
                const SizedBox(width: 8),
                Text(
                  'تصنيف حالة المدرج حسب النسبة',
                  style: AppFonts.labelLarge.copyWith(
                    color: _steelDark,
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
                    color: _steel.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ICAO Annex 14',
                    style: AppFonts.labelSmall.copyWith(
                      color: _steelDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _TableHeaderRow(),

          const _GradeRow(
            range: '90% – 100%',
            gradeAr: 'ممتاز',
            action: 'صالح لأعلى الاستخدامات — لا تدخل مطلوب',
            color: AppColors.excellent,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '75% – 89%',
            gradeAr: 'جيد',
            action: 'جيد مع ملاحظات بسيطة — صيانة وقائية',
            color: AppColors.good,
            isAlternate: true,
          ),
          const _GradeRow(
            range: '60% – 74%',
            gradeAr: 'مقبول',
            action: 'يحتاج صيانة خلال 3 أشهر — مراقبة مكثفة',
            color: AppColors.acceptable,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '< 60%',
            gradeAr: 'غير آمن',
            action: '⛔ يُوصى بإغلاق المدرج حتى الإصلاح',
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.functions,
                      size: 16,
                      color: Color(0xFF546E7A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'النسبة = (المجموع ÷ 120) × 100',
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
                      'أقصى درجة = 12 × 10 = 120',
                      style: AppFonts.labelMedium.copyWith(
                        color: const Color(0xFF455A64),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // مثال من المستند
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.good.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.good.withOpacity(0.25)),
                  ),
                  child: Text(
                    'مثال: مجموع 101 من 120 → (101/120) × 100 = 84.2% → جيد',
                    style: AppFonts.labelSmall.copyWith(
                      color: AppColors.good,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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
  Widget build(BuildContext context) => Container(
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

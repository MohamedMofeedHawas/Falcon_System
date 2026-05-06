// lib/features/inspection/widgets/met_section_widget.dart

import 'package:falcon_system/data/sections/met_element_score.dart';
import 'package:falcon_system/data/sections/met_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

import 'met_element_card.dart';

/// القسم الكامل لتقييم خدمات الأرصاد الجوية (MET)
/// يُستخدم داخل _buildMETStep() في EvaluationFormScreen
class MetSectionWidget extends StatelessWidget {
  final MetEvaluation evaluation;
  final ValueChanged<MetEvaluation> onChanged;

  const MetSectionWidget({
    super.key,
    required this.evaluation,
    required this.onChanged,
  });

  // ─── تحديث عنصر بعينه ─────────────────────────────────────────────────────

  MetEvaluation _updateElement(String key, MetElementScore updated) {
    final e = evaluation;
    return MetEvaluation(
      aviationReports: key == 'aviation_reports' ? updated : e.aviationReports,
      basicEquipment: key == 'basic_equipment' ? updated : e.basicEquipment,
      advancedEquipment: key == 'advanced_equipment'
          ? updated
          : e.advancedEquipment,
      informationTransfer: key == 'information_transfer'
          ? updated
          : e.informationTransfer,
      maintenanceCalibration: key == 'maintenance_calibration'
          ? updated
          : e.maintenanceCalibration,
      aviationForecasts: key == 'aviation_forecasts'
          ? updated
          : e.aviationForecasts,
    );
  }

  MetElementScore _scoreFor(String key) {
    return switch (key) {
      'aviation_reports' => evaluation.aviationReports,
      'basic_equipment' => evaluation.basicEquipment,
      'advanced_equipment' => evaluation.advancedEquipment,
      'information_transfer' => evaluation.informationTransfer,
      'maintenance_calibration' => evaluation.maintenanceCalibration,
      'aviation_forecasts' => evaluation.aviationForecasts,
      _ => MetElementScore(key: key),
    };
  }

  // ─── بناء الواجهة ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── بطاقة الرأس ─────────────────────────────────────────────────
        _MetHeaderCard(evaluation: evaluation),
        const SizedBox(height: 20),

        // ── ملاحظة درجة حرجة خاصة بـ MET ───────────────────────────────
        _MetCriticalNote(),
        const SizedBox(height: 16),

        // ── عناصر التقييم الستة ──────────────────────────────────────────
        ...kMetElementsMeta.asMap().entries.map((entry) {
          final i = entry.key;
          final meta = entry.value;
          final score = _scoreFor(meta.key);

          return MetElementCard(
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
          _MetCriticalFindingsPanel(
            elements: evaluation.criticalElements,
            meta: kMetElementsMeta,
          ),
          const SizedBox(height: 16),
        ],

        // ── جدول مرجع التصنيف (يظهر دائماً تحت المدرجات) ────────────────
        const _MetGradeReferencePanel(),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── بطاقة الرأس ─────────────────────────────────────────────────────────────

class _MetHeaderCard extends StatelessWidget {
  final MetEvaluation evaluation;
  const _MetHeaderCard({required this.evaluation});

  Color _gradeColor(String key) => switch (key) {
    'excellent' => AppColors.excellent,
    'good' => AppColors.good,
    'acceptable' => AppColors.acceptable,
    _ => AppColors.unsafe,
  };

  // لون خاص بالأرصاد — سماوي معدّل
  static const Color _metAccent = Color(0xFF0288D1);

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
          colors: [Color(0xFF01579B), Color(0xFF0288D1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _metAccent.withOpacity(0.35),
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
                  Icons.cloud_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خدمات الأرصاد الجوية',
                    style: AppFonts.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    'Meteorological Services (MET)',
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
                value: '${evaluation.totalScore} / 60',
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
                'أقصى درجة = 6 × 10 = 60',
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

// ─── ملاحظة الدرجة الحرجة الخاصة بـ MET ─────────────────────────────────────

class _MetCriticalNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF1565C0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppFonts.bodySmall.copyWith(
                  color: const Color(0xFF0D47A1),
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'درجة حرجة: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        'إذا تعطّل مقياس الرياح أو RVR لأكثر من 4 ساعات متواصلة دون بديل → يُغلق المدرج ليلاً وفي الضباب.',
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

class _MetCriticalFindingsPanel extends StatelessWidget {
  final List<MetElementScore> elements;
  final List<MetElementMeta> meta;

  const _MetCriticalFindingsPanel({required this.elements, required this.meta});

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

// ─── جدول مرجع التصنيف ────────────────────────────────────────────────────────

class _MetGradeReferencePanel extends StatelessWidget {
  const _MetGradeReferencePanel();

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
          // ── رأس الجدول ─────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE3F2FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart_outlined,
                  size: 18,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 8),
                Text(
                  'مرجع تصنيف خدمات الأرصاد الجوية',
                  style: AppFonts.labelLarge.copyWith(
                    color: const Color(0xFF1565C0),
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
                    color: const Color(0xFF1E88E5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ICAO Annex 3',
                    style: AppFonts.labelSmall.copyWith(
                      color: const Color(0xFF1565C0),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── رأس الأعمدة ────────────────────────────────────────────────
          _TableHeaderRow(),

          // ── صفوف البيانات ──────────────────────────────────────────────
          const _GradeRow(
            range: '≥ 90%',
            gradeAr: 'ممتاز',
            action: 'لا يتطلب تدخلاً — جميع الأجهزة تعمل',
            color: AppColors.excellent,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '75% – 89%',
            gradeAr: 'جيد',
            action: 'يحتاج تحديث RVRs وصيانة دورية',
            color: AppColors.good,
            isAlternate: true,
          ),
          const _GradeRow(
            range: '60% – 74%',
            gradeAr: 'مقبول',
            action: 'مراقبة مستمرة — إصلاح خلال شهر',
            color: AppColors.acceptable,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '< 60%',
            gradeAr: 'خطر',
            action: 'تدخل فوري — قد يُغلق المدرج ليلاً وفي الضباب',
            color: AppColors.unsafe,
            isAlternate: true,
            isLast: true,
          ),

          // ── الصيغة الحسابية ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.functions, size: 16, color: Color(0xFF546E7A)),
                const SizedBox(width: 6),
                Text(
                  'النسبة = (المجموع ÷ 60) × 100',
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
                  'أقصى درجة = 6 × 10 = 60',
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

// ─── مساعدات مشتركة ───────────────────────────────────────────────────────────

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

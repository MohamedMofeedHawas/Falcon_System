// lib/features/inspection/widgets/navaids_section_widget.dart

import 'package:falcon_system/data/sections/navaids_element_score.dart';
import 'package:falcon_system/data/sections/navaids_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

import 'navaids_element_card.dart';

/// القسم الكامل لتقييم المساعدات الملاحية (NAVAIDs)
class NavaidsSection extends StatelessWidget {
  final NavaidsEvaluation evaluation;
  final ValueChanged<NavaidsEvaluation> onChanged;

  const NavaidsSection({
    super.key,
    required this.evaluation,
    required this.onChanged,
  });

  NavaidsEvaluation _updateElement(String key, NavaidsElementScore updated) {
    final e = evaluation;
    return NavaidsEvaluation(
      hasILS: e.hasILS,
      papiVasi: key == 'papi_vasi' ? updated : e.papiVasi,
      vor: key == 'vor' ? updated : e.vor,
      dme: key == 'dme' ? updated : e.dme,
      ils: key == 'ils' ? updated : e.ils,
      atisVolmet: key == 'atis_volmet' ? updated : e.atisVolmet,
      flightInspection: key == 'flight_inspection'
          ? updated
          : e.flightInspection,
    );
  }

  NavaidsElementScore _scoreFor(String key) => switch (key) {
    'papi_vasi' => evaluation.papiVasi,
    'vor' => evaluation.vor,
    'dme' => evaluation.dme,
    'ils' => evaluation.ils,
    'atis_volmet' => evaluation.atisVolmet,
    'flight_inspection' => evaluation.flightInspection,
    _ => NavaidsElementScore(key: key),
  };

  @override
  Widget build(BuildContext context) {
    // العناصر المعروضة: ILS يُعرض فقط إذا hasILS = true
    final visibleMeta = kNavaidsElementsMeta
        .where((m) => !m.isOptional || evaluation.hasILS)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NavaidsHeaderCard(evaluation: evaluation),
        const SizedBox(height: 16),

        // Toggle ILS
        _IlsToggle(
          hasILS: evaluation.hasILS,
          onChanged: (val) => onChanged(
            NavaidsEvaluation(
              hasILS: val,
              papiVasi: evaluation.papiVasi,
              vor: evaluation.vor,
              dme: evaluation.dme,
              ils: evaluation.ils,
              atisVolmet: evaluation.atisVolmet,
              flightInspection: evaluation.flightInspection,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // عناصر التقييم
        ...visibleMeta.asMap().entries.map((entry) {
          final i = entry.key;
          final meta = entry.value;
          final score = _scoreFor(meta.key);
          return NavaidsElementCard(
            elementIndex: i,
            meta: meta,
            score: score,
            onChanged: (updated) =>
                onChanged(_updateElement(meta.key, updated)),
          );
        }),

        const SizedBox(height: 8),

        if (evaluation.criticalElements.isNotEmpty) ...[
          _NavaidsCriticalPanel(
            elements: evaluation.criticalElements,
            meta: kNavaidsElementsMeta,
          ),
          const SizedBox(height: 16),
        ],

        _NavaidsGradeReferencePanel(hasILS: evaluation.hasILS),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Toggle ILS ───────────────────────────────────────────────────────────────

class _IlsToggle extends StatelessWidget {
  final bool hasILS;
  final ValueChanged<bool> onChanged;
  const _IlsToggle({required this.hasILS, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasILS
            ? const Color(0xFFE3F2FD)
            : AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasILS
              ? const Color(0xFF1E88E5).withOpacity(0.4)
              : AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasILS ? Icons.flight_land : Icons.flight_land_outlined,
            size: 20,
            color: hasILS ? const Color(0xFF1565C0) : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'هل المطار مزوَّد بـ ILS؟',
                  style: AppFonts.bodySmall.copyWith(
                    color: hasILS
                        ? const Color(0xFF0D47A1)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hasILS
                      ? 'نعم — أقصى درجة = 60 (6 × 10)'
                      : 'لا — أقصى درجة = 50 (5 × 10) — عنصر ILS مستثنى',
                  style: AppFonts.labelSmall.copyWith(
                    color: hasILS
                        ? const Color(0xFF1565C0)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: hasILS,
            onChanged: onChanged,
            activeColor: const Color(0xFF1565C0),
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة الرأس ─────────────────────────────────────────────────────────────

class _NavaidsHeaderCard extends StatelessWidget {
  final NavaidsEvaluation evaluation;
  const _NavaidsHeaderCard({required this.evaluation});

  Color _gradeColor(String key) => switch (key) {
    'excellent' => AppColors.excellent,
    'good' => AppColors.good,
    'acceptable' => AppColors.acceptable,
    _ => AppColors.unsafe,
  };

  // لون مميز للملاحة — كحلي فيروزي

     static const Color _navAccent = Color(0xFF37474F);
  static const Color _navAccent2 = Color(0xFF102027);

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
          colors: [_navAccent2, _navAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _navAccent.withOpacity(0.40),
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
                child: const Icon(Icons.radar, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المساعدات الملاحية',
                    style: AppFonts.headline6.copyWith(
                      color: Colors.white,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  Text(
                    'NAVAIDs Evaluation',
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
                value: '${evaluation.totalScore} / ${evaluation.maxScore}',
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
                evaluation.hasILS
                    ? 'أقصى درجة = 6 × 10 = 60 (مع ILS)'
                    : 'أقصى درجة = 5 × 10 = 50 (بدون ILS)',
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

// ─── لوحة العناصر الحرجة ─────────────────────────────────────────────────────

class _NavaidsCriticalPanel extends StatelessWidget {
  final List<NavaidsElementScore> elements;
  final List<NavaidsElementMeta> meta;
  const _NavaidsCriticalPanel({required this.elements, required this.meta});

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

class _NavaidsGradeReferencePanel extends StatelessWidget {
  final bool hasILS;
  const _NavaidsGradeReferencePanel({required this.hasILS});

  static const Color _cyan = Color(0xFF006064);
  static const Color _cyanDark = Color(0xFF00363A);

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
              color: _cyan.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.table_chart_outlined, size: 18, color: _cyanDark),
                const SizedBox(width: 8),
                Text(
                  'مرجع تصنيف المساعدات الملاحية',
                  style: AppFonts.labelLarge.copyWith(
                    color: _cyanDark,
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
                    color: _cyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'ICAO Annex 10',
                    style: AppFonts.labelSmall.copyWith(
                      color: _cyanDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          _TableHeaderRow(),

          const _GradeRow(
            range: '≥ 90%',
            gradeAr: 'ممتاز',
            action: 'جميع NAVAIDs تعمل بكامل طاقتها',
            color: AppColors.excellent,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '75% – 89%',
            gradeAr: 'جيد',
            action: 'صيانة دورية + تحديث جدول فحوصات الطيران',
            color: AppColors.good,
            isAlternate: true,
          ),
          const _GradeRow(
            range: '60% – 74%',
            gradeAr: 'مقبول',
            action: 'إجراءات بديلة جاهزة — إصلاح خلال شهر',
            color: AppColors.acceptable,
            isAlternate: false,
          ),
          const _GradeRow(
            range: '< 60%',
            gradeAr: 'خطر',
            action: '⛔ NAVAIDs حرجة معطَّلة — قد يُقيَّد التشغيل الليلي',
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
                  hasILS
                      ? 'النسبة = (المجموع ÷ 60) × 100'
                      : 'النسبة = (المجموع ÷ 50) × 100',
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
                  hasILS
                      ? 'أقصى درجة = 6 × 10 = 60'
                      : 'أقصى درجة = 5 × 10 = 50',
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

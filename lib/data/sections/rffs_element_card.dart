// lib/features/inspection/widgets/rffs_element_card.dart

import 'package:falcon_system/data/sections/rffs_element_score.dart';
import 'package:falcon_system/data/sections/rffs_evaluation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';


class RffsElementCard extends StatefulWidget {
  final int elementIndex;
  final RffsElementMeta meta;
  final RffsElementScore score;
  final ValueChanged<RffsElementScore> onChanged;

  const RffsElementCard({
    super.key,
    required this.elementIndex,
    required this.meta,
    required this.score,
    required this.onChanged,
  });

  @override
  State<RffsElementCard> createState() => _RffsElementCardState();
}

class _RffsElementCardState extends State<RffsElementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.score.notes);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    if (widget.elementIndex == 0) {
      _isExpanded = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _scoreColor(int s) {
    if (s >= 8) return AppColors.excellent;
    if (s >= 6) return AppColors.good;
    if (s >= 4) return AppColors.acceptable;
    return AppColors.unsafe;
  }

  String _scoreLabel(int s) {
    if (s >= 8) return 'ممتاز';
    if (s >= 6) return 'جيد';
    if (s >= 4) return 'مقبول';
    return 'ضعيف';
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.score.score;
    final color = _scoreColor(s);
    final meta = widget.meta;

    // تمييز خاص لعنصري "مواد الإطفاء" و"الفئة" لخطورتهما القصوى
    final isZeroRisk =
        meta.key == 'extinguishing_agents' || meta.key == 'icao_category';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border(right: BorderSide(color: color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(_isExpanded ? 0.15 : 0.06),
              blurRadius: _isExpanded ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── رأس الكارد ──────────────────────────────────────────────
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _toggleExpand,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.elementIndex + 1}',
                        style: AppFonts.labelLarge.copyWith(
                          color: color,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meta.titleAr,
                                  style: AppFonts.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: AppFonts.semiBold,
                                  ),
                                ),
                              ),
                              
                              // شارة "تقييم 0" لعناصر الخطر القصوى
                              if (isZeroRisk)
                           
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.unsafe,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'قد يُصفَّر',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta.subtitleAr,
                            style: AppFonts.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _ScoreBadge(score: s, color: color),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 280),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color: color.withOpacity(0.2),
                    indent: 16,
                    endIndent: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── تحذير التصفير لعناصر الخطر ──────────────
                        if (isZeroRisk) ...[
                          _ZeroScoreWarning(elementKey: meta.key),
                          const SizedBox(height: 10),
                        ],

                        // ── المعايير الفرعية ──────────────────────────
                        _RffsSubCriteriaSection(
                          meta: meta,
                          checked: widget.score.subCriteriaChecked,
                          onChanged: (key, val) {
                            final updated = Map<String, bool>.from(
                              widget.score.subCriteriaChecked,
                            )..[key] = val;
                            widget.onChanged(
                              widget.score.copyWith(
                                subCriteriaChecked: updated,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── تنبيه السلامة ─────────────────────────────
                        _RffsSafetyBanner(note: meta.safetyNoteAr, score: s),
                        const SizedBox(height: 16),

                        // ── شريط الدرجة ──────────────────────────────
                        Row(
                          children: [
                            Text(
                              'الدرجة:',
                              style: AppFonts.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            _ScoreChip(
                              score: s,
                              label: _scoreLabel(s),
                              color: color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: color,
                            inactiveTrackColor: color.withOpacity(0.18),
                            thumbColor: color,
                            overlayColor: color.withOpacity(0.15),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                            trackHeight: 6,
                            valueIndicatorColor: color,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: Slider(
                            value: s.toDouble(),
                            min: 0,
                            max: 10,
                            divisions: 10,
                            label: '$s',
                            onChanged: (val) {
                              widget.onChanged(
                                widget.score.copyWith(score: val.toInt()),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(11, (i) {
                              final isActive = i <= s;
                              return Text(
                                '$i',
                                style: AppFonts.labelSmall.copyWith(
                                  color: isActive
                                      ? color
                                      : AppColors.textSecondary.withOpacity(
                                          0.4,
                                        ),
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  fontSize: i == s ? 13 : 10,
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── ملاحظات المفتش ────────────────────────────
                        Text(
                          'ملاحظات المفتش:',
                          style: AppFonts.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          textDirection: TextDirection.rtl,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'أدخل ملاحظاتك حول ${meta.titleAr}...',
                            hintStyle: AppFonts.bodySmall.copyWith(
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            filled: true,
                            fillColor: AppColors.background.withOpacity(0.5),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: color, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.textSecondary.withOpacity(0.2),
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            widget.onChanged(widget.score.copyWith(notes: val));
                          },
                        ),

                        // ── مرجع ICAO ─────────────────────────────────
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                meta.icaoRef,
                                style: AppFonts.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── تحذير التصفير الخاص بـ RFFS ─────────────────────────────────────────────

class _ZeroScoreWarning extends StatelessWidget {
  final String elementKey;
  const _ZeroScoreWarning({required this.elementKey});

  @override
  Widget build(BuildContext context) {
    final msg = elementKey == 'extinguishing_agents'
        ? 'نقص المياه أو رغوة منتهية الصلاحية = يُضبَط التقييم على 0 تلقائياً'
        : 'فئة ICAO غير مطابقة = يُغلق المطار للطائرات الكبيرة — راجع الفئة أولاً';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB71C1C).withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.block, size: 16, color: Color(0xFFB71C1C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: AppFonts.labelSmall.copyWith(
                color: const Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── المعايير الفرعية ─────────────────────────────────────────────────────────

class _RffsSubCriteriaSection extends StatelessWidget {
  final RffsElementMeta meta;
  final Map<String, bool> checked;
  final void Function(String key, bool val) onChanged;

  const _RffsSubCriteriaSection({
    required this.meta,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                'المعايير الفرعية',
                style: AppFonts.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: AppFonts.semiBold,
                ),
              ),
              const Spacer(),
              Text(
                '${checked.values.where((v) => v).length}/${meta.subCriteria.length}',
                style: AppFonts.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...meta.subCriteria.map((sub) {
            final isChecked = checked[sub.key] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => onChanged(sub.key, !isChecked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? AppColors.good
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isChecked
                                ? AppColors.good
                                : AppColors.textSecondary.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(
                                Icons.check,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sub.labelAr,
                          style: AppFonts.bodySmall.copyWith(
                            color: isChecked
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── تنبيه السلامة ────────────────────────────────────────────────────────────

class _RffsSafetyBanner extends StatelessWidget {
  final String note;
  final int score;
  const _RffsSafetyBanner({required this.note, required this.score});

  @override
  Widget build(BuildContext context) {
    final isCritical = score <= 3;
    final bgColor = isCritical
        ? const Color(0xFFFFEBEE)
        : const Color(0xFFFFF8E1);
    final borderColor = isCritical ? AppColors.unsafe : AppColors.acceptable;
    final textColor = isCritical
        ? const Color(0xFFB71C1C)
        : const Color(0xFFE65100);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.error_outline : Icons.warning_amber_rounded,
            color: borderColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: AppFonts.bodySmall.copyWith(color: textColor, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── الشارات المشتركة ─────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreBadge({required this.score, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(
      '$score/10',
      style: AppFonts.labelMedium.copyWith(
        color: color,
        fontWeight: AppFonts.bold,
      ),
    ),
  );
}

class _ScoreChip extends StatelessWidget {
  final int score;
  final String label;
  final Color color;
  const _ScoreChip({
    required this.score,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$score — $label',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

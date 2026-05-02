import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class EvaluationSlider extends StatefulWidget {
  final String label;
  final String? englishLabel;
  final int value;
  final Function(int) onChanged;
  final String? note;
  final String? warning;
  final bool enabled;

  const EvaluationSlider({
    super.key,
    required this.label,
    this.englishLabel,
    required this.value,
    required this.onChanged,
    this.note,
    this.warning,
    this.enabled = true,
  });

  @override
  State<EvaluationSlider> createState() => _EvaluationSliderState();
}

class _EvaluationSliderState extends State<EvaluationSlider> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSliderColor(widget.value);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: AppFonts.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (widget.englishLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.englishLabel!,
                          style: AppFonts.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Text(
                          '${widget.value}/10',
                          style: AppFonts.labelLarge.copyWith(
                            color: color,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ),
                    ],
                ),
                // Score Badge
                
            )],
            ),
            const SizedBox(height: 16),
            // Slider
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                activeTrackColor: color,
                inactiveTrackColor: AppColors.border,
                thumbColor: color,
                overlayColor: color.withOpacity(0.1),
                valueIndicatorColor: color,
                valueIndicatorTextStyle: AppFonts.labelMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: AppFonts.bold,
                ),
              ),
              child: Slider(
                value: widget.value.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: widget.enabled ? (v) => widget.onChanged(v.toInt()) : null,
              ),
            ),
            const SizedBox(height: 12),
            // Warning
            if (widget.warning != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.warning!,
                        style: AppFonts.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.warning != null) const SizedBox(height: 12),
            // Note Field
            if (widget.note != null || !widget.enabled)
              TextField(
                controller: _noteController,
                maxLines: 3,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  labelText: 'ملاحظة المفتش',
                  hintText: 'أضف ملاحظاتك هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
                  ),
                  filled: true,
                  fillColor: widget.enabled ? AppColors.background : AppColors.border,
                  contentPadding: const EdgeInsets.all(12),
                  labelStyle: AppFonts.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  hintStyle: AppFonts.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                style: AppFonts.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Color _getSliderColor(int value) {
    if (value >= 9) return AppColors.sliderGreen;
    if (value >= 7) return AppColors.sliderYellow;
    if (value >= 5) return AppColors.sliderOrange;
    return AppColors.sliderRed;
  }
}

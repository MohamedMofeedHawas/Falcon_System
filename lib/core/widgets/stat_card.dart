import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sublabel;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.sublabel,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundColor ?? AppColors.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  if (sublabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSublabelColor(sublabel!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sublabel!,
                        style: AppFonts.labelSmall.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: AppFonts.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppFonts.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppFonts.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSublabelColor(String sublabel) {
    if (sublabel.contains('عاجل') || sublabel.contains('غير آمن')) {
      return AppColors.danger;
    } else if (sublabel.contains('قريباً') || sublabel.contains('تصحيح')) {
      return AppColors.warning;
    } else if (sublabel.contains('نشط') || sublabel.contains('ممتاز')) {
      return AppColors.success;
    } else {
      return AppColors.info;
    }
  }
}

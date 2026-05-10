import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Function()? onTap;
  final FocusNode? focusNode;
  final String? counterText;
  final bool isRequired;
  

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.counterText,
    this.isRequired = false, 
   
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      style: AppFonts.bodyMedium,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, end: 12),
                child: suffixIcon,
              )
            : null,
        counterText: counterText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2),
        ),
        filled: true,
        fillColor: enabled ? AppColors.background : AppColors.border,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppFonts.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppFonts.labelMedium.copyWith(color: AppColors.textHint),
        errorStyle: AppFonts.labelSmall.copyWith(color: AppColors.danger),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../constants/app_strings.dart';

class SignaturePad extends StatefulWidget {
  final String? initialSignature;
  final Function(Uint8List?) onSignatureChanged;
  final double height;
  final Color? strokeColor;
  final double strokeWidth;

  const SignaturePad({
    super.key,
    this.initialSignature,
    required this.onSignatureChanged,
    this.height = 200,
    this.strokeColor,
    this.strokeWidth = 3.0,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  late final SignatureController _controller;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.strokeWidth,
      penColor: widget.strokeColor ?? AppColors.textPrimary,
      exportBackgroundColor: Colors.transparent,
      onDrawStart: () => setState(() => _hasSignature = true),
      onDrawEnd: () => _exportSignature(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportSignature() async {
    if (_hasSignature) {
      final signature = await _controller.toPngBytes();
      widget.onSignatureChanged(signature);
    } else {
      widget.onSignatureChanged(null);
    }
  }

  void _clearSignature() {
    _controller.clear();
    setState(() => _hasSignature = false);
    widget.onSignatureChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.signature,
                style: AppFonts.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppFonts.bold,
                ),
              ),
              if (_hasSignature)
                TextButton.icon(
                  onPressed: _clearSignature,
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  label: Text(
                    AppStrings.clearSignature,
                    style: AppFonts.labelSmall.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Signature Canvas
          Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasSignature ? AppColors.primary : AppColors.border,
                width: _hasSignature ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: _controller,
                height: widget.height,
                backgroundColor: AppColors.background,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Instructions
          Text(
            'قم بالتوقيع في المربع أعلاه',
            style: AppFonts.labelSmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class SignatureDisplay extends StatelessWidget {
  final Uint8List? signatureData;
  final String? signerName;
  final String? signerTitle;
  final DateTime? signedAt;
  final VoidCallback? onClear;

  const SignatureDisplay({
    super.key,
    required this.signatureData,
    this.signerName,
    this.signerTitle,
    this.signedAt,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (signatureData == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_outlined,
                size: 32,
                color: AppColors.textHint.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'لا يوجد توقيع',
                style: AppFonts.labelSmall.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Signature Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(signatureData!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          // Signer Info
          if (signerName != null || signerTitle != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (signerName != null)
                        Text(
                          signerName!,
                          style: AppFonts.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      if (signerTitle != null)
                        Text(
                          signerTitle!,
                          style: AppFonts.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (signedAt != null)
                  Text(
                    _formatDate(signedAt!),
                    style: AppFonts.labelSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                if (onClear != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

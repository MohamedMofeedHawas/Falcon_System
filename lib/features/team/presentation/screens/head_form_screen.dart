import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/loading_overlay.dart';
import 'package:falcon_system/core/widgets/section_header.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/features/team/presentation/cubit/team_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeadFormScreen extends StatefulWidget {
  final InspectionHead? head;

  const HeadFormScreen({super.key, this.head});

  @override
  State<HeadFormScreen> createState() => _HeadFormScreenState();
}

class _HeadFormScreenState extends State<HeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _rankController = TextEditingController();
  final _notesController = TextEditingController();

  Uint8List? _signature;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.head != null) {
      _loadHeadData();
    }
  }

  void _loadHeadData() {
    final head = widget.head!;
    _fullNameController.text = head.fullName;
    _specializationController.text = head.specialization;
    _rankController.text = head.rank ?? '';
    _signature = head.signature;
    _notesController.text = head.notes ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _specializationController.dispose();
    _rankController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveHead() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final head = InspectionHead(
        id: widget.head?.id ?? '',
        fullName: _fullNameController.text.trim(),
        specialization: _specializationController.text.trim(),
        rank: _rankController.text.trim().isEmpty
            ? null
            : _rankController.text.trim(),
        signature: _signature,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.head?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.head == null) {
        context.read<TeamCubit>().addHead(head);
      } else {
        context.read<TeamCubit>().updateHead(head);
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات رئيس الفريق ✓'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.head == null ? 'رئيس فريق جديد' : 'تعديل رئيس الفريق',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    icon: Icons.person_pin,
                    title: 'رئيس فريق الفحص',
                    subtitle: 'بيانات رئيس فريق الفحص',
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: AppStrings.fullName,
                    hint: 'أدخل الاسم الكامل',
                    controller: _fullNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'التخصص',
                    hint: 'أدخل التخصص',
                    controller: _specializationController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال التخصص';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: AppStrings.rank,
                    hint: 'أدخل الرتبة (اختياري)',
                    controller: _rankController,
                  ),
                  const SizedBox(height: 24),

                  SectionHeader(
                    icon: Icons.draw,
                    title: 'التوقيع',
                    subtitle: 'التوقيع الرقمي',
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('توقيع رئيس الفريق', style: AppFonts.labelMedium),
                      const SizedBox(height: 8),
                      SignaturePad(
                        onSignatureChanged: (signature) {
                          setState(() {
                            _signature = signature;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SectionHeader(
                    icon: Icons.note,
                    title: 'ملاحظات إضافية',
                    subtitle: 'أي ملاحظات إضافية (اختياري)',
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'ملاحظات',
                    hint: 'أدخل أي ملاحظات إضافية',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveHead,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.head == null
                                  ? 'إضافة رئيس الفريق'
                                  : 'حفظ التعديلات',
                              style: AppFonts.titleMedium,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const LoadingOverlay(isLoading: true, child: SizedBox()),
        ],
      ),
    );
  }
}

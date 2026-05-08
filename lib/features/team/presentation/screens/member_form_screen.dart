import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/loading_overlay.dart';
import 'package:falcon_system/core/widgets/section_header.dart';
import 'package:falcon_system/data/models/inspection_member.dart';
import 'package:falcon_system/features/team/presentation/cubit/team_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberFormScreen extends StatefulWidget {
  final InspectionMember? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _rankController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _loadMemberData();
    }
  }

  void _loadMemberData() {
    final member = widget.member!;
    _fullNameController.text = member.fullName;
    _specializationController.text = member.specialization;
    _rankController.text = member.rank ?? '';
    _notesController.text = member.notes ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _specializationController.dispose();
    _rankController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final member = InspectionMember(
        id: widget.member?.id ?? '',
        fullName: _fullNameController.text.trim(),
        specialization: _specializationController.text.trim(),
        rank: _rankController.text.trim().isEmpty
            ? null
            : _rankController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.member?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.member == null) {
        context.read<TeamCubit>().addMember(member);
      } else {
        context.read<TeamCubit>().updateMember(member);
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات العضو ✓'),
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
        title: Text(widget.member == null ? 'عضو جديد' : 'تعديل العضو'),
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
                    icon: Icons.person,
                    title: 'عضو  لجنة الفحص والتفتيش',
                    subtitle: 'بيانات عضو لجنة الفحص والتفتيش',
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
                      onPressed: _isLoading ? null : _saveMember,
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
                              widget.member == null
                                  ? 'إضافة العضو'
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

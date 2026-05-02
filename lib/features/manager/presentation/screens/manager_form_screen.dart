import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/loading_overlay.dart';
import 'package:falcon_system/core/widgets/section_header.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerFormScreen extends StatefulWidget {
  final AirportManager? manager;

  const ManagerFormScreen({super.key, this.manager});

  @override
  State<ManagerFormScreen> createState() => _ManagerFormScreenState();
}

class _ManagerFormScreenState extends State<ManagerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _appointmentDate;
  Uint8List? _signature;
  Uint8List? _officialStamp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.manager != null) {
      _loadManagerData();
    }
  }

  void _loadManagerData() {
    final manager = widget.manager!;
    _fullNameController.text = manager.fullName;
    _employeeNumberController.text = manager.employeeNumber;
    _appointmentDate = manager.appointmentDate;
    _signature = manager.signature;
    _officialStamp = manager.officialStamp;
    _notesController.text = manager.notes ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _employeeNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
    );
    if (picked != null) {
      setState(() {
        _appointmentDate = picked;
      });
    }
  }

  void _saveManager() {
    if (_formKey.currentState!.validate()) {
      if (_appointmentDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار تاريخ التعيين'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final manager = AirportManager(
        id: widget.manager?.id ?? '',
        fullName: _fullNameController.text.trim(),
        employeeNumber: _employeeNumberController.text.trim(),
        appointmentDate: _appointmentDate!,
        signature: _signature,
        officialStamp: _officialStamp,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.manager?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.manager == null) {
        context.read<ManagerCubit>().addManager(manager);
      } else {
        context.read<ManagerCubit>().updateManager(manager);
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.managerSaved),
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
          widget.manager == null
              ? AppStrings.newManager
              : AppStrings.editManager,
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
                    icon: Icons.person,
                    title: AppStrings.manager,
                    subtitle: 'بيانات مدير المطار',
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
                    label: AppStrings.employeeNumber,
                    hint: 'أدخل الرقم الوظيفي',
                    controller: _employeeNumberController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الرقم الوظيفي';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _appointmentDate == null
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.appointmentDate,
                                  style: AppFonts.labelLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _appointmentDate == null
                                      ? 'اختر تاريخ التعيين'
                                      : '${_appointmentDate!.day}/${_appointmentDate!.month}/${_appointmentDate!.year}',
                                  style: AppFonts.bodyLarge.copyWith(
                                    color: _appointmentDate == null
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_appointmentDate != null)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SectionHeader(
                    icon: Icons.draw,
                    title: 'التوقيع والختم',
                    subtitle: 'التوقيع الرقمي والختم الرسمي',
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('توقيع المدير', style: AppFonts.labelMedium),
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
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الختم الرسمي', style: AppFonts.labelMedium),
                      const SizedBox(height: 8),
                      SignaturePad(
                        onSignatureChanged: (stamp) {
                          setState(() {
                            _officialStamp = stamp;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    AppStrings.stampNote,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
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
                      onPressed: _isLoading ? null : _saveManager,
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
                              widget.manager == null
                                  ? 'إضافة المدير'
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

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/loading_overlay.dart';
import 'package:falcon_system/core/widgets/section_header.dart';
import 'package:falcon_system/data/models/aircraft.dart';
import 'package:falcon_system/features/aircraft/presentation/cubit/aircraft_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AircraftFormScreen extends StatefulWidget {
  final Aircraft? aircraft;

  const AircraftFormScreen({super.key, this.aircraft});

  @override
  State<AircraftFormScreen> createState() => _AircraftFormScreenState();
}

class _AircraftFormScreenState extends State<AircraftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _typeController = TextEditingController();
  final _yearController = TextEditingController();
  final _engineTypeController = TextEditingController();
  final _maxTakeoffWeightController = TextEditingController();
  final _maxLandingWeightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.aircraft != null) {
      _loadAircraftData();
    }
  }

  void _loadAircraftData() {
    final aircraft = widget.aircraft!;
    _registrationNumberController.text = aircraft.registrationNumber;
    _manufacturerController.text = aircraft.manufacturer;
    _modelController.text = aircraft.model;
    _typeController.text = aircraft.type;
    _yearController.text = aircraft.year?.toString() ?? '';
    _engineTypeController.text = aircraft.engineType ?? '';
    _maxTakeoffWeightController.text =
        aircraft.maxTakeoffWeight?.toString() ?? '';
    _maxLandingWeightController.text =
        aircraft.maxLandingWeight?.toString() ?? '';
    _notesController.text = aircraft.notes ?? '';
  }

  @override
  void dispose() {
    _registrationNumberController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _yearController.dispose();
    _engineTypeController.dispose();
    _maxTakeoffWeightController.dispose();
    _maxLandingWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAircraft() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final aircraft = Aircraft(
        id: widget.aircraft?.id ?? '',
        registrationNumber: _registrationNumberController.text.trim(),
        manufacturer: _manufacturerController.text.trim(),
        model: _modelController.text.trim(),
        type: _typeController.text.trim(),
        year: _yearController.text.trim().isEmpty
            ? null
            : int.tryParse(_yearController.text.trim()),
        engineType: _engineTypeController.text.trim().isEmpty
            ? null
            : _engineTypeController.text.trim(),
        maxTakeoffWeight: _maxTakeoffWeightController.text.trim().isEmpty
            ? null
            : int.tryParse(_maxTakeoffWeightController.text.trim()),
        maxLandingWeight: _maxLandingWeightController.text.trim().isEmpty
            ? null
            : int.tryParse(_maxLandingWeightController.text.trim()),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.aircraft?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.aircraft == null) {
        context.read<AircraftCubit>().addAircraft(aircraft);
      } else {
        context.read<AircraftCubit>().updateAircraft(aircraft);
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات الطائرة ✓'),
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
        title: Text(widget.aircraft == null ? 'طائرة جديدة' : 'تعديل الطائرة'),
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
                    icon: Icons.flight,
                    title: 'بيانات الطائرة',
                    subtitle: 'معلومات الطائرة الأساسية',
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'رقم التسجيل',
                    hint: 'أدخل رقم التسجيل',
                    controller: _registrationNumberController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم التسجيل';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'الشركة المصنعة',
                    hint: 'أدخل اسم الشركة المصنعة',
                    controller: _manufacturerController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم الشركة المصنعة';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'الموديل',
                    hint: 'أدخل موديل الطائرة',
                    controller: _modelController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال موديل الطائرة';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'نوع الطائرة',
                    hint: 'أدخل نوع الطائرة',
                    controller: _typeController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال نوع الطائرة';
                      }
                      return null;
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'سنة الصنع',
                    hint: 'أدخل سنة الصنع (اختياري)',
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'نوع المحرك',
                    hint: 'أدخل نوع المحرك (اختياري)',
                    controller: _engineTypeController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'أقصى وزن للإقلاع (كجم)',
                    hint: 'أدخل أقصى وزن للإقلاع (اختياري)',
                    controller: _maxTakeoffWeightController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'أقصى وزن للهبوط (كجم)',
                    hint: 'أدخل أقصى وزن للهبوط (اختياري)',
                    controller: _maxLandingWeightController,
                    keyboardType: TextInputType.number,
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
                      onPressed: _isLoading ? null : _saveAircraft,
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
                              widget.aircraft == null
                                  ? 'إضافة الطائرة'
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/core/utils/validators.dart';
import 'package:falcon_system/core/widgets/custom_dropdown.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/data/models/admin_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String? _nationality;
  String? _rank;
  int? _age;
  int? _flightHours;
  final List<String> _phones = [];
  String? _governorate;
  String? _workplace;
  DateTime? _employmentDate;
  bool _hasLicense = false;
  DateTime? _licenseIssueDate;
  DateTime? _licenseExpiryDate;
  Uint8List? _photo;

  bool _isLoading = false;
  String? _licenseValidityStatus;
  Color? _licenseValidityColor;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _photo = bytes);
    }
  }

  void _calculateLicenseValidity() {
    if (_licenseIssueDate != null && _licenseExpiryDate != null) {
      final result = Validators.calculateLicenseValidity(
        _licenseIssueDate!,
        _licenseExpiryDate!,
      );
      setState(() {
        _licenseValidityStatus = result['status'];
        _licenseValidityColor = result['color'];
      });
    }
  }

  Future<void> _saveAdminProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminProfile = AdminProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        nationality: _nationality ?? 'مصري',
        nationalId: _nationalIdController.text.trim(),
        rank: _rank,
        age: _age,
        flightHours: _flightHours,
        phones: _phones,
        governorate: _governorate,
        workplace: _workplace,
        employmentDate: _employmentDate,
        hasLicense: _hasLicense,
        licenseNumber: _hasLicense
            ? _licenseNumberController.text.trim()
            : null,
        licenseIssueDate: _hasLicense ? _licenseIssueDate : null,
        licenseExpiryDate: _hasLicense ? _licenseExpiryDate : null,
        photo: _photo != null
            ? 'data:image/jpeg;base64,${base64Encode(_photo!)}'
            : null,
      );

      await HiveService.adminBox.put('admin', adminProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.savedSuccessfully),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.adminSetup),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Photo
                _buildPhotoSection(),
                const SizedBox(height: 24),

                // Basic Info
                _buildSectionHeader(AppStrings.basicInfo),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.fullName,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال الاسم بالكامل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  label: AppStrings.nationality,
                  value: _nationality,
                  items: AppStrings.nationalities
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _nationality = value),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.nationalId,
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                  validator: Validators.validateNationalId,
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  label: AppStrings.rank,
                  value: _rank,
                  items: AppStrings.ranks
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _rank = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: AppStrings.age,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال العمر';
                          }
                          final age = int.tryParse(value);
                          if (age == null) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return Validators.validateAge(age.toString());
                        },
                        onChanged: (value) {
                          final age = int.tryParse(value ?? '');
                          setState(() => _age = age);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: AppStrings.flightHours,
                        keyboardType: TextInputType.number,
                        hint: AppStrings.notAvailable,
                        onChanged: (value) {
                          final hours = int.tryParse(value ?? '');
                          setState(() => _flightHours = hours);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Contact Info
                _buildSectionHeader(AppStrings.contactInfo),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.phoneNumber,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: Validators.validatePhone,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_phoneController.text.isNotEmpty &&
                          Validators.validatePhone(_phoneController.text) ==
                              null) {
                        setState(() => _phones.add(_phoneController.text));
                        _phoneController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (_phones.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _phones.map((phone) {
                      return Chip(
                        label: Text(phone),
                        onDeleted: () {
                          setState(() => _phones.remove(phone));
                        },
                        deleteIconColor: AppColors.danger,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),

                // Work Info
                _buildSectionHeader(AppStrings.workInfo),
                const SizedBox(height: 16),
                CustomDropdown(
                  label: AppStrings.governorate,
                  value: _governorate,
                  items: AppStrings.governorates
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => _governorate = value),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.workplace,
                  hint: 'مكان العمل الحالي',
                  onChanged: (value) => setState(() => _workplace = value),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _employmentDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppStrings.employmentDate,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _employmentDate != null
                          ? '${_employmentDate!.day}/${_employmentDate!.month}/${_employmentDate!.year}'
                          : '',
                      style: AppFonts.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Flying License
                _buildSectionHeader(AppStrings.flyingLicense),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(AppStrings.haveLicense),
                  value: _hasLicense,
                  onChanged: (value) =>
                      setState(() => _hasLicense = value ?? false),
                  activeThumbColor: AppColors.primary,
                ),
                if (_hasLicense) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.licenseNumber,
                    controller: _licenseNumberController,
                    validator: (value) {
                      if (_hasLicense &&
                          (value == null || value.trim().isEmpty)) {
                        return 'الرجاء إدخال رقم الرخصة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _licenseIssueDate = date;
                                _calculateLicenseValidity();
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppStrings.issueDate,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _licenseIssueDate != null
                                  ? '${_licenseIssueDate!.day}/${_licenseIssueDate!.month}/${_licenseIssueDate!.year}'
                                  : '',
                              style: AppFonts.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _licenseExpiryDate = date;
                                _calculateLicenseValidity();
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppStrings.expiryDate,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _licenseExpiryDate != null
                                  ? '${_licenseExpiryDate!.day}/${_licenseExpiryDate!.month}/${_licenseExpiryDate!.year}'
                                  : '',
                              style: AppFonts.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_licenseValidityStatus != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _licenseValidityColor!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _licenseValidityColor!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _licenseValidityColor == AppColors.success
                                ? Icons.check_circle
                                : Icons.error,
                            color: _licenseValidityColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _licenseValidityStatus!,
                              style: AppFonts.labelMedium.copyWith(
                                color: _licenseValidityColor,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAdminProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                              AppColors.textWhite,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.save,
                              style: AppFonts.labelLarge.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: _photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(58),
                      child: Image.memory(_photo!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.personalPhoto,
                          style: AppFonts.labelSmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (_photo != null)
            TextButton.icon(
              onPressed: () => setState(() => _photo = null),
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              label: Text(
                'حذف الصورة',
                style: AppFonts.labelSmall.copyWith(color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppFonts.headline6.copyWith(
          color: AppColors.primary,
          fontWeight: AppFonts.bold,
        ),
      ),
    );
  }
}

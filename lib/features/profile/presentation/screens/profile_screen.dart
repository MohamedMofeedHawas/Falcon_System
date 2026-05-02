import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/core/utils/validators.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/data/models/admin_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _rankController = TextEditingController();
  final _ageController = TextEditingController();
  final _flightHoursController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _governorateController = TextEditingController();
  final _workplaceController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  DateTime? _employmentDate;
  bool _hasLicense = false;
  String? _profileImagePath;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nationalityController.dispose();
    _nationalIdController.dispose();
    _rankController.dispose();
    _ageController.dispose();
    _flightHoursController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _governorateController.dispose();
    _workplaceController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = HiveService.getAdminProfile();
      if (profile != null) {
        setState(() {
          _fullNameController.text = profile.fullName;
          _emailController.text = profile.email;
          _nationalityController.text = profile.nationality;
          _nationalIdController.text = profile.nationalId;
          _rankController.text = profile.rank ?? '';
          _ageController.text = profile.age?.toString() ?? '';
          _flightHoursController.text = profile.flightHours?.toString() ?? '';
          _phone1Controller.text = profile.phones.isNotEmpty
              ? profile.phones[0]
              : '';
          _phone2Controller.text = profile.phones.length > 1
              ? profile.phones[1]
              : '';
          _governorateController.text = profile.governorate ?? '';
          _workplaceController.text = profile.workplace ?? '';
          _employmentDate = profile.employmentDate;
          _hasLicense = profile.hasLicense;
          _licenseNumberController.text = profile.licenseNumber ?? '';
          _profileImagePath = profile.photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _employmentDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
    );

    if (picked != null && mounted) {
      setState(() {
        _employmentDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final phones = <String>[];
      if (_phone1Controller.text.isNotEmpty) {
        phones.add(_phone1Controller.text);
      }
      if (_phone2Controller.text.isNotEmpty) {
        phones.add(_phone2Controller.text);
      }

      final profile = AdminProfile(
        id: HiveService.getAdminProfile()?.id ?? 'admin',
        fullName: _fullNameController.text,
        email: _emailController.text,
        nationality: _nationalityController.text,
        nationalId: _nationalIdController.text,
        rank: _rankController.text.isEmpty ? null : _rankController.text,
        age: _ageController.text.isEmpty
            ? null
            : int.tryParse(_ageController.text),
        flightHours: _flightHoursController.text.isEmpty
            ? null
            : int.tryParse(_flightHoursController.text),
        phones: phones,
        governorate: _governorateController.text.isEmpty
            ? null
            : _governorateController.text,
        workplace: _workplaceController.text.isEmpty
            ? null
            : _workplaceController.text,
        employmentDate: _employmentDate,
        hasLicense: _hasLicense,
        licenseNumber: _licenseNumberController.text.isEmpty
            ? null
            : _licenseNumberController.text,
        photo: _profileImagePath,
      );

      await HiveService.saveAdminProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح')));
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في حفظ البيانات: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(
            'الملف الشخصي',
            style: AppFonts.headline6.copyWith(color: AppColors.textWhite),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textWhite),
                onPressed: () => setState(() => _isEditing = true),
              )
            else
              IconButton(
                icon: const Icon(Icons.save, color: AppColors.textWhite),
                onPressed: _saveProfile,
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Center(
                        child: GestureDetector(
                          onTap: _isEditing ? _pickImage : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                backgroundImage: _profileImagePath != null
                                    ? NetworkImage(_profileImagePath!)
                                    : null,
                                child: _profileImagePath == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.textWhite,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Personal Information Section
                      _buildSectionTitle('المعلومات الشخصية'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _fullNameController,
                        label: 'الاسم الكامل',
                        prefixIcon: const Icon(Icons.person),
                        enabled: _isEditing,
                        validator: (value) =>
                            Validators.validateRequired(value, 'الاسم الكامل'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        enabled: _isEditing,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nationalityController,
                        label: 'الجنسية',
                        prefixIcon: const Icon(Icons.flag),
                        enabled: _isEditing,
                        validator: (value) =>
                            Validators.validateRequired(value, 'الجنسية'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nationalIdController,
                        label: 'الرقم القومي',
                        prefixIcon: const Icon(Icons.badge),
                        keyboardType: TextInputType.number,
                        enabled: _isEditing,
                        validator: Validators.validateNationalId,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _rankController,
                        label: 'الرتبة',
                        prefixIcon: const Icon(Icons.military_tech),
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ageController,
                        label: 'العمر',
                        prefixIcon: const Icon(Icons.cake),
                        keyboardType: TextInputType.number,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _flightHoursController,
                        label: 'ساعات الطيران',
                        prefixIcon: const Icon(Icons.flight),
                        keyboardType: TextInputType.number,
                        enabled: _isEditing,
                      ),

                      const SizedBox(height: 24),

                      // Contact Information Section
                      _buildSectionTitle('معلومات الاتصال'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phone1Controller,
                        label: 'رقم الهاتف 1',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        enabled: _isEditing,
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phone2Controller,
                        label: 'رقم الهاتف 2',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        enabled: _isEditing,
                      ),

                      const SizedBox(height: 24),

                      // Work Information Section
                      _buildSectionTitle('معلومات العمل'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _governorateController,
                        label: 'المحافظة',
                        prefixIcon: const Icon(Icons.location_city),
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _workplaceController,
                        label: 'مكان العمل',
                        prefixIcon: const Icon(Icons.work),
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _isEditing ? _selectDate : null,
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: TextEditingController(
                              text: _employmentDate != null
                                  ? '${_employmentDate!.day}/${_employmentDate!.month}/${_employmentDate!.year}'
                                  : '',
                            ),
                            label: 'تاريخ التعيين',
                            prefixIcon: const Icon(Icons.calendar_today),
                            enabled: _isEditing,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // License Information Section
                      _buildSectionTitle('معلومات الرخصة'),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'لدي رخصة طيران',
                          style: AppFonts.labelMedium,
                        ),
                        value: _hasLicense,
                        onChanged: _isEditing
                            ? (value) => setState(() => _hasLicense = value)
                            : null,
                        activeThumbColor: AppColors.primary,
                      ),
                      if (_hasLicense) ...[
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _licenseNumberController,
                          label: 'رقم الرخصة',
                          prefixIcon: const Icon(Icons.card_membership),
                          enabled: _isEditing,
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
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

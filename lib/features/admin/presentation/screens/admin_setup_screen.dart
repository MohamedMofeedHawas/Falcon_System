import 'dart:convert';
import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/core/utils/validators.dart';
import 'package:falcon_system/core/widgets/custom_dropdown.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/admin_profile.dart';
import 'package:falcon_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ── License issuing authorities ──────────────────────────────────────────────
const _licenseAuthorities = [
  'الهيئة المصرية للطيران المدني (ECAA)',
  'هيئة الطيران المدني السعودية (GACA)',
  'هيئة الطيران المدني الإماراتية (GCAA)',
  'الإدارة الفيدرالية للطيران الأمريكية (FAA)',
  'وكالة سلامة الطيران الأوروبية (EASA)',
  'منظمة الطيران المدني الدولي (ICAO)',
  'هيئة الطيران المدني الكويتية',
  'هيئة الطيران المدني القطرية (QCAA)',
  'هيئة الطيران المدني الأردنية (JCAA)',
  'الرقابة الجوية الليبية',
  'هيئة الطيران المدني التونسية',
  'هيئة الطيران المدني المغربية',
  'أخرى',
];

// ── Age calculation helpers ──────────────────────────────────────────────────
Map<String, int> _calcAge(DateTime dob) {
  final now = DateTime.now();
  int years = now.year - dob.year;
  int months = now.month - dob.month;
  int days = now.day - dob.day;
  if (days < 0) {
    months--;
    days += DateTime(now.year, now.month, 0).day;
  }
  if (months < 0) {
    months += 12;
    years--;
  }
  return {'years': years, 'months': months, 'days': days};
}

// ── License duration helper ──────────────────────────────────────────────────
Map<String, int> _calcDuration(DateTime from, DateTime to) {
  if (to.isBefore(from)) return {'years': 0, 'months': 0, 'days': 0};
  int years = to.year - from.year;
  int months = to.month - from.month;
  int days = to.day - from.day;
  if (days < 0) {
    months--;
    days += DateTime(to.year, to.month, 0).day;
  }
  if (months < 0) {
    months += 12;
    years--;
  }
  return {'years': years, 'months': months, 'days': days};
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});
  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _licenseNumberCtrl = TextEditingController();
  final _customNationalityCtrl = TextEditingController();
  final _residenceAddressCtrl = TextEditingController();
  final _manualSignatureCtrl = TextEditingController();
  final _customAuthorityCtrl = TextEditingController();

  String? _nationality;
  String? _rank;
  int? _flightHours;
  final List<String> _phones = [];
  final List<String> _whatsapps = [];
  String? _governorate;
  String? _workplace;
  DateTime? _employmentDate;
  DateTime? _dateOfBirth;
  bool _hasLicense = false;
  DateTime? _licenseIssueDate;
  DateTime? _licenseExpiryDate;
  String? _licenseAuthority;
  Uint8List? _photo;
  bool _obscurePw = true;
  bool _obscureConfirm = true;
  String _signatureMode = 'manual';
  Uint8List? _signatureImage;
  bool _isLoading = false;

  // Computed
  Map<String, int>? _ageResult;
  Map<String, int>? _licenseTotal; // total duration: issue → expiry
  Map<String, int>? _licenseRemain; // remaining: today → expiry
  bool _licenseExpired = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nationalIdCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _licenseNumberCtrl.dispose();
    _customNationalityCtrl.dispose();
    _residenceAddressCtrl.dispose();
    _manualSignatureCtrl.dispose();
    _customAuthorityCtrl.dispose();
    super.dispose();
  }

  // ── DOB → age ──────────────────────────────────────────────────────────────
  void _onDOBSelected(DateTime dob) {
    setState(() {
      _dateOfBirth = dob;
      _ageResult = _calcAge(dob);
    });
  }

  // ── License validity ───────────────────────────────────────────────────────
  void _recalcLicense() {
    if (_licenseIssueDate == null || _licenseExpiryDate == null) return;
    final now = DateTime.now();
    setState(() {
      _licenseTotal = _calcDuration(_licenseIssueDate!, _licenseExpiryDate!);
      _licenseExpired = _licenseExpiryDate!.isBefore(now);
      _licenseRemain = _licenseExpired
          ? null
          : _calcDuration(now, _licenseExpiryDate!);
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _snack('كلمات المرور غير متطابقة', AppColors.danger);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final authority = _licenseAuthority == 'أخرى'
          ? _customAuthorityCtrl.text.trim()
          : _licenseAuthority;

      final profile = AdminProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().toLowerCase(),
        password: _passwordCtrl.text,
        nationality: _nationality ?? 'مصري',
        customNationality: _nationality == 'أخرى'
            ? _customNationalityCtrl.text.trim()
            : null,
        nationalId: _nationalIdCtrl.text.trim(),
        rank: _rank,
        flightHours: _flightHours,
        phones: List<String>.from(_phones),
        whatsappNumbers: List<String>.from(_whatsapps),
        residenceAddress: _governorate != null
            ? _residenceAddressCtrl.text.trim()
            : null,
        governorate: _governorate,
        workplace: _workplace?.trim().isEmpty == true
            ? null
            : _workplace?.trim(),
        employmentDate: _employmentDate,
        dateOfBirth: _dateOfBirth,
        hasLicense: _hasLicense,
        licenseNumber: _hasLicense ? _licenseNumberCtrl.text.trim() : null,
        licenseIssuingAuthority: _hasLicense ? authority : null,
        licenseIssueDate: _hasLicense ? _licenseIssueDate : null,
        licenseExpiryDate: _hasLicense ? _licenseExpiryDate : null,
        photo: _photo != null
            ? 'data:image/jpeg;base64,${base64Encode(_photo!)}'
            : null,
        adminSignatureMode: _signatureMode,
        adminSignatureText:
            _signatureMode == 'manual' &&
                _manualSignatureCtrl.text.trim().isNotEmpty
            ? _manualSignatureCtrl.text.trim()
            : null,
        adminSignatureImage: _signatureMode == 'board' ? _signatureImage : null,
        adminSignatureSavedAt:
            (_manualSignatureCtrl.text.trim().isNotEmpty ||
                _signatureImage != null)
            ? DateTime.now()
            : null,
      );
      await HiveService.saveAdminProfile(profile);
      HiveService.setCurrentAdminEmail(profile.email);
      if (!mounted) return;
      _snack(
        AppStrings.savedSuccessfully,
        AppColors.success,
        icon: Icons.check_circle,
      );
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const DashboardScreen(),
          transitionsBuilder: (_, a, _, c) =>
              FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      _snack('خطأ: $e', AppColors.danger, icon: Icons.error_outline);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, Color color, {IconData? icon}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                msg,
                style: AppFonts.labelLarge.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: AppFonts.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 6),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFonts.headline6.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.bold,
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Divider(color: AppColors.border, thickness: 1),
  );

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: AppColors.background,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      child: Text(
        date != null ? '${date.day}/${date.month}/${date.year}' : '         ',
        style: AppFonts.bodyMedium,
      ),
    ),
  );

  // ── Animated phone chip ────────────────────────────────────────────────────
  Widget _animatedChip({
    required String label,
    required VoidCallback onDelete,
    Widget? avatar,
  }) => TweenAnimationBuilder<double>(
    key: ValueKey(label),
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOut,
    builder: (_, v, child) => Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, (1 - v) * -14),
        child: child,
      ),
    ),
    child: Chip(
      avatar: avatar,
      label: Text(label),
      onDeleted: onDelete,
      deleteIconColor: AppColors.danger,
    ),
  );

  // ── Duration display row ───────────────────────────────────────────────────
  Widget _durationRow(Map<String, int> d, {String? subtitle, Color? color}) {
    final items = <Widget>[];
    if (d['years']! > 0) items.add(_durationItem(d['years']!, 'سنة', color));
    if (d['months']! > 0) items.add(_durationItem(d['months']!, 'شهر', color));
    if (d['days']! > 0) items.add(_durationItem(d['days']!, 'يوم', color));
    if (items.isEmpty) items.add(_durationItem(0, '—', color));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null) ...[
          Text(
            subtitle,
            style: AppFonts.labelSmall.copyWith(
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items),
      ],
    );
  }

  Widget _durationItem(int value, String label, Color? color) => Column(
    children: [
      Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              color ?? AppColors.primary,
              (color ?? AppColors.primary).withOpacity(0.65),
            ],
          ),
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: AppFonts.headline6.copyWith(
              color: Colors.white,
              fontWeight: AppFonts.bold,
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: AppFonts.labelSmall.copyWith(color: AppColors.textPrimary),
      ),
    ],
  );

  // ────────────────────────────────────────────────────────────────────────────

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
                // ── Photo ────────────────────────────────────────────────
                _buildPhotoSection(),
                _divider(),

                // ── Basic Info ───────────────────────────────────────────
                _sectionHeader(AppStrings.basicInfo),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.fullName,
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'يرجى إدخال الاسم الكامل'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: AppStrings.nationality,
                  value: _nationality,
                  items: AppStrings.nationalities
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _nationality = v),
                ),
                if (_nationality == 'أخرى') ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: AppStrings.customNationality,
                    controller: _customNationalityCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'يرجى إدخال الجنسية'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                // ✅ No counter shown (maxLength removed — validated in validator)
                CustomTextField(
                  counterText: "",
                  maxLength: 14,
                  label: AppStrings.nationalId,
                  controller: _nationalIdCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  validator: Validators.validateNationalId,
                ),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: AppStrings.rank,
                  value: _rank,
                  items: AppStrings.ranks
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _rank = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // ✅ Date of birth replaces plain age field
                    Expanded(
                      child: _dateTile(
                        label: 'تاريخ الميلاد',
                        date: _dateOfBirth,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime(1990),
                            firstDate: DateTime(1940),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) _onDOBSelected(d);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'ساعات الطيران',
                        hint: AppStrings.notAvailable,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.flight_outlined),
                        onChanged: (v) =>
                            setState(() => _flightHours = int.tryParse(v)),
                      ),
                    ),
                  ],
                ),
                // ✅ Age result card
                if (_ageResult != null) ...[
                  const SizedBox(height: 10),
                  _ageCard(_ageResult!),
                ],
                _divider(),

                // ── Registration ─────────────────────────────────────────
                _sectionHeader(AppStrings.registrationData),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.alternate_email),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordCtrl,
                  obscureText: _obscurePw,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePw ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => setState(() => _obscurePw = !_obscurePw),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
                    if (v.length < 6) return 'كلمة المرور 6 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'يرجى تأكيد كلمة المرور'
                      : null,
                ),
                _divider(),

                // ── Contact ──────────────────────────────────────────────
                _sectionHeader(AppStrings.contactInfo),
                const SizedBox(height: 14),
                // ✅ No maxLength counter — validator handles 11 digits
                CustomTextField(
                  maxLength: 11,
                  counterText: "",

              
                  label: AppStrings.phoneNumber,
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      final t = _phoneCtrl.text.trim();
                      if (t.isNotEmpty &&
                          Validators.validatePhone(t) == null &&
                          !_phones.contains(t)) {
                        setState(() => _phones.add(t));
                        _phoneCtrl.clear();
                      }
                    },
                  ),
                ),
                // ✅ Smooth slide-down animation for chips
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _phones.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _phones
                                .map(
                                  (p) => _animatedChip(
                                    label: p,
                                    onDelete: () =>
                                        setState(() => _phones.remove(p)),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  maxLength: 11,
                  counterText: "",
                  label: AppStrings.whatsappNumbers,
                  controller: _whatsappCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.message_outlined,
                    color: Colors.green,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      final t = _whatsappCtrl.text.trim();
                      if (t.isNotEmpty &&
                          Validators.validatePhone(t) == null &&
                          !_whatsapps.contains(t)) {
                        setState(() => _whatsapps.add(t));
                        _whatsappCtrl.clear();
                      }
                    },
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _whatsapps.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _whatsapps
                                .map(
                                  (w) => _animatedChip(
                                    label: w,
                                    onDelete: () =>
                                        setState(() => _whatsapps.remove(w)),
                                    avatar: const Icon(
                                      Icons.message,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
                _divider(),

                // ── Work Info ────────────────────────────────────────────
                _sectionHeader(AppStrings.workInfo),
                const SizedBox(height: 14),
                CustomDropdown(
                  label: AppStrings.governorate,
                  value: _governorate,
                  items: AppStrings.governorates
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _governorate = v),
                ),
                if (_governorate != null) ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: AppStrings.residenceAddress,
                    controller: _residenceAddressCtrl,
                    hint: 'الشارع – الحي – المدينة',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 12),
                CustomTextField(
                  label: AppStrings.workplace,
                  hint: 'اتركه فارغًا إن لم تكن تعمل حاليًا',
                  prefixIcon: const Icon(Icons.work_outline),
                  onChanged: (v) => setState(() => _workplace = v),
                ),
                const SizedBox(height: 12),
                _dateTile(
                  label: AppStrings.employmentDate,
                  date: _employmentDate,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _employmentDate = d);
                  },
                ),
                _divider(),

                // ── Flying License ───────────────────────────────────────
                _sectionHeader(AppStrings.flyingLicense),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(AppStrings.haveLicense),
                  value: _hasLicense,
                  onChanged: (v) => setState(() => _hasLicense = v),
                  activeColor: AppColors.primary,
                  tileColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                if (_hasLicense) ...[
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: AppStrings.licenseNumber,
                    controller: _licenseNumberCtrl,
                    prefixIcon: const Icon(Icons.card_membership_outlined),
                    validator: (v) =>
                        (_hasLicense && (v == null || v.trim().isEmpty))
                        ? 'يرجى إدخال رقم الرخصة'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // ✅ Issuing authority
                  CustomDropdown(
                    label: 'جهة الإصدار',
                    value: _licenseAuthority,
                    items: _licenseAuthorities
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _licenseAuthority = v),
                  ),
                  if (_licenseAuthority == 'أخرى') ...[
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'اسم جهة الإصدار',
                      controller: _customAuthorityCtrl,
                      prefixIcon: const Icon(Icons.business_outlined),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _dateTile(
                          label: AppStrings.issueDate,
                          date: _licenseIssueDate,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) {
                              setState(() => _licenseIssueDate = d);
                              _recalcLicense();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateTile(
                          label: AppStrings.expiryDate,
                          date: _licenseExpiryDate,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime(2100),
                            );
                            if (d != null) {
                              setState(() => _licenseExpiryDate = d);
                              _recalcLicense();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  // ✅ License validity cards
                  if (_licenseTotal != null) ...[
                    const SizedBox(height: 14),
                    _licenseValidityCard(),
                  ],
                ],
                _divider(),

                // ── Signature ────────────────────────────────────────────
                _sectionHeader('توقيع الأدمن'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'manual',
                            icon: Icon(Icons.text_fields, size: 16),
                            label: Text('توقيع كتابي'),
                          ),
                          ButtonSegment(
                            value: 'board',
                            icon: Icon(Icons.draw_outlined, size: 16),
                            label: Text('لوحة التوقيع'),
                          ),
                        ],
                        selected: {_signatureMode},
                        onSelectionChanged: (s) =>
                            setState(() => _signatureMode = s.first),
                      ),
                      const SizedBox(height: 14),
                      if (_signatureMode == 'manual')
                        CustomTextField(
                          controller: _manualSignatureCtrl,
                          label: 'اسمك كما سيظهر في التوقيع',
                          hint: 'مثال: اللواء أحمد محمد',
                          prefixIcon: const Icon(Icons.edit_outlined),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ارسم توقيعك:',
                              style: AppFonts.labelMedium.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SignaturePad(
                                onSignatureChanged: (b) =>
                                    setState(() => _signatureImage = b),
                                height: 150,
                              ),
                            ),
                            if (_signatureImage != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'تم رسم التوقيع',
                                    style: AppFonts.labelSmall.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
                _divider(),

                // ── Save Button ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
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
                              const Icon(Icons.save_outlined),
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
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Age card ─────────────────────────────────────────────────────────────
  Widget _ageCard(Map<String, int> age) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.08),
          AppColors.primary.withOpacity(0.03),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العمر الحالي',
          style: AppFonts.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 12),
        _durationRow(age),
      ],
    ),
  );

  // ── License validity card ─────────────────────────────────────────────────
  Widget _licenseValidityCard() {
    final expiredColor = AppColors.danger;
    final validColor = AppColors.success;
    final totalColor = AppColors.primary;

    return Column(
      children: [
        // Total duration
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                totalColor.withOpacity(0.08),
                totalColor.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: totalColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المدة الإجمالية للرخصة',
                style: AppFonts.labelLarge.copyWith(
                  color: totalColor,
                  fontWeight: AppFonts.bold,
                ),
              ),
              const SizedBox(height: 12),
              _durationRow(_licenseTotal!, color: totalColor),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Remaining / Expired
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _licenseExpired
                  ? [
                      expiredColor.withOpacity(0.08),
                      expiredColor.withOpacity(0.03),
                    ]
                  : [
                      validColor.withOpacity(0.08),
                      validColor.withOpacity(0.03),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (_licenseExpired ? expiredColor : validColor).withOpacity(
                0.3,
              ),
            ),
          ),
          child: _licenseExpired
              ? Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: expiredColor),
                    const SizedBox(width: 8),
                    Text(
                      'الرخصة منتهية الصلاحية',
                      style: AppFonts.labelLarge.copyWith(
                        color: expiredColor,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: validColor,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'المتبقي حتى الانتهاء',
                          style: AppFonts.labelLarge.copyWith(
                            color: validColor,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _durationRow(_licenseRemain!, color: validColor),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Photo section ─────────────────────────────────────────────────────────
  Widget _buildPhotoSection() => Center(
    child: Column(
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final f = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 80,
            );
            if (f != null) {
              final b = await f.readAsBytes();
              setState(() => _photo = b);
            }
          },
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: _photo != null
                ? ClipOval(child: Image.memory(_photo!, fit: BoxFit.cover))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 34,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.personalPhoto,
                        style: AppFonts.labelSmall.copyWith(
                          color: AppColors.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
        if (_photo != null) ...[
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => setState(() => _photo = null),
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.danger,
              size: 18,
            ),
            label: Text(
              'حذف الصورة',
              style: AppFonts.labelSmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    ),
  );
}

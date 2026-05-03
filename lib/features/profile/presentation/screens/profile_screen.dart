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
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ── Same authority list as setup screen ─────────────────────────────────────
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

// ── Duration helpers ─────────────────────────────────────────────────────────
Map<String, int> _calcAge(DateTime dob) {
  final now = DateTime.now();
  int years = now.year - dob.year,
      months = now.month - dob.month,
      days = now.day - dob.day;
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

Map<String, int> _calcDuration(DateTime from, DateTime to) {
  if (to.isBefore(from)) return {'years': 0, 'months': 0, 'days': 0};
  int years = to.year - from.year,
      months = to.month - from.month,
      days = to.day - from.day;
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
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _flightHoursCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _residenceCtrl = TextEditingController();
  final _workplaceCtrl = TextEditingController();
  final _licenseNumCtrl = TextEditingController();
  final _customNationalityCtrl = TextEditingController();
  final _manualSigCtrl = TextEditingController();
  final _customAuthorityCtrl = TextEditingController();

  AdminProfile? _profile;
  String? _nationality;
  String? _rank;
  String? _governorate;
  DateTime? _employmentDate;
  DateTime? _dateOfBirth;
  bool _hasLicense = false;
  Uint8List? _photo;
  Uint8List? _signatureImage;
  String _signatureMode = 'manual';
  String? _licenseAuthority;
  final List<String> _phones = [];
  final List<String> _whatsapps = [];

  bool _isEditing = false;
  bool _isLoading = false;
  bool _obscurePw = true;
  bool _obscureConfirm = true;

  // Computed license data
  Map<String, int>? _licenseTotal;
  Map<String, int>? _licenseRemain;
  bool _licenseExpired = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl,
      _nationalIdCtrl,
      _flightHoursCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmPwCtrl,
      _phoneCtrl,
      _whatsappCtrl,
      _residenceCtrl,
      _workplaceCtrl,
      _licenseNumCtrl,
      _customNationalityCtrl,
      _manualSigCtrl,
      _customAuthorityCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final p = HiveService.getAdminProfile();
    if (p != null) {
      _profile = p;
      _fullNameCtrl.text = p.fullName;
      _nationality = p.nationality;
      _nationalIdCtrl.text = p.nationalId;
      _rank = p.rank;
      _flightHoursCtrl.text = p.flightHours?.toString() ?? '';
      _emailCtrl.text = p.email;
      _passwordCtrl.text = p.password ?? '';
      _confirmPwCtrl.text = p.password ?? '';
      _phones
        ..clear()
        ..addAll(p.phones);
      _whatsapps
        ..clear()
        ..addAll(p.whatsappNumbers);
      _governorate = p.governorate;
      _residenceCtrl.text = p.residenceAddress ?? '';
      _workplaceCtrl.text = p.workplace ?? '';
      _employmentDate = p.employmentDate;
      _dateOfBirth = p.dateOfBirth;
      _hasLicense = p.hasLicense;
      _licenseNumCtrl.text = p.licenseNumber ?? '';
      _licenseAuthority = p.licenseIssuingAuthority;
      _customNationalityCtrl.text = p.customNationality ?? '';
      _manualSigCtrl.text = p.adminSignatureText ?? '';
      _signatureImage = p.adminSignatureImage;
      _signatureMode = p.adminSignatureMode ?? 'manual';

      if (p.photo != null && p.photo!.startsWith('data:')) {
        try {
          _photo = base64Decode(p.photo!.split(',')[1]);
        } catch (_) {
          _photo = null;
        }
      }
      _recalcLicense();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _recalcLicense() {
    if (_profile?.licenseIssueDate == null ||
        _profile?.licenseExpiryDate == null)
      return;
    final now = DateTime.now();
    _licenseTotal = _calcDuration(
      _profile!.licenseIssueDate!,
      _profile!.licenseExpiryDate!,
    );
    _licenseExpired = _profile!.licenseExpiryDate!.isBefore(now);
    _licenseRemain = _licenseExpired
        ? null
        : _calcDuration(now, _profile!.licenseExpiryDate!);
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _profile == null) return;
    if (_passwordCtrl.text != _confirmPwCtrl.text) {
      _snack('كلمة المرور وتأكيدها غير متطابقتين', AppColors.danger);
      return;
    }
    setState(() => _isLoading = true);

    final authority = _licenseAuthority == 'أخرى'
        ? _customAuthorityCtrl.text.trim()
        : _licenseAuthority;

    final updated = AdminProfile(
      id: _profile!.id,
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().toLowerCase(),
      password: _passwordCtrl.text,
      nationality: _nationality ?? 'مصري',
      customNationality: _nationality == 'أخرى'
          ? _customNationalityCtrl.text.trim()
          : null,
      nationalId: _nationalIdCtrl.text.trim(),
      rank: _rank,
      flightHours: int.tryParse(_flightHoursCtrl.text),
      phones: List<String>.from(_phones),
      whatsappNumbers: List<String>.from(_whatsapps),
      governorate: _governorate,
      residenceAddress: _governorate != null
          ? _residenceCtrl.text.trim()
          : null,
      workplace: _workplaceCtrl.text.trim().isEmpty
          ? null
          : _workplaceCtrl.text.trim(),
      employmentDate: _employmentDate,
      dateOfBirth: _dateOfBirth,
      hasLicense: _hasLicense,
      licenseNumber: _hasLicense ? _licenseNumCtrl.text.trim() : null,
      licenseIssuingAuthority: _hasLicense ? authority : null,
      licenseIssueDate: _profile!.licenseIssueDate,
      licenseExpiryDate: _profile!.licenseExpiryDate,
      photo: _photo != null
          ? 'data:image/jpeg;base64,${base64Encode(_photo!)}'
          : _profile!.photo,
      adminSignatureMode: _signatureMode,
      adminSignatureText:
          _signatureMode == 'manual' && _manualSigCtrl.text.trim().isNotEmpty
          ? _manualSigCtrl.text.trim()
          : null,
      adminSignatureImage: _signatureMode == 'board' ? _signatureImage : null,
      adminSignatureSavedAt: _profile!.adminSignatureSavedAt,
      createdAt: _profile!.createdAt,
      updatedAt: DateTime.now(),
    );

    await HiveService.saveAdminProfile(updated);
    HiveService.setCurrentAdminEmail(updated.email);
    if (!mounted) return;
    setState(() {
      _profile = updated;
      _isEditing = false;
      _isLoading = false;
    });
    _recalcLicense();
    _snack(
      'تم حفظ الملف الشخصي بنجاح',
      AppColors.success,
      icon: Icons.check_circle,
    );
  }

  void _cancelEdit() =>
      _loadProfile().then((_) => setState(() => _isEditing = false));

  void _snack(String msg, Color color, {IconData? icon}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                msg,
                style: AppFonts.labelLarge.copyWith(color: AppColors.textWhite),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Signature helpers ─────────────────────────────────────────────────────
  Future<void> _saveSignatureOnly() async {
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      adminSignatureMode: _signatureMode,
      adminSignatureText: _signatureMode == 'manual'
          ? _manualSigCtrl.text.trim()
          : null,
      adminSignatureImage: _signatureMode == 'board' ? _signatureImage : null,
      adminSignatureSavedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await HiveService.saveAdminProfile(updated);
    setState(() => _profile = updated);
    _snack('تم حفظ التوقيع', AppColors.success, icon: Icons.verified);
  }

  Future<void> _deleteSignatureOnly() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('حذف التوقيع'),
        content: const Text('هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final updated = _profile!.copyWith(
      adminSignatureMode: null,
      adminSignatureText: null,
      adminSignatureImage: null,
      adminSignatureSavedAt: null,
      updatedAt: DateTime.now(),
    );
    await HiveService.saveAdminProfile(updated);
    setState(() {
      _profile = updated;
      _manualSigCtrl.clear();
      _signatureImage = null;
      _signatureMode = 'manual';
    });
  }

  // ── UI helpers ────────────────────────────────────────────────────────────
  Widget _section(String title, {IconData? icon}) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 4),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
        ],
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

  // ── Read-only tile ─────────────────────────────────────────────────────────
  Widget _roTile(String label, String? value, {IconData? icon}) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppFonts.labelSmall.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: 2),
              Text(
                value?.isNotEmpty == true ? value! : '—',
                style: AppFonts.bodyMedium.copyWith(
                  color: value?.isNotEmpty == true
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _roDateTile(String label, DateTime? d) => _roTile(
    label,
    d != null ? '${d.day}/${d.month}/${d.year}' : null,
    icon: Icons.calendar_today_outlined,
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

  // ── Animated chip ─────────────────────────────────────────────────────────
  Widget _animChip(String label, VoidCallback onDelete, {Widget? avatar}) =>
      TweenAnimationBuilder<double>(
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

  // ── Duration row ──────────────────────────────────────────────────────────
  Widget _durRow(Map<String, int> d, {Color? color}) {
    final c = color ?? AppColors.primary;
    final items = <Widget>[];
    if (d['years']! > 0) items.add(_durItem(d['years']!, 'سنة', c));
    if (d['months']! > 0) items.add(_durItem(d['months']!, 'شهر', c));
    if (d['days']! > 0) items.add(_durItem(d['days']!, 'يوم', c));
    if (items.isEmpty) items.add(_durItem(0, '—', c));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items,
    );
  }

  Widget _durItem(int v, String label, Color color) => Column(
    children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [color, color.withOpacity(0.65)]),
        ),
        child: Center(
          child: Text(
            v.toString(),
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

  // ── DOB age card ──────────────────────────────────────────────────────────
  Widget _ageCard(DateTime dob) {
    final age = _calcAge(dob);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.primary.withOpacity(0.03),
          ],
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
          _durRow(age),
        ],
      ),
    );
  }

  // ── License validity card ─────────────────────────────────────────────────
  Widget _licenseCard() {
    if (_licenseTotal == null) return const SizedBox.shrink();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المدة الإجمالية',
                style: AppFonts.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: AppFonts.bold,
                ),
              ),
              const SizedBox(height: 12),
              _durRow(_licenseTotal!, color: AppColors.primary),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _licenseExpired
                  ? [
                      AppColors.danger.withOpacity(0.08),
                      AppColors.danger.withOpacity(0.03),
                    ]
                  : [
                      AppColors.success.withOpacity(0.08),
                      AppColors.success.withOpacity(0.03),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (_licenseExpired ? AppColors.danger : AppColors.success)
                  .withOpacity(0.3),
            ),
          ),
          child: _licenseExpired
              ? Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Text(
                      'الرخصة منتهية الصلاحية',
                      style: AppFonts.labelLarge.copyWith(
                        color: AppColors.danger,
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
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'المتبقي حتى الانتهاء',
                          style: AppFonts.labelLarge.copyWith(
                            color: AppColors.success,
                            fontWeight: AppFonts.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _durRow(_licenseRemain!, color: AppColors.success),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Signature preview ─────────────────────────────────────────────────────
  Widget _sigPreview() {
    final hasText = _profile?.adminSignatureText?.isNotEmpty == true;
    final hasImage = _profile?.adminSignatureImage != null;
    if (!hasText && !hasImage) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            'لا يوجد توقيع محفوظ',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textHint),
          ),
        ),
      );
    }
    final savedAt = _profile?.adminSignatureSavedAt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _profile?.adminSignatureMode == 'board'
                    ? Icons.draw_outlined
                    : Icons.text_fields,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _profile?.adminSignatureMode == 'board'
                    ? 'توقيع لوحي'
                    : 'توقيع كتابي',
                style: AppFonts.labelSmall.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              if (savedAt != null)
                Text(
                  '${savedAt.day}/${savedAt.month}/${savedAt.year}',
                  style: AppFonts.labelSmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_profile?.adminSignatureMode == 'board' && hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _profile!.adminSignatureImage!,
                height: 100,
                fit: BoxFit.contain,
              ),
            )
          else if (hasText)
            Text(
              _profile!.adminSignatureText!,
              style: AppFonts.headline6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          const Divider(height: 16),
          Center(
            child: Text(
              _profile!.fullName,
              style: AppFonts.labelSmall.copyWith(color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sigEdit() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
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
          onSelectionChanged: (s) => setState(() => _signatureMode = s.first),
        ),
        const SizedBox(height: 14),
        if (_signatureMode == 'manual')
          CustomTextField(
            controller: _manualSigCtrl,
            label: 'اسمك كما سيظهر في التوقيع',
            hint: 'مثال: اللواء أحمد محمد',
            prefixIcon: const Icon(Icons.edit_outlined),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SignaturePad(
              onSignatureChanged: (b) => setState(() => _signatureImage = b),
              height: 150,
              initialSignature: _signatureImage != null
                  ? 'data:image/png;base64,${base64Encode(_signatureImage!)}'
                  : null,
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveSignatureOnly,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('حفظ التوقيع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _deleteSignatureOnly,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.danger,
                ),
                label: const Text(
                  'حذف',
                  style: TextStyle(color: AppColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          title: Text(_isEditing ? 'تعديل الملف الشخصي' : 'الملف الشخصي'),
          centerTitle: true,
          actions: [
            if (!_isEditing)
              IconButton(
                tooltip: 'تعديل',
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_outlined),
              )
            else ...[
              IconButton(
                tooltip: 'إلغاء',
                onPressed: _cancelEdit,
                icon: const Icon(Icons.close),
              ),
              IconButton(
                tooltip: 'حفظ',
                onPressed: _isLoading ? null : _saveProfile,
                icon: const Icon(Icons.save_outlined),
              ),
            ],
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Photo ──────────────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: _isEditing
                              ? () async {
                                  final f = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (f != null) {
                                    final b = await f.readAsBytes();
                                    setState(() => _photo = b);
                                  }
                                }
                              : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 58,
                                backgroundColor: AppColors.background,
                                backgroundImage: _photo != null
                                    ? MemoryImage(_photo!)
                                    : null,
                                child: _photo == null
                                    ? Icon(
                                        Icons.person_outline,
                                        size: 54,
                                        color: AppColors.textHint,
                                      )
                                    : null,
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!_isEditing && _profile != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _profile!.fullName,
                            style: AppFonts.headline5.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppFonts.bold,
                            ),
                          ),
                        ),
                      ],
                      _divider(),

                      // ── Basic Info ─────────────────────────────────────────
                      _section(
                        AppStrings.basicInfo,
                        icon: Icons.person_outline,
                      ),
                      if (!_isEditing) ...[
                        _roTile(
                          AppStrings.fullName,
                          _profile?.fullName,
                          icon: Icons.person_outline,
                        ),
                        _roTile(
                          AppStrings.nationality,
                          _profile?.nationality,
                          icon: Icons.flag_outlined,
                        ),
                        if (_profile?.customNationality != null)
                          _roTile(
                            AppStrings.customNationality,
                            _profile?.customNationality,
                          ),
                        _roTile(
                          AppStrings.nationalId,
                          _profile?.nationalId,
                          icon: Icons.badge_outlined,
                        ),
                        _roTile(
                          AppStrings.rank,
                          _profile?.rank,
                          icon: Icons.military_tech_outlined,
                        ),
                        _roDateTile('تاريخ الميلاد', _profile?.dateOfBirth),
                        if (_profile?.dateOfBirth != null)
                          _ageCard(_profile!.dateOfBirth!),
                        _roTile(
                          AppStrings.flightHours,
                          _profile?.flightHours?.toString(),
                          icon: Icons.flight_outlined,
                        ),
                      ] else ...[
                        CustomTextField(
                          controller: _fullNameCtrl,
                          label: AppStrings.fullName,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) => Validators.validateRequired(
                            v,
                            AppStrings.fullName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          label: AppStrings.nationality,
                          value: _nationality,
                          items: AppStrings.nationalities
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _nationality = v),
                        ),
                        if (_nationality == 'أخرى') ...[
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _customNationalityCtrl,
                            label: AppStrings.customNationality,
                          ),
                        ],
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _nationalIdCtrl,
                          label: AppStrings.nationalId,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.badge_outlined),
                          validator: Validators.validateNationalId,
                        ),
                        const SizedBox(height: 12),
                        CustomDropdown<String>(
                          label: AppStrings.rank,
                          value: _rank,
                          items: AppStrings.ranks
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _rank = v),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _dateTile(
                                label: 'تاريخ الميلاد',
                                date: _dateOfBirth,
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _dateOfBirth ?? DateTime(1990),
                                    firstDate: DateTime(1940),
                                    lastDate: DateTime.now(),
                                  );
                                  if (d != null)
                                    setState(() => _dateOfBirth = d);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                controller: _flightHoursCtrl,
                                label: AppStrings.flightHours,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.flight_outlined),
                              ),
                            ),
                          ],
                        ),
                        if (_dateOfBirth != null) ...[
                          const SizedBox(height: 10),
                          _ageCard(_dateOfBirth!),
                        ],
                      ],
                      _divider(),

                      // ── Registration ───────────────────────────────────────
                      _section(
                        AppStrings.registrationData,
                        icon: Icons.lock_outline,
                      ),
                      if (!_isEditing) ...[
                        _roTile(
                          AppStrings.email,
                          _profile?.email,
                          icon: Icons.alternate_email,
                        ),
                        _roTile(
                          AppStrings.password,
                          '••••••••',
                          icon: Icons.lock_outline,
                        ),
                      ] else ...[
                        CustomTextField(
                          controller: _emailCtrl,
                          label: AppStrings.email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.alternate_email),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: AppStrings.password,
                          obscureText: _obscurePw,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePw
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePw = !_obscurePw),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _confirmPwCtrl,
                          label: AppStrings.confirmPassword,
                          obscureText: _obscureConfirm,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                      ],
                      _divider(),

                      // ── Contact ────────────────────────────────────────────
                      _section(
                        AppStrings.contactInfo,
                        icon: Icons.phone_outlined,
                      ),
                      if (!_isEditing) ...[
                        // ✅ Show each phone on its own line, not joined
                        if (_phones.isEmpty)
                          _roTile(
                            AppStrings.phoneNumber,
                            null,
                            icon: Icons.phone_outlined,
                          )
                        else
                          ..._phones.map(
                            (p) => _roTile(
                              AppStrings.phoneNumber,
                              p,
                              icon: Icons.phone_outlined,
                            ),
                          ),
                        if (_whatsapps.isNotEmpty)
                          ..._whatsapps.map(
                            (w) => _roTile(
                              AppStrings.whatsappNumbers,
                              w,
                              icon: Icons.message_outlined,
                            ),
                          ),
                      ] else ...[
                        CustomTextField(
                          controller: _phoneCtrl,
                          label: AppStrings.phoneNumber,
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
                                          (p) => _animChip(
                                            p,
                                            () => setState(
                                              () => _phones.remove(p),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _whatsappCtrl,
                          label: AppStrings.whatsappNumbers,
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
                                          (w) => _animChip(
                                            w,
                                            () => setState(
                                              () => _whatsapps.remove(w),
                                            ),
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
                      ],
                      _divider(),

                      // ── Work Info ──────────────────────────────────────────
                      _section(AppStrings.workInfo, icon: Icons.work_outline),
                      if (!_isEditing) ...[
                        _roTile(
                          AppStrings.governorate,
                          _profile?.governorate,
                          icon: Icons.map_outlined,
                        ),
                        if (_profile?.governorate != null)
                          _roTile(
                            AppStrings.residenceAddress,
                            _profile?.residenceAddress,
                            icon: Icons.location_on_outlined,
                          ),
                        _roTile(
                          AppStrings.workplace,
                          _profile?.workplace,
                          icon: Icons.business_outlined,
                        ),
                        _roDateTile(
                          AppStrings.employmentDate,
                          _profile?.employmentDate,
                        ),
                      ] else ...[
                        CustomDropdown<String>(
                          label: AppStrings.governorate,
                          value: _governorate,
                          items: AppStrings.governorates
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _governorate = v;
                              if (v == null) _residenceCtrl.clear();
                            });
                          },
                        ),
                        if (_governorate != null) ...[
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _residenceCtrl,
                            label: AppStrings.residenceAddress,
                            hint: 'الشارع – الحي – المدينة',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            maxLines: 2,
                          ),
                        ],
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _workplaceCtrl,
                          label: AppStrings.workplace,
                          prefixIcon: const Icon(Icons.business_outlined),
                        ),
                        const SizedBox(height: 12),
                        _dateTile(
                          label: AppStrings.employmentDate,
                          date: _employmentDate,
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _employmentDate ?? DateTime.now(),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );
                            if (d != null) setState(() => _employmentDate = d);
                          },
                        ),
                      ],
                      _divider(),

                      // ── License ────────────────────────────────────────────
                      _section(
                        AppStrings.flyingLicense,
                        icon: Icons.card_membership_outlined,
                      ),
                      if (!_isEditing) ...[
                        _roTile(
                          AppStrings.haveLicense,
                          _hasLicense ? 'نعم' : 'لا',
                          icon: Icons.check_circle_outline,
                        ),
                        if (_hasLicense) ...[
                          _roTile(
                            AppStrings.licenseNumber,
                            _profile?.licenseNumber,
                            icon: Icons.numbers_outlined,
                          ),
                          _roTile(
                            'جهة الإصدار',
                            _profile?.licenseIssuingAuthority,
                            icon: Icons.business_outlined,
                          ),
                          _roDateTile(
                            AppStrings.issueDate,
                            _profile?.licenseIssueDate,
                          ),
                          _roDateTile(
                            AppStrings.expiryDate,
                            _profile?.licenseExpiryDate,
                          ),
                          const SizedBox(height: 4),
                          _licenseCard(),
                        ],
                      ] else ...[
                        SwitchListTile(
                          value: _hasLicense,
                          onChanged: (v) => setState(() => _hasLicense = v),
                          title: Text(AppStrings.haveLicense),
                          activeColor: AppColors.primary,
                          tileColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        if (_hasLicense) ...[
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _licenseNumCtrl,
                            label: AppStrings.licenseNumber,
                            prefixIcon: const Icon(Icons.numbers_outlined),
                          ),
                          const SizedBox(height: 12),
                          CustomDropdown(
                            label: 'جهة الإصدار',
                            value: _licenseAuthority,
                            items: _licenseAuthorities
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      e,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _licenseAuthority = v),
                          ),
                          if (_licenseAuthority == 'أخرى') ...[
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _customAuthorityCtrl,
                              label: 'اسم جهة الإصدار',
                              prefixIcon: const Icon(Icons.business_outlined),
                            ),
                          ],
                        ],
                      ],
                      _divider(),

                      // ── Signature ──────────────────────────────────────────
                      _section('توقيع الأدمن', icon: Icons.draw_outlined),
                      if (!_isEditing) _sigPreview() else _sigEdit(),

                      const SizedBox(height: 24),

                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
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
}

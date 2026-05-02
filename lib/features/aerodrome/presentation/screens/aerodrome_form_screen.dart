import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../data/models/aerodrome.dart';
import '../cubit/aerodrome_cubit.dart';

class AerodromeFormScreen extends StatefulWidget {
  final dynamic aerodrome;

  const AerodromeFormScreen({super.key, this.aerodrome});

  @override
  State<AerodromeFormScreen> createState() => _AerodromeFormScreenState();
}

class _AerodromeFormScreenState extends State<AerodromeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _icaoCodeController = TextEditingController();
  final _arabicNameController = TextEditingController();
  final _englishNameController = TextEditingController();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _elevationController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _operatorController = TextEditingController();
  final _supervisingAuthorityController = TextEditingController();
  final _longestRunwayController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController();

  String _airportType = 'عسكري';
  String _operationalStatus = 'نشط';
  String _icaoCategory = '4F';
  DateTime? _creationDate;
  DateTime? _lastInspection;
  bool _isLoading = false;

  final List<String> _airportTypes = ['عسكري', 'مدني', 'مختلط'];

  final List<String> _operationalStatuses = [
    'نشط',
    'مغلق مؤقتاً',
    'مغلق نهائياً',
    'تحت الصيانة',
  ];

  final List<String> _icaoCategories = [
    '4F',
    '4E',
    '4D',
    '4C',
    '3F',
    '3E',
    '3D',
    '3C',
    '2F',
    '2E',
    '2D',
    '2C',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.aerodrome != null) {
      _populateForm(widget.aerodrome);
    }
  }

  void _populateForm(dynamic aerodrome) {
    _icaoCodeController.text = aerodrome.icaoCode;
    _arabicNameController.text = aerodrome.arabicName;
    _englishNameController.text = aerodrome.englishName;
    _governorateController.text = aerodrome.governorate;
    _cityController.text = aerodrome.city;
    _latitudeController.text = aerodrome.latitude.toString();
    _longitudeController.text = aerodrome.longitude.toString();
    _elevationController.text = aerodrome.elevation.toString();
    _registrationNumberController.text = aerodrome.registrationNumber;
    _operatorController.text = aerodrome.operator;
    _supervisingAuthorityController.text = aerodrome.supervisingAuthority;
    _longestRunwayController.text = aerodrome.longestRunway.toString();
    _capacityController.text = aerodrome.capacity.toString();
    _notesController.text = aerodrome.notes ?? '';
    _airportType = aerodrome.airportType;
    _operationalStatus = aerodrome.operationalStatus;
    _icaoCategory = aerodrome.icaoCategory;
    _creationDate = aerodrome.creationDate;
    _lastInspection = aerodrome.lastInspection;
  }

  @override
  void dispose() {
    _icaoCodeController.dispose();
    _arabicNameController.dispose();
    _englishNameController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _elevationController.dispose();
    _registrationNumberController.dispose();
    _operatorController.dispose();
    _supervisingAuthorityController.dispose();
    _longestRunwayController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.aerodrome == null ? 'إضافة مطار' : 'تعديل المطار'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildOperationalSection(),
                  const SizedBox(height: 24),
                  _buildTechnicalSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
            if (_isLoading)
              const LoadingOverlay(isLoading: true, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المعلومات الأساسية',
          style: AppFonts.headline6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'كود ICAO',
          hint: 'مثال: HEAX',
          controller: _icaoCodeController,
          validator: Validators.validateIcaoCode,
          maxLength: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'اسم المطار بالعربية',
          hint: 'أدخل اسم المطار بالعربية',
          controller: _arabicNameController,
          validator: (value) =>
              Validators.validateRequired(value, 'اسم المطار'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'اسم المطار بالإنجليزية',
          hint: 'أدخل اسم المطار بالإنجليزية',
          controller: _englishNameController,
          validator: (value) =>
              Validators.validateRequired(value, 'اسم المطار بالإنجليزية'),
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'نوع المطار',
          hint: 'اختر نوع المطار',
          items: _airportTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _airportType,
          onChanged: (value) => setState(() => _airportType = value!),
          validator: (value) =>
              Validators.validateRequired(value, 'نوع المطار'),
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'تاريخ الإنشاء',
          date: _creationDate,
          onTap: () => _selectDate(context, (date) {
            setState(() => _creationDate = date);
          }),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع الجغرافي',
          style: AppFonts.headline6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'المحافظة',
          hint: 'أدخل المحافظة',
          controller: _governorateController,
          validator: (value) => Validators.validateRequired(value, 'المحافظة'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'المدينة',
          hint: 'أدخل المدينة',
          controller: _cityController,
          validator: (value) => Validators.validateRequired(value, 'المدينة'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'خط العرض',
                hint: 'مثال: 30.1234',
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Validators.validateRequired(value, 'خط العرض'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'خط الطول',
                hint: 'مثال: 31.5678',
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Validators.validateRequired(value, 'خط الطول'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'الارتفاع (متر)',
          hint: 'أدخل الارتفاع فوق مستوى البحر',
          controller: _elevationController,
          keyboardType: TextInputType.number,
          validator: (value) => Validators.validateRequired(value, 'الارتفاع'),
        ),
      ],
    );
  }

  Widget _buildOperationalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة التشغيلية',
          style: AppFonts.headline6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'الحالة التشغيلية',
          hint: 'اختر الحالة التشغيلية',
          items: _operationalStatuses
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _operationalStatus,
          onChanged: (value) => setState(() => _operationalStatus = value!),
          validator: (value) =>
              Validators.validateRequired(value, 'الحالة التشغيلية'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'رقم التسجيل',
          hint: 'أدخل رقم التسجيل',
          controller: _registrationNumberController,
          validator: (value) =>
              Validators.validateRequired(value, 'رقم التسجيل'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'المشغل',
          hint: 'أدخل اسم المشغل',
          controller: _operatorController,
          validator: (value) => Validators.validateRequired(value, 'المشغل'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'الجهة المشرفة',
          hint: 'أدخل الجهة المشرفة',
          controller: _supervisingAuthorityController,
          validator: (value) =>
              Validators.validateRequired(value, 'الجهة المشرفة'),
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'تاريخ آخر فحص',
          date: _lastInspection,
          onTap: () => _selectDate(context, (date) {
            setState(() => _lastInspection = date);
          }),
        ),
      ],
    );
  }

  Widget _buildTechnicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المواصفات الفنية',
          style: AppFonts.headline6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'فئة ICAO',
          hint: 'اختر فئة ICAO',
          items: _icaoCategories
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _icaoCategory,
          onChanged: (value) => setState(() => _icaoCategory = value!),
          validator: (value) => Validators.validateRequired(value, 'فئة ICAO'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'أطول مدرج (متر)',
          hint: 'أدخل طول أطول مدرج',
          controller: _longestRunwayController,
          keyboardType: TextInputType.number,
          validator: (value) => Validators.validateRequired(value, 'أطول مدرج'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'السعة (طائرة)',
          hint: 'أدخل السعة الاستيعابية',
          controller: _capacityController,
          keyboardType: TextInputType.number,
          validator: (value) => Validators.validateRequired(value, 'السعة'),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات',
          style: AppFonts.headline6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'ملاحظات إضافية',
          hint: 'أدخل أي ملاحظات إضافية',
          controller: _notesController,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: AppColors.card,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'اختر التاريخ',
          style: AppFonts.bodyMedium.copyWith(
            color: date != null ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        widget.aerodrome == null ? 'إضافة المطار' : 'حفظ التعديلات',
        style: AppFonts.labelLarge.copyWith(fontWeight: AppFonts.bold),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final aerodrome = Aerodrome(
          id: widget.aerodrome?.id ?? const Uuid().v4(),
          icaoCode: _icaoCodeController.text.toUpperCase(),
          arabicName: _arabicNameController.text,
          englishName: _englishNameController.text,
          creationDate: _creationDate ?? DateTime.now(),
          airportType: _airportType,
          governorate: _governorateController.text,
          city: _cityController.text,
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          elevation: double.parse(_elevationController.text),
          operationalStatus: _operationalStatus,
          registrationNumber: _registrationNumberController.text,
          operator: _operatorController.text,
          supervisingAuthority: _supervisingAuthorityController.text,
          icaoCategory: _icaoCategory,
          longestRunway: double.parse(_longestRunwayController.text),
          capacity: int.parse(_capacityController.text),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          lastInspection: _lastInspection,
          createdAt: widget.aerodrome?.createdAt,
          updatedAt: DateTime.now(),
        );

        if (widget.aerodrome == null) {
          await context.read<AerodromeCubit>().addAerodrome(aerodrome);
        } else {
          await context.read<AerodromeCubit>().updateAerodrome(aerodrome);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.aerodrome == null
                  ? 'تم حفظ بيانات المطار بنجاح'
                  : 'تم تحديث بيانات المطار بنجاح',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر حفظ بيانات المطار: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}

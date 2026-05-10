/*import 'package:flutter/material.dart';
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

  final List<String> _airportTypes = ['عسكري', 'مدني', 'مختلط', 'متخصص'];

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
}*/
import 'package:falcon_system/features/aerodrome/presentation/screens/egyption_airport_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
 // ← مسار ملف البيانات
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
  // ── Form Key ────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────
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

  // ── Dropdown State ───────────────────────────────────────────────────────
  String _airportType = 'عسكري';
  String _operationalStatus = 'نشط';
  String _icaoCategory = '4F';
  DateTime? _creationDate;
  DateTime? _lastInspection;
  bool _isLoading = false;

  // ── DMS Coordinates State (Professional Picker) ───────────────────────────
  int _latDeg = 30;
  int _latMin = 0;
  int _latSec = 0;
  String _latDir = 'N';

  int _lonDeg = 31;
  int _lonMin = 0;
  int _lonSec = 0;
  String _lonDir = 'E';

  // ── Airport Picker State ─────────────────────────────────────────────────
  /// الاختيار من القائمة — null = لم يختر بعد، '__other__' = أخرى
  EgyptAirportEntry? _selectedKnownAirport;
  bool _isCustomAirport = false; // اليوزر اختار "أخرى"
  bool _airportPicked = false; // اختار أي شيء من الـ picker

  // ── Options ──────────────────────────────────────────────────────────────
  final List<String> _airportTypes = ['عسكري', 'مدني', 'مختلط', 'متخصص'];
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

  // ── Type color map ───────────────────────────────────────────────────────
  static const Map<EgyptAirportCategory, Color> _catColors = {
    EgyptAirportCategory.civil: Color(0xFF1565C0),
    EgyptAirportCategory.military: Color(0xFFC62828),
    EgyptAirportCategory.mixed: Color(0xFF6A1B9A),
    EgyptAirportCategory.local: Color(0xFF00695C),
  };

  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    if (widget.aerodrome != null) _populateForm(widget.aerodrome);
  }

  void _populateForm(dynamic a) {
    _icaoCodeController.text = a.icaoCode;
    _arabicNameController.text = a.arabicName;
    _englishNameController.text = a.englishName;
    _governorateController.text = a.governorate;
    _cityController.text = a.city;
    _latitudeController.text = a.latitude.toString();
    _longitudeController.text = a.longitude.toString();
    _elevationController.text = a.elevation.toString();
    _registrationNumberController.text = a.registrationNumber;
    _operatorController.text = a.operator;
    _supervisingAuthorityController.text = a.supervisingAuthority;
    _longestRunwayController.text = a.longestRunway.toString();
    _capacityController.text = a.capacity.toString();
    _notesController.text = a.notes ?? '';
    _airportType = a.airportType;
    _operationalStatus = a.operationalStatus;
    _icaoCategory = a.icaoCategory;
    _creationDate = a.creationDate;
    _lastInspection = a.lastInspection;
    _setCoordinatesFromDecimal(a.latitude, a.longitude);
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

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

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
                  // ── اختيار مطار من القائمة (فقط عند الإضافة) ────────────
                  if (widget.aerodrome == null) ...[
                    _buildAirportPickerSection(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 4),
                  ],

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
                  const SizedBox(height: 24),
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

  // ══════════════════════════════════════════════════════════════════════════
  // AIRPORT PICKER SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAirportPickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── عنوان ─────────────────────────────────────────────────────────
        Row(
          children: [
            const Icon(
              Icons.travel_explore_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'اختر من قائمة مطارات مصر',
              style: AppFonts.headline6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'اختر مطارًا لملء بيانات ICAO تلقائيًا، أو اختر «أخرى» للإدخال اليدوي',
          style: AppFonts.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        // ── زر الـ Picker ──────────────────────────────────────────────────
        _buildPickerButton(),

        // ── حقل ICAO اليدوي — يظهر فقط عند اختيار "أخرى" ─────────────────
        if (_isCustomAirport) ...[
          const SizedBox(height: 12),
          CustomTextField(
            label: 'كود ICAO',
            hint: 'مثال: HEXY',
            controller: _icaoCodeController,
            validator: Validators.validateIcaoCode,
            maxLength: 4,
            
          ),
        ],

        // ── معلومات المطار المختار ─────────────────────────────────────────
        if (_selectedKnownAirport != null && !_isCustomAirport) ...[
          const SizedBox(height: 12),
          _buildSelectedAirportCard(_selectedKnownAirport!),
        ],
      ],
    );
  }

  /// زر يفتح Bottom Sheet قائمة المطارات
  Widget _buildPickerButton() {
    final hasSelection = _airportPicked;
    final label = _isCustomAirport
        ? '✏️  إدخال يدوي (أخرى)'
        : _selectedKnownAirport != null
        ? '${_selectedKnownAirport!.icaoCode}  —  ${_selectedKnownAirport!.arabicName}'
        : 'اختر مطارًا من القائمة';

    return GestureDetector(
      onTap: () => _showAirportPickerSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection
                ? AppColors.primary.withOpacity(0.6)
                : AppColors.textHint.withOpacity(0.4),
            width: hasSelection ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isCustomAirport
                  ? Icons.edit_rounded
                  : _selectedKnownAirport != null
                  ? _selectedKnownAirport!.icon
                  : Icons.flight_outlined,
              color: hasSelection
                  ? (_selectedKnownAirport != null
                        ? _catColors[_selectedKnownAirport!.category]!
                        : AppColors.primary)
                  : AppColors.textHint,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppFonts.labelMedium.copyWith(
                  color: hasSelection
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  /// كارد يعرض ملخص المطار المختار (ICAO locked)
  Widget _buildSelectedAirportCard(EgyptAirportEntry entry) {
    final color = _catColors[entry.category] ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.icaoCode,
                  style: AppFonts.labelLarge.copyWith(
                    color: color,
                    fontWeight: AppFonts.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                if (entry.iataCode != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.iataCode!,
                    style: AppFonts.labelSmall.copyWith(
                      fontSize: 9,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.arabicName,
                  style: AppFonts.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppFonts.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.englishName,
                  style: AppFonts.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(entry.icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      entry.typeLabel,
                      style: AppFonts.labelSmall.copyWith(
                        fontSize: 11,
                        color: color,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET — قائمة المطارات مع بحث
  // ══════════════════════════════════════════════════════════════════════════

  void _showAirportPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AirportPickerSheet(
        onSelected: (entry) {
          Navigator.pop(context);
          _onKnownAirportSelected(entry);
        },
        onCustom: () {
          Navigator.pop(context);
          _onCustomSelected();
        },
      ),
    );
  }

  void _onKnownAirportSelected(EgyptAirportEntry entry) {
    setState(() {
      _selectedKnownAirport = entry;
      _isCustomAirport = false;
      _airportPicked = true;
      _icaoCodeController.text = entry.icaoCode;
      _arabicNameController.text = entry.arabicName;
      _englishNameController.text = entry.englishName;

      // تعيين نوع المطار تلقائيًا
      switch (entry.category) {
        case EgyptAirportCategory.civil:
          _airportType = 'مدني';
          break;
        case EgyptAirportCategory.military:
          _airportType = 'عسكري';
          break;
        case EgyptAirportCategory.mixed:
          _airportType = 'مختلط';
          break;
        case EgyptAirportCategory.local:
          _airportType = 'متخصص';
          break;
      }
    });
  }

  void _onCustomSelected() {
    setState(() {
      _selectedKnownAirport = null;
      _isCustomAirport = true;
      _airportPicked = true;
      _icaoCodeController.clear();
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORM SECTIONS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildBasicInfoSection() {
    // عند التعديل أو عند اختيار مطار معروف → ICAO يبقى مقفول
    final icaoLocked =
        widget.aerodrome != null || (_airportPicked && !_isCustomAirport);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('المعلومات الأساسية', Icons.info_outline_rounded),
        const SizedBox(height: 16),

        // ── حقل ICAO: يظهر دائمًا عند التعديل وعند إضافة يدوية ───────────
        // (عند اختيار مطار معروف يكون مقفول ومعروض فى كارد الـ picker)
        if (widget.aerodrome != null ||
            _isCustomAirport ||
            !_airportPicked) ...[
          if (!(widget.aerodrome == null &&
              _airportPicked &&
              !_isCustomAirport))
            CustomTextField(
              label: 'كود ICAO',
              hint: 'مثال: HEAX',
              controller: _icaoCodeController,
              validator: Validators.validateIcaoCode,
              maxLength: 5,
              enabled: !icaoLocked,
              suffixIcon: icaoLocked
                  ? const Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: AppColors.textHint,
                    )
                  : null,
            ),
          const SizedBox(height: 16),
        ],

        CustomTextField(
          label: 'اسم المطار بالعربية',
          hint: 'أدخل اسم المطار بالعربية',
          controller: _arabicNameController,
          validator: (v) => Validators.validateRequired(v, 'اسم المطار'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'اسم المطار بالإنجليزية',
          hint: 'Airport English Name',
          controller: _englishNameController,
          validator: (v) =>
              Validators.validateRequired(v, 'اسم المطار بالإنجليزية'),
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'نوع المطار',
          hint: 'اختر نوع المطار',
          items: _airportTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _airportType,
          onChanged: (v) => setState(() => _airportType = v!),
          validator: (v) => Validators.validateRequired(v, 'نوع المطار'),
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'تاريخ الإنشاء',
          date: _creationDate,
          onTap: () =>
              _selectDate(context, (d) => setState(() => _creationDate = d)),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('الموقع الجغرافي', Icons.location_on_outlined),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'المحافظة',
          hint: 'أدخل المحافظة',
          controller: _governorateController,
          validator: (v) => Validators.validateRequired(v, 'المحافظة'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'المدينة',
          hint: 'أدخل المدينة',
          controller: _cityController,
          validator: (v) => Validators.validateRequired(v, 'المدينة'),
        ),
        const SizedBox(height: 16),
        _buildCoordinatePickerCard(
          title: 'خط العرض',
          subtitle: 'Latitude (N/S)',
          isLatitude: true,
          maxDegree: 90,
          degree: _latDeg,
          minute: _latMin,
          second: _latSec,
          direction: _latDir,
          directions: const ['N', 'S'],
          onDegreeChanged: (v) => setState(() => _latDeg = v ?? _latDeg),
          onMinuteChanged: (v) => setState(() => _latMin = v ?? _latMin),
          onSecondChanged: (v) => setState(() => _latSec = v ?? _latSec),
          onDirectionChanged: (v) => setState(() => _latDir = v ?? _latDir),
        ),
        const SizedBox(height: 12),
        _buildCoordinatePickerCard(
          title: 'خط الطول',
          subtitle: 'Longitude (E/W)',
          isLatitude: false,
          maxDegree: 180,
          degree: _lonDeg,
          minute: _lonMin,
          second: _lonSec,
          direction: _lonDir,
          directions: const ['E', 'W'],
          onDegreeChanged: (v) => setState(() => _lonDeg = v ?? _lonDeg),
          onMinuteChanged: (v) => setState(() => _lonMin = v ?? _lonMin),
          onSecondChanged: (v) => setState(() => _lonSec = v ?? _lonSec),
          onDirectionChanged: (v) => setState(() => _lonDir = v ?? _lonDir),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Container(
            key: ValueKey(
              'coord_${[
                _latDeg,
                _latMin,
                _latSec,
                _latDir,
                _lonDeg,
                _lonMin,
                _lonSec,
                _lonDir,
              ].join('_')}',
            ),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
            ),
            child: Text(
              'DMS: ${_formatDms(_latDeg, _latMin, _latSec, _latDir)}  |  ${_formatDms(_lonDeg, _lonMin, _lonSec, _lonDir)}',
              style: AppFonts.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppFonts.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'الارتفاع (متر)',
          hint: 'الارتفاع فوق مستوى البحر',
          controller: _elevationController,
          keyboardType: TextInputType.number,
          validator: (v) => Validators.validateRequired(v, 'الارتفاع'),
        ),
      ],
    );
  }

  Widget _buildOperationalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('الحالة التشغيلية', Icons.settings_outlined),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'الحالة التشغيلية',
          hint: 'اختر الحالة التشغيلية',
          items: _operationalStatuses
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _operationalStatus,
          onChanged: (v) => setState(() => _operationalStatus = v!),
          validator: (v) => Validators.validateRequired(v, 'الحالة التشغيلية'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'رقم التسجيل',
          hint: 'أدخل رقم التسجيل',
          controller: _registrationNumberController,
          validator: (v) => Validators.validateRequired(v, 'رقم التسجيل'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'المشغل',
          hint: 'أدخل اسم المشغل',
          controller: _operatorController,
          validator: (v) => Validators.validateRequired(v, 'المشغل'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'الجهة المشرفة',
          hint: 'أدخل الجهة المشرفة',
          controller: _supervisingAuthorityController,
          validator: (v) => Validators.validateRequired(v, 'الجهة المشرفة'),
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'تاريخ آخر فحص',
          date: _lastInspection,
          onTap: () =>
              _selectDate(context, (d) => setState(() => _lastInspection = d)),
        ),
      ],
    );
  }

  Widget _buildTechnicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('المواصفات الفنية', Icons.engineering_outlined),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'فئة ICAO',
          hint: 'اختر فئة ICAO',
          items: _icaoCategories
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          value: _icaoCategory,
          onChanged: (v) => setState(() => _icaoCategory = v!),
          validator: (v) => Validators.validateRequired(v, 'فئة ICAO'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'أطول مدرج (متر)',
          hint: 'أدخل طول أطول مدرج',
          controller: _longestRunwayController,
          keyboardType: TextInputType.number,
          validator: (v) => Validators.validateRequired(v, 'أطول مدرج'),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'السعة (طائرة)',
          hint: 'أدخل السعة الاستيعابية',
          controller: _capacityController,
          keyboardType: TextInputType.number,
          validator: (v) => Validators.validateRequired(v, 'السعة'),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ملاحظات', Icons.notes_rounded),
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

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppFonts.headline6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFonts.bold,
          ),
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
    Function(DateTime) onSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) onSelected(picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // تحقق من أن اليوزر اختار مطار أو أدخل ICAO يدويًا
    if (widget.aerodrome == null && !_airportPicked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار مطار من القائمة أو تحديد «أخرى»'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final latitude = _toDecimal(_latDeg, _latMin, _latSec, _latDir);
    final longitude = _toDecimal(_lonDeg, _lonMin, _lonSec, _lonDir);

    // نحتفظ بالقيمة العشرية داخل الكونترولر فقط لسهولة التتبع/التوافق.
    _latitudeController.text = latitude.toStringAsFixed(6);
    _longitudeController.text = longitude.toStringAsFixed(6);

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
        latitude: latitude,
        longitude: longitude,
        elevation: double.tryParse(_elevationController.text) ?? 0,
        operationalStatus: _operationalStatus,
        registrationNumber: _registrationNumberController.text,
        operator: _operatorController.text,
        supervisingAuthority: _supervisingAuthorityController.text,
        icaoCategory: _icaoCategory,
        longestRunway: double.tryParse(_longestRunwayController.text) ?? 0,
        capacity: int.tryParse(_capacityController.text) ?? 0,
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // COORDINATE PICKER HELPERS
  // ════════════════════════════════════════════════════════════════════════

  void _setCoordinatesFromDecimal(double latitude, double longitude) {
    final lat = _fromDecimal(latitude);
    final lon = _fromDecimal(longitude);

    _latDeg = lat.$1;
    _latMin = lat.$2;
    _latSec = lat.$3;
    _latDir = latitude < 0 ? 'S' : 'N';

    _lonDeg = lon.$1;
    _lonMin = lon.$2;
    _lonSec = lon.$3;
    _lonDir = longitude < 0 ? 'W' : 'E';
  }

  (int, int, int) _fromDecimal(double value) {
    final absValue = value.abs();
    final deg = absValue.floor();
    final minRaw = (absValue - deg) * 60;
    final min = minRaw.floor();
    final sec = ((minRaw - min) * 60).round();

    if (sec == 60) {
      if (min + 1 == 60) {
        return (deg + 1, 0, 0);
      }
      return (deg, min + 1, 0);
    }
    return (deg, min, sec);
  }

  double _toDecimal(int deg, int min, int sec, String dir) {
    final value = deg + (min / 60.0) + (sec / 3600.0);
    return (dir == 'S' || dir == 'W') ? -value : value;
  }

  String _formatDms(int deg, int min, int sec, String dir) {
    return '$deg° ${min.toString().padLeft(2, '0')}\' ${sec.toString().padLeft(2, '0')}" $dir';
  }

  Widget _buildCoordinatePickerCard({
    required String title,
    required String subtitle,
    required bool isLatitude,
    required int maxDegree,
    required int degree,
    required int minute,
    required int second,
    required String direction,
    required List<String> directions,
    required ValueChanged<int?> onDegreeChanged,
    required ValueChanged<int?> onMinuteChanged,
    required ValueChanged<int?> onSecondChanged,
    required ValueChanged<String?> onDirectionChanged,
  }) {
    final accent = isLatitude ? const Color(0xFF1565C0) : const Color(0xFF2E7D32);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLatitude ? Icons.north_rounded : Icons.explore_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppFonts.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppFonts.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: AppFonts.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dmsDropdown<int>(
                  label: '°',
                  value: degree,
                  items: List<int>.generate(maxDegree + 1, (i) => i),
                  onChanged: onDegreeChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dmsDropdown<int>(
                  label: '\'',
                  value: minute,
                  items: List<int>.generate(60, (i) => i),
                  onChanged: onMinuteChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dmsDropdown<int>(
                  label: '"',
                  value: second,
                  items: List<int>.generate(60, (i) => i),
                  onChanged: onSecondChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dmsDropdown<String>(
                  label: 'Dir',
                  value: direction,
                  items: directions,
                  onChanged: onDirectionChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dmsDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                e is int ? e.toString().padLeft(2, '0') : e.toString(),
                overflow: TextOverflow.ellipsis,
                style: AppFonts.labelMedium.copyWith(color: AppColors.textPrimary),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AIRPORT PICKER BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _AirportPickerSheet extends StatefulWidget {
  final void Function(EgyptAirportEntry) onSelected;
  final VoidCallback onCustom;

  const _AirportPickerSheet({required this.onSelected, required this.onCustom});

  @override
  State<_AirportPickerSheet> createState() => _AirportPickerSheetState();
}

class _AirportPickerSheetState extends State<_AirportPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  static const Map<EgyptAirportCategory, Color> _catColors = {
    EgyptAirportCategory.civil: Color(0xFF1565C0),
    EgyptAirportCategory.military: Color(0xFFC62828),
    EgyptAirportCategory.mixed: Color(0xFF6A1B9A),
    EgyptAirportCategory.local: Color(0xFF00695C),
  };

  static const Map<EgyptAirportCategory, String> _catLabels = {
    EgyptAirportCategory.civil: 'مطارات مدنية',
    EgyptAirportCategory.military: 'قواعد جوية عسكرية',
    EgyptAirportCategory.mixed: 'مطارات مختلطة',
    EgyptAirportCategory.local: 'مطارات محلية وخاصة',
  };

  List<EgyptAirportEntry> get _filtered {
    if (_query.isEmpty) return EgyptianAirportsData.all;
    final q = _query.toLowerCase();
    return EgyptianAirportsData.all.where((e) {
      return e.icaoCode.toLowerCase().contains(q) ||
          e.arabicName.contains(q) ||
          e.englishName.toLowerCase().contains(q) ||
          (e.iataCode?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = <EgyptAirportCategory, List<EgyptAirportEntry>>{};
    for (final e in _filtered) {
      groups.putIfAbsent(e.category, () => []).add(e);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // ── Handle ────────────────────────────────────────────────
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),

                // ── العنوان ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مطارات جمهورية مصر العربية',
                        style: AppFonts.headline6.copyWith(
                          fontWeight: AppFonts.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${EgyptianAirportsData.all.length} مطار',
                        style: AppFonts.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── شريط البحث ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو ICAO أو IATA...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),

                // ── القائمة ───────────────────────────────────────────────
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // ── خيار "أخرى" ─────────────────────────────────────
                      _buildCustomOption(),
                      const Divider(height: 1),

                      // ── مجموعات حسب النوع ───────────────────────────────
                      for (final cat in EgyptAirportCategory.values)
                        if (groups.containsKey(cat)) ...[
                          _buildGroupHeader(cat),
                          for (final entry in groups[cat]!)
                            _buildAirportTile(entry),
                        ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomOption() {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.edit_rounded, color: Colors.grey, size: 20),
      ),
      title: const Text(
        'أخرى — إدخال يدوي',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('اكتب كود ICAO خاص بك'),
      trailing: const Icon(
        Icons.keyboard_arrow_left_rounded,
        color: Colors.grey,
      ),
      onTap: widget.onCustom,
    );
  }

  Widget _buildGroupHeader(EgyptAirportCategory cat) {
    final color = _catColors[cat] ?? Colors.grey;
    final entry = EgyptianAirportsData.all.firstWhere((e) => e.category == cat);
    return Container(
      color: color.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(entry.icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            _catLabels[cat] ?? '',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirportTile(EgyptAirportEntry entry) {
    final color = _catColors[entry.category] ?? Colors.grey;
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entry.icaoCode,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            if (entry.iataCode != null)
              Text(
                entry.iataCode!,
                style: TextStyle(color: color.withOpacity(0.6), fontSize: 8),
              ),
          ],
        ),
      ),
      title: Text(
        entry.arabicName,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        entry.englishName,
        style: const TextStyle(fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entry.icon, size: 14, color: color.withOpacity(0.6)),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: Colors.grey,
            size: 18,
          ),
        ],
      ),
      onTap: () => widget.onSelected(entry),
    );
  }
}

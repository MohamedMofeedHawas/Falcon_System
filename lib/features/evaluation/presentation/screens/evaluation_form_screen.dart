import 'dart:typed_data';

import 'package:falcon_system/data/sections/apron_evaluation.dart';
import 'package:falcon_system/data/sections/apron_section_widget.dart';
import 'package:falcon_system/data/sections/met_evaluation.dart';
import 'package:falcon_system/data/sections/met_section_widget.dart';
import 'package:falcon_system/data/sections/rffs_evaluation.dart';
import 'package:falcon_system/data/sections/rffs_section_widget.dart';
import 'package:falcon_system/data/sections/sms_evaluation.dart';
import 'package:falcon_system/data/sections/sms_section_widget.dart';
import 'package:falcon_system/data/sections/taxiway_evaluation.dart';
import 'package:falcon_system/data/sections/taxiway_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/evaluation_slider.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/signature_pad.dart';
import '../../../../data/models/aerodrome.dart';
import '../../../../data/models/aircraft.dart';
import '../../../../data/models/airport_manager.dart';
import '../../../../data/models/evaluation_report.dart';
import '../../../../data/models/inspection_head.dart';
import '../../../../data/models/inspection_member.dart';
import '../../../aerodrome/presentation/cubit/aerodrome_cubit.dart';
import '../../../aircraft/presentation/cubit/aircraft_cubit.dart';
import '../../../manager/presentation/cubit/manager_cubit.dart';
import '../../../team/presentation/cubit/team_cubit.dart';
import '../cubit/evaluation_cubit.dart';

class EvaluationFormScreen extends StatefulWidget {
  final EvaluationReport? evaluation;

  const EvaluationFormScreen({super.key, this.evaluation});

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  // Basic Info
  String? _selectedAerodromeId;
  String? _selectedAerodromeName;
  String? _selectedManagerId;
  String? _selectedManagerName;
  String? _selectedHeadId;
  String? _selectedHeadName;
  List<String> _selectedMemberIds = [];
  List<String> _selectedMemberNames = [];
  String? _selectedAircraftId;
  String? _selectedAircraftName;
  String? _pendingMemberId;
  DateTime _evaluationDateTime = DateTime.now(); // ← دايمًا عنده قيمة
  String? _notes;

  List<Aerodrome> _aerodromes = [];
  List<AirportManager> _managers = [];
  List<InspectionHead> _heads = [];
  List<InspectionMember> _members = [];
  List<Aircraft> _aircraft = [];

  // Signatures
  Uint8List? _managerSignature;
  Uint8List? _headSignature;

  // Section Evaluations
  Map<String, dynamic> _runwayEvaluation = {};
  TaxiwayEvaluation _taxiwayModel_2 = TaxiwayEvaluation();
  ApronEvaluation _apronEvaluation = ApronEvaluation();
  RffsEvaluation _rffsModel = RffsEvaluation();
  MetEvaluation _metModel = MetEvaluation();
  Map<String, dynamic> _navaidsEvaluation = {};
  Map<String, dynamic> _operationalEvaluation = {};
  SmsEvaluation _smsModel = SmsEvaluation();
  Map<String, dynamic> _documentsEvaluation = {};

  // Runway items
  final List<String> _runwayItems = [
    'حالة سطح المدرج',
    'إضاءة المدرج',
    'علامات المدرج',
    'نظام الإخلاء',
    'مقاومة السطح',
  ];

  // Taxiway items
  final List<String> _taxiwayItems = [
    'حالة المسارات',
    'إضاءة المسارات',
    'علامات المسارات',
    'نظام التوجيه',
  ];

  // Apron items
  final List<String> _apronItems = [
    'حالة الساحة',
    'إضاءة الساحة',
    'مواقف الطائرات',
    'نظام التزويد بالوقود',
  ];

  // RFFS items
  final List<String> _rffsItems = [
    'معدات الإطفاء',
    'الطاقم المتاح',
    'استجابة الطوارئ',
    'التدريب المنتظم',
    'معدات الإنقاذ',
  ];

  // MET items
  final List<String> _metItems = [
    'دقة القياسات',
    'نظام الرصد',
    'تنبيهات الطقس',
    'أجهزة الاتصال',
  ];

  // NAVAIDS items
  final List<String> _navaidsItems = [
    'نظام الهبوط',
    'أجهزة الملاحة',
    'إضاءة الممرات',
    'نظام الاتصال',
  ];

  // Operational items
  final List<String> _operationalItems = [
    'برج المراقبة',
    'خدمة الحركة الجوية',
    'إجراءات السلامة',
    'التدريب المستمر',
  ];

  // SMS items
  final List<String> _smsItems = [
    'نظام إدارة السلامة',
    'إدارة المخاطر',
    'التدريب على السلامة',
    'التوثيق والتحقيق',
  ];

  // Documents items
  final List<String> _documentsItems = [
    'دليل العمليات',
    'شهادات الترخيص',
    'سجلات الصيانة',
    'وثائق التدريب',
  ];

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
    if (widget.evaluation != null) {
      _populateForm(widget.evaluation!);
    }
  }

  void _loadReferenceData() {
    context.read<AerodromeCubit>().loadAerodromes();
    context.read<ManagerCubit>().loadManagers();
    context.read<TeamCubit>().loadTeam();
    context.read<AircraftCubit>().loadAircraft();
    _syncDataFromStates();
  }

  void _syncDataFromStates() {
    final aerodromeState = context.read<AerodromeCubit>().state;
    final managerState = context.read<ManagerCubit>().state;
    final teamState = context.read<TeamCubit>().state;
    final aircraftState = context.read<AircraftCubit>().state;

    if (aerodromeState is AerodromeLoaded) {
      _aerodromes = aerodromeState.aerodromes.cast<Aerodrome>();
    }
    if (managerState is ManagerLoaded) {
      _managers = managerState.managers;
    }
    if (teamState is TeamLoaded) {
      _heads = teamState.head;
      _members = teamState.members;
    }
    if (aircraftState is AircraftLoaded) {
      _aircraft = aircraftState.aircraft;
    }
  }

  void _populateForm(EvaluationReport evaluation) {
    _selectedAerodromeId = evaluation.aerodromeId;
    _selectedAerodromeName = evaluation.aerodromeName;
    _selectedManagerId = evaluation.managerId;
    _selectedManagerName = evaluation.managerName;
    _selectedHeadId = evaluation.headId;
    _selectedHeadName = evaluation.headName;
    _selectedMemberIds = evaluation.memberIds;
    _selectedMemberNames = evaluation.memberNames;
    _selectedAircraftId = evaluation.aircraftId;
    _selectedAircraftName = evaluation.aircraftName;

    // ← استخدم safeEvaluationDate بدل evaluationDate مباشرة
    _evaluationDateTime = evaluation.safeEvaluationDate;

    _notes = evaluation.notes;
    _managerSignature = evaluation.managerSignature;
    _headSignature = evaluation.headSignature;
    _runwayEvaluation = evaluation.runwayEvaluation;

    _taxiwayModel_2 = TaxiwayEvaluation.fromCompatibilityMap(
      evaluation.taxiwayEvaluation,
    );

    _apronEvaluation = ApronEvaluation.fromCompatibilityMap(
      evaluation.apronEvaluation,
    );
    _rffsModel = RffsEvaluation.fromCompatibilityMap(evaluation.rffsEvaluation);
    _metModel = MetEvaluation.fromCompatibilityMap(evaluation.metEvaluation);
    _navaidsEvaluation = evaluation.navaidsEvaluation;
    _operationalEvaluation = evaluation.operationalEvaluation;
    _smsModel = SmsEvaluation.fromCompatibilityMap(evaluation.smsEvaluation);
    _documentsEvaluation = evaluation.documentsEvaluation;
  }

  // ← دالة التاريخ والوقت المحسّنة
  Future<void> _selectDateTime() async {
    // الخطوة 1: اختيار التاريخ
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _evaluationDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    // الخطوة 2: اختيار الوقت
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_evaluationDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.card,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    // الخطوة 3: الثواني تلقائية من الوقت الحالي
    final int autoSeconds = DateTime.now().second;

    setState(() {
      _evaluationDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
        autoSeconds,
      );
    });
  }

  // ← دالة التنسيق الاحترافي — محمية من null
  String _formatDateTimeArabic(DateTime? dt) {
    // لو جه null لأي سبب، استخدم الوقت الحالي
    final safeDate = dt ?? DateTime.now();

    const List<String> arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    const List<String> arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final String dayName = arabicDays[safeDate.weekday - 1];
    final String monthName = arabicMonths[safeDate.month - 1];
    final String day = safeDate.day.toString().padLeft(2, '0');
    final String year = safeDate.year.toString();
    final String minute = safeDate.minute.toString().padLeft(2, '0');
    final String second = safeDate.second.toString().padLeft(2, '0');
    final String period = safeDate.hour >= 12 ? 'م' : 'ص';
    final int hour12 = safeDate.hour > 12
        ? safeDate.hour - 12
        : safeDate.hour == 0
        ? 12
        : safeDate.hour;
    final String hour12Str = hour12.toString().padLeft(2, '0');

    return '$dayName، $day $monthName $year\n$hour12Str:$minute:$second $period';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.evaluation == null ? 'تقرير تقييم جديد' : 'تعديل التقرير',
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
        ),
        body: Stack(
          children: [
            Stepper(
              currentStep: _currentStep,
              onStepContinue: _currentStep < 11 ? _nextStep : null,
              onStepCancel: _currentStep > 0 ? _previousStep : null,
              steps: [
                _buildBasicInfoStep(),
                _buildRunwayStep(),
                _buildTaxiwayStep(),
                _buildApronStep(),
                _buildRFFSStep(),
                _buildMETStep(),
                _buildNAVIDSStep(),
                _buildOperationalStep(),
                _buildSMSStep(),
                _buildDocumentsStep(),
                _buildSignaturesStep(),
                _buildSummaryStep(),
              ],
            ),
            if (_isLoading)
              const LoadingOverlay(isLoading: true, child: SizedBox()),
          ],
        ),
      ),
    );
  }

  Step _buildBasicInfoStep() {
    return Step(
      title: const Text('المعلومات الأساسية'),
      content: MultiBlocListener(
        listeners: [
          BlocListener<AerodromeCubit, AerodromeState>(
            listener: (context, state) {
              if (state is AerodromeLoaded) {
                setState(() {
                  _aerodromes = state.aerodromes.cast<Aerodrome>();
                });
              }
            },
          ),
          BlocListener<ManagerCubit, ManagerState>(
            listener: (context, state) {
              if (state is ManagerLoaded) {
                setState(() => _managers = state.managers);
              }
            },
          ),
          BlocListener<TeamCubit, TeamState>(
            listener: (context, state) {
              if (state is TeamLoaded) {
                setState(() {
                  _heads = state.head;
                  _members = state.members;
                });
              }
            },
          ),
          BlocListener<AircraftCubit, AircraftState>(
            listener: (context, state) {
              if (state is AircraftLoaded) {
                setState(() => _aircraft = state.aircraft);
              }
            },
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'المطار',
              hint: 'اختر المطار',
              items: _aerodromes
                  .map(
                    (a) => DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(a.arabicName),
                    ),
                  )
                  .toList(),
              value: _selectedAerodromeId,
              onChanged: (value) {
                if (value == null) return;
                final selected = _aerodromes.firstWhere((a) => a.id == value);
                setState(() {
                  _selectedAerodromeId = selected.id;
                  _selectedAerodromeName = selected.arabicName;
                });
              },
              validator: (value) => value == null ? 'يرجى اختيار المطار' : null,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'قائد المطار',
              hint: 'اختر قائد المطار',
              items: _managers
                  .map(
                    (m) => DropdownMenuItem<String>(
                      value: m.id,
                      child: Text(m.fullName),
                    ),
                  )
                  .toList(),
              value: _selectedManagerId,
              onChanged: (value) {
                if (value == null) return;
                final selected = _managers.firstWhere((m) => m.id == value);
                setState(() {
                  _selectedManagerId = selected.id;
                  _selectedManagerName = selected.fullName;
                });
              },
              validator: (value) =>
                  value == null ? 'يرجى اختيار قائد المطار' : null,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'رئيس لجنة التفتيش ',
              hint: 'اختر رئيس لجنة التفتيش',
              items: _heads
                  .map(
                    (h) => DropdownMenuItem<String>(
                      value: h.id,
                      child: Text(h.fullName),
                    ),
                  )
                  .toList(),
              value: _selectedHeadId,
              onChanged: (value) {
                if (value == null) return;
                final selected = _heads.firstWhere((h) => h.id == value);
                setState(() {
                  _selectedHeadId = selected.id;
                  _selectedHeadName = selected.fullName;
                });
              },
              validator: (value) =>
                  value == null ? 'يرجى اختيار رئيس لجنة التفتيش' : null,
            ),
            const SizedBox(height: 16),
            CustomDropdown<String>(
              label: 'عضو لجنة التفتيش',
              hint: 'اختر عضو لجنة التفتيش',
              items: _members
                  .where((m) => !_selectedMemberIds.contains(m.id))
                  .map(
                    (m) => DropdownMenuItem<String>(
                      value: m.id,
                      child: Text(m.fullName),
                    ),
                  )
                  .toList(),
              value: _pendingMemberId,
              onChanged: (value) {
                if (value == null) return;
                final selected = _members.firstWhere((m) => m.id == value);
                setState(() {
                  _pendingMemberId = null;
                  _selectedMemberIds = [..._selectedMemberIds, selected.id];
                  _selectedMemberNames = [
                    ..._selectedMemberNames,
                    selected.fullName,
                  ];
                });
              },
            ),
            if (_selectedMemberNames.isNotEmpty) const SizedBox(height: 8),
            ..._selectedMemberNames.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(name, style: AppFonts.bodyMedium)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.danger),
                      onPressed: () {
                        final index = _selectedMemberNames.indexOf(name);
                        if (index == -1) return;
                        setState(() {
                          _selectedMemberNames = List<String>.from(
                            _selectedMemberNames,
                          )..removeAt(index);
                          _selectedMemberIds = List<String>.from(
                            _selectedMemberIds,
                          )..removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ← Widget التاريخ والوقت المحسّن
            InkWell(
              onTap: _selectDateTime,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'تاريخ  التقييم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.calendar_today, size: 18),
                      SizedBox(height: 2),
                      Icon(Icons.access_time, size: 18),
                    ],
                  ),
                ),
                child: Text(
                  _formatDateTimeArabic(_evaluationDateTime),
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            CustomTextField(
              label: 'ملاحظات',
              hint: 'أدخل ملاحظات التقييم',
              controller: TextEditingController(text: _notes),
              maxLines: 4,
              onChanged: (value) => setState(() => _notes = value),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildRunwayStep() {
    return Step(
      title: const Text('المدرجات'),
      content: _buildEvaluationSection(
        'تقييم المدرجات',
        _runwayItems,
        _runwayEvaluation,
        (key, value) => setState(() => _runwayEvaluation[key] = value),
      ),
    );
  }

  Step _buildTaxiwayStep() {
    return Step(
      title: const Text('ممرات التاكسي'),
      content: TaxiwaySectionWidget(
        evaluation: _taxiwayModel_2,
        onChanged: (updated) => setState(() => _taxiwayModel_2 = updated),
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildApronStep() {
    return Step(
      title: const Text('ساحات الوقوف'),
      content: ApronSectionWidget(
        evaluation: _apronEvaluation,
        onChanged: (updated) => setState(() => _apronEvaluation = updated),
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildRFFSStep() {
    return Step(
      title: const Text('الإطفاء والإنقاذ'),
      content: RffsSectionWidget(
        evaluation: _rffsModel,
        onChanged: (updated) => setState(() => _rffsModel = updated),
      ),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildMETStep() {
    return Step(
      title: const Text('الأرصاد الجوية'),
      content: MetSectionWidget(
        evaluation: _metModel,
        onChanged: (updated) => setState(() => _metModel = updated),
      ),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildNAVIDSStep() {
    return Step(
      title: const Text('المساعدات الملاحية'),
      content: _buildEvaluationSection(
        'تقييم المساعدات الملاحية',
        _navaidsItems,
        _navaidsEvaluation,
        (key, value) => setState(() => _navaidsEvaluation[key] = value),
      ),
    );
  }

  Step _buildOperationalStep() {
    return Step(
      title: const Text('العمليات التشغيلية'),
      content: _buildEvaluationSection(
        'تقييم العمليات التشغيلية',
        _operationalItems,
        _operationalEvaluation,
        (key, value) => setState(() => _operationalEvaluation[key] = value),
      ),
    );
  }

 Step _buildSMSStep() {
    return Step(
      title: const Text('نظام السلامة'),
      content: SmsSectionWidget(
        evaluation: _smsModel,
        onChanged: (updated) => setState(() => _smsModel = updated),
      ),
      isActive: _currentStep >= 8,
      state: _currentStep > 8 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildDocumentsStep() {
    return Step(
      title: const Text('الوثائق'),
      content: _buildEvaluationSection(
        'تقييم الوثائق',
        _documentsItems,
        _documentsEvaluation,
        (key, value) => setState(() => _documentsEvaluation[key] = value),
      ),
    );
  }

  Step _buildSignaturesStep() {
    return Step(
      title: const Text('التوقيعات'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const SectionHeader(
            icon: Icons.person,
            title: 'توقيع قائد المطار',
            subtitle: 'يرجى التوقيع أدناه',
          ),
          const SizedBox(height: 16),
          SignaturePad(
            onSignatureChanged: (signature) {
              setState(() => _managerSignature = signature);
            },
          ),
          const SizedBox(height: 32),
          const SectionHeader(
            icon: Icons.badge,
            title: 'توقيع رئيس لجنة التفتيش',
            subtitle: 'يرجى التوقيع أدناه',
          ),
          const SizedBox(height: 16),
          SignaturePad(
            onSignatureChanged: (signature) {
              setState(() => _headSignature = signature);
            },
          ),
        ],
      ),
    );
  }

  Step _buildSummaryStep() {
    final cubit = context.read<EvaluationCubit>();
    final totalScore = cubit.calculateTotalScore({
      'runways': _runwayEvaluation,
      'taxiways': _taxiwayModel_2.toCompatibilityMap(),
      'aprons': _apronEvaluation.toCompatibilityMap(),
      'rescueFire': _rffsModel.toCompatibilityMap(),
      'meteorological': _metModel.toCompatibilityMap(),
      'navigationalAids': _navaidsEvaluation,
      'atc': _operationalEvaluation,
      'security': _smsModel.toCompatibilityMap(),
      'documentation': _documentsEvaluation,
    });

    final operationalDecision = cubit.getOperationalDecision(totalScore);
    final reinspectionDate = cubit.calculateReinspectionDate(totalScore);

    return Step(
      title: const Text('الملخص'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'النتيجة النهائية',
                    style: AppFonts.headline6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'الدرجة الكلية',
                              style: AppFonts.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${totalScore.toStringAsFixed(1)}%',
                              style: AppFonts.headline4.copyWith(
                                color: _getScoreColor(totalScore),
                                fontWeight: AppFonts.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'القرار التشغيلي',
                              style: AppFonts.labelMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              operationalDecision,
                              style: AppFonts.labelLarge.copyWith(
                                color: _getScoreColor(totalScore),
                                fontWeight: AppFonts.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تاريخ إعادة الفحص: ${app_date_utils.DateUtils.formatToArabic(reinspectionDate)}',
                    style: AppFonts.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitEvaluation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حفظ التقرير',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationSection(
    String title,
    List<String> items,
    Map<String, dynamic> evaluation,
    Function(String, Map<String, dynamic>) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.assessment,
          title: title,
          subtitle: 'قيم كل عنصر من 0 إلى 10',
        ),
        const SizedBox(height: 16),
        ...items.map((item) {
          final itemData = evaluation[item] as Map<String, dynamic>?;
          final score = (itemData?['score'] as num?)?.toDouble() ?? 5.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EvaluationSlider(
              label: item,
              value: score.toInt(),
              onChanged: (value) {
                onChanged(item, {
                  'score': value.toDouble(),
                  'note': itemData?['note'] as String? ?? '',
                });
              },
            ),
          );
        }),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return AppColors.excellent;
    if (score >= 75) return AppColors.good;
    if (score >= 60) return AppColors.acceptable;
    return AppColors.unsafe;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedManagerName != null || _selectedHeadName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
        );
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _previousStep() {
    setState(() => _currentStep--);
  }

  void _submitEvaluation() {
    if (_managerSignature == null || _headSignature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التوقيع من جميع الأطراف')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final cubit = context.read<EvaluationCubit>();
    final totalScore = cubit.calculateTotalScore({
      'runways': _runwayEvaluation,
      'taxiways': _taxiwayModel_2.toCompatibilityMap(),
      'aprons': _apronEvaluation.toCompatibilityMap(),
      'rescueFire': _rffsModel.toCompatibilityMap(),
      'meteorological': _metModel.toCompatibilityMap(),
      'navigationalAids': _navaidsEvaluation,
      'atc': _operationalEvaluation,
      'security': _smsModel.toCompatibilityMap(),
      'documentation': _documentsEvaluation,
    });

    final operationalDecision = cubit.getOperationalDecision(totalScore);
    final reinspectionDate = cubit.calculateReinspectionDate(totalScore);

    final evaluation = EvaluationReport(
      id: widget.evaluation?.id ?? const Uuid().v4(),
      aerodromeId: _selectedAerodromeId!,
      aerodromeName: _selectedAerodromeName!,
      managerId: _selectedManagerId!,
      managerName: _selectedManagerName!,
      headId: _selectedHeadId!,
      headName: _selectedHeadName!,
      memberIds: _selectedMemberIds,
      memberNames: _selectedMemberNames,
      aircraftId: _selectedAircraftId,
      aircraftName: _selectedAircraftName,
      evaluationDate: _evaluationDateTime, // ← دايمًا عندها قيمة
      totalScore: totalScore,
      operationalDecision: operationalDecision,
      managerSignature: _managerSignature,
      headSignature: _headSignature,
      reinspectionDate: reinspectionDate,
      notes: _notes,
      createdAt: widget.evaluation?.safeCreatedAt, // ← استخدم safe getter
      updatedAt: DateTime.now(),
      runwayEvaluation: _runwayEvaluation,
      taxiwayEvaluation: _taxiwayModel_2.toCompatibilityMap(),
      apronEvaluation: _apronEvaluation.toCompatibilityMap(),
      rffsEvaluation: _rffsModel.toCompatibilityMap(),
      metEvaluation: _metModel.toCompatibilityMap(),
      navaidsEvaluation: _navaidsEvaluation,
      operationalEvaluation: _operationalEvaluation,
      smsEvaluation: _smsModel.toCompatibilityMap(),
      documentsEvaluation: _documentsEvaluation,
    );

    cubit.saveEvaluation(evaluation);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pop(context);
    });
  }
}

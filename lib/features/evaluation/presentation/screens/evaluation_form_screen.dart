import 'dart:math' as math;
import 'dart:typed_data';

import 'package:falcon_system/data/sections/apron_evaluation.dart';
import 'package:falcon_system/data/sections/apron_section_widget.dart';
import 'package:falcon_system/data/sections/met_evaluation.dart';
import 'package:falcon_system/data/sections/met_section_widget.dart';
import 'package:falcon_system/data/sections/navaids_evaluation.dart';
import 'package:falcon_system/data/sections/navaids_section_widget.dart';
import 'package:falcon_system/data/sections/rffs_evaluation.dart';
import 'package:falcon_system/data/sections/rffs_section_widget.dart';
import 'package:falcon_system/data/sections/runway_evaluation.dart';
import 'package:falcon_system/data/sections/runway_section_widget.dart';
import 'package:falcon_system/data/sections/sms_evaluation.dart';
import 'package:falcon_system/data/sections/sms_section_widget.dart';
import '../../../../data/sections/taxiway_evaluation.dart';
import '../../../../data/sections/taxiway_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/utils/date_utils.dart' as app_date_utils;
import '../../../../core/widgets/custom_dropdown.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
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

// ═══════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════
class _DS {
  // Gradients
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF1A3A6B), Color(0xFF0D2E5C)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFAFCFF), Color(0xFFF0F5FF)],
  );

  // Colors
  static const navy = Color(0xFF0A1628);
  static const navyMid = Color(0xFF1A3A6B);
  static const gold = Color(0xFFC8962E);
  static const goldLight = Color(0xFFF0C040);
  static const surface = Color(0xFFF7F9FD);
  static const cardBg = Color(0xFFFFFFFF);
  static const borderColor = Color(0xFFE2EAF8);
  static const textPrimary = Color(0xFF0D1B2E);
  static const textSecondary = Color(0xFF6B7A99);
  static const textHint = Color(0xFFADB8D0);

  // Score Colors
  static const excellent = Color(0xFF00C48C);
  static const good = Color(0xFF4A90D9);
  static const acceptable = Color(0xFFF5A623);
  static const poor = Color(0xFFFF6B6B);
  static const danger = Color(0xFFD63031);

  // Dimensions
  static const radius = 16.0;
  static const radiusLg = 24.0;
  static const radiusSm = 10.0;

  static Color scoreColor(double score) {
    if (score >= 9) return excellent;
    if (score >= 7) return good;
    if (score >= 5) return acceptable;
    if (score >= 3) return poor;
    return danger;
  }

  static String scoreLabel(double score) {
    if (score >= 9) return 'ممتاز';
    if (score >= 7) return 'جيد';
    if (score >= 5) return 'مقبول';
    if (score >= 3) return 'ضعيف';
    return 'خطر';
  }
}

// ═══════════════════════════════════════════════════════════
// STEP META-DATA
// ═══════════════════════════════════════════════════════════
class _StepMeta {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  const _StepMeta(this.title, this.subtitle, this.icon, this.accent);
}

const List<_StepMeta> _steps = [
  _StepMeta(
    'المعلومات الأساسية',
    'بيانات التفتيش والفريق',
    Icons.assignment_outlined,
    Color(0xFF4A90D9),
  ),
  _StepMeta(
    'المدرجات',
    'تقييم حالة وأداء المدرجات',
    Icons.straighten_outlined,
    Color(0xFF00C48C),
  ),
  _StepMeta(
    'ممرات التاكسي',
    'تقييم شبكة ممرات التاكسي',
    Icons.swap_horizontal_circle_outlined,
    Color(0xFF9B59B6),
  ),
  _StepMeta(
    'ساحات الوقوف',
    'تقييم مناطق ركن الطائرات',
    Icons.local_parking_outlined,
    Color(0xFFF39C12),
  ),
  _StepMeta(
    'الإطفاء والإنقاذ',
    'تقييم خدمات الطوارئ',
    Icons.local_fire_department_outlined,
    Color(0xFFE74C3C),
  ),
  _StepMeta(
    'الأرصاد الجوية',
    'تقييم خدمات الطقس',
    Icons.cloud_outlined,
    Color(0xFF1ABC9C),
  ),
  _StepMeta(
    'المساعدات الملاحية',
    'تقييم أنظمة الملاحة',
    Icons.navigation_outlined,
    Color(0xFF3498DB),
  ),
  _StepMeta(
    'العمليات التشغيلية',
    'تقييم برج المراقبة والخدمات',
    Icons.control_point_outlined,
    Color(0xFF8E44AD),
  ),
  _StepMeta(
    'نظام السلامة',
    'تقييم SMS وإدارة المخاطر',
    Icons.security_outlined,
    Color(0xFF27AE60),
  ),
  _StepMeta(
    'الوثائق',
    'تقييم السجلات والتراخيص',
    Icons.folder_outlined,
    Color(0xFF2980B9),
  ),
  _StepMeta(
    'الملخص النهائي',
    'نتائج التقييم الشاملة',
    Icons.analytics_outlined,
    Color(0xFFC8962E),
  ),
];

// ═══════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════
class EvaluationFormScreen extends StatefulWidget {
  final EvaluationReport? evaluation;
  const EvaluationFormScreen({super.key, this.evaluation});

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen>
    with TickerProviderStateMixin {
  // ── Controllers
  late final PageController _pageController;
  late final AnimationController _headerAnim;
  late final AnimationController _cardAnim;
  late final AnimationController _progressAnim;

  // ── State
  int _currentStep = 0;
  bool _isLoading = false;

  // ── Basic Info
  String? _selectedAerodromeId, _selectedAerodromeName;
  String? _selectedManagerId, _selectedManagerName;
  String? _selectedHeadId, _selectedHeadName;
  List<String> _selectedMemberIds = [];
  List<String> _selectedMemberNames = [];
  String? _selectedAircraftId, _selectedAircraftName;
  String? _pendingMemberId;
  DateTime _evaluationDateTime = DateTime.now();
  String? _notes;

  // ── Reference Data
  List<Aerodrome> _aerodromes = [];
  List<AirportManager> _managers = [];
  List<InspectionHead> _heads = [];
  List<InspectionMember> _members = [];
  List<Aircraft> _aircraft = [];

  // ── Signatures
  Uint8List? _managerSignature;
  Uint8List? _headSignature;

  // ── Section Models
  RunwayEvaluation _runwayModel = RunwayEvaluation();
  TaxiwayEvaluation _taxiwayModel = TaxiwayEvaluation();
  ApronEvaluation _apronEvaluation = ApronEvaluation();
  RffsEvaluation _rffsModel = RffsEvaluation();
  MetEvaluation _metModel = MetEvaluation();
  NavaidsEvaluation _navaidsModel = NavaidsEvaluation();
  Map<String, dynamic> _operationalEvaluation = {};
  SmsEvaluation _smsModel = SmsEvaluation();
  Map<String, dynamic> _documentsEvaluation = {};

  // ── Section Items
  final _operationalItems = [
    'برج المراقبة',
    'خدمة الحركة الجوية',
    'إجراءات السلامة',
    'التدريب المستمر',
  ];
  final _documentsItems = [
    'دليل العمليات',
    'شهادات الترخيص',
    'سجلات الصيانة',
    'وثائق التدريب',
  ];

  // ── Completion tracking
  final Set<int> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerAnim.forward();
    _cardAnim.forward();

    _loadReferenceData();
    if (widget.evaluation != null) _populateForm(widget.evaluation!);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerAnim.dispose();
    _cardAnim.dispose();
    _progressAnim.dispose();
    super.dispose();
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
    if (aerodromeState is AerodromeLoaded)
      _aerodromes = aerodromeState.aerodromes.cast<Aerodrome>();
    if (managerState is ManagerLoaded) _managers = managerState.managers;
    if (teamState is TeamLoaded) {
      _heads = teamState.head;
      _members = teamState.members;
    }
    if (aircraftState is AircraftLoaded) _aircraft = aircraftState.aircraft;
  }

  void _populateForm(EvaluationReport e) {
    _selectedAerodromeId = e.aerodromeId;
    _selectedAerodromeName = e.aerodromeName;
    _selectedManagerId = e.managerId;
    _selectedManagerName = e.managerName;
    _selectedHeadId = e.headId;
    _selectedHeadName = e.headName;
    _selectedMemberIds = e.memberIds;
    _selectedMemberNames = e.memberNames;
    _selectedAircraftId = e.aircraftId;
    _selectedAircraftName = e.aircraftName;
    _evaluationDateTime = e.safeEvaluationDate;
    _notes = e.notes;
    _managerSignature = e.managerSignature;
    _headSignature = e.headSignature;
    _runwayModel = RunwayEvaluation.fromCompatibilityMap(e.runwayEvaluation);
    _taxiwayModel = TaxiwayEvaluation.fromCompatibilityMap(e.taxiwayEvaluation);
    _apronEvaluation = ApronEvaluation.fromCompatibilityMap(e.apronEvaluation);
    _rffsModel = RffsEvaluation.fromCompatibilityMap(e.rffsEvaluation);
    _metModel = MetEvaluation.fromCompatibilityMap(e.metEvaluation);
    _navaidsModel = NavaidsEvaluation.fromCompatibilityMap(e.navaidsEvaluation);
    _operationalEvaluation = e.operationalEvaluation;
    _smsModel = SmsEvaluation.fromCompatibilityMap(e.smsEvaluation);
    _documentsEvaluation = e.documentsEvaluation;
  }

  // ── Navigation
  void _goToStep(int step) {
    if (step < 0 || step > 10) return;
    HapticFeedback.selectionClick();
    _completedSteps.add(_currentStep);
    setState(() => _currentStep = step);
    _cardAnim.reset();
    _cardAnim.forward();
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextStep() => _goToStep(_currentStep + 1);
  void _prevStep() => _goToStep(_currentStep - 1);

  // ── Date/Time
  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _evaluationDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(data: _buildPickerTheme(), child: child!),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_evaluationDateTime),
      builder: (ctx, child) => Theme(
        data: _buildPickerTheme(),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _evaluationDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
        DateTime.now().second,
      );
    });
  }

  ThemeData _buildPickerTheme() => ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: _DS.navyMid,
      onPrimary: Colors.white,
      surface: Colors.white,
    ),
    dialogBackgroundColor: Colors.white,
  );

  String _formatDateTimeArabic(DateTime dt) {
    const months = [
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
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final day = days[dt.weekday - 1];
    final month = months[dt.month - 1];
    final period = dt.hour >= 12 ? 'م' : 'ص';
    final h = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    return '$day، ${dt.day} $month ${dt.year}  •  ${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  // ── Submit
  void _submitEvaluation() {
    setState(() => _isLoading = true);
    final cubit = context.read<EvaluationCubit>();
    final allData = {
      'runways': _runwayModel.toCompatibilityMap(),
      'taxiways': _taxiwayModel.toCompatibilityMap(),
      'aprons': _apronEvaluation.toCompatibilityMap(),
      'rescueFire': _rffsModel.toCompatibilityMap(),
      'meteorological': _metModel.toCompatibilityMap(),
      'navigationalAids': _navaidsModel.toCompatibilityMap(),
      'atc': _operationalEvaluation,
      'security': _smsModel.toCompatibilityMap(),
      'documentation': _documentsEvaluation,
    };
    final totalScore = cubit.calculateTotalScore(allData);
    final decision = cubit.getOperationalDecision(totalScore);
    final reinspection = cubit.calculateReinspectionDate(totalScore);

    final report = EvaluationReport(
      id: widget.evaluation?.id ?? const Uuid().v4(),
      aerodromeId: _selectedAerodromeId ?? '',
      aerodromeName: _selectedAerodromeName ?? '',
      managerId: _selectedManagerId ?? '',
      managerName: _selectedManagerName ?? '',
      headId: _selectedHeadId ?? '',
      headName: _selectedHeadName ?? '',
      memberIds: _selectedMemberIds,
      memberNames: _selectedMemberNames,
      aircraftId: _selectedAircraftId,
      aircraftName: _selectedAircraftName,
      evaluationDate: _evaluationDateTime,
      totalScore: totalScore,
      operationalDecision: decision,
      managerSignature: _managerSignature,
      headSignature: _headSignature,
      reinspectionDate: reinspection,
      notes: _notes,
      createdAt: widget.evaluation?.safeCreatedAt,
      updatedAt: DateTime.now(),
      runwayEvaluation: _runwayModel.toCompatibilityMap(),
      taxiwayEvaluation: _taxiwayModel.toCompatibilityMap(),
      apronEvaluation: _apronEvaluation.toCompatibilityMap(),
      rffsEvaluation: _rffsModel.toCompatibilityMap(),
      metEvaluation: _metModel.toCompatibilityMap(),
      navaidsEvaluation: _navaidsModel.toCompatibilityMap(),
      operationalEvaluation: _operationalEvaluation,
      smsEvaluation: _smsModel.toCompatibilityMap(),
      documentsEvaluation: _documentsEvaluation,
    );
    cubit.saveEvaluation(report);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSuccessDialog(totalScore, decision);
    });
  }

  void _showSuccessDialog(double score, String decision) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        score: score,
        decision: decision,
        onClose: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // go back
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _DS.surface,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildStepIndicatorBar(),
                Expanded(child: _buildPageContent()),
                _buildBottomNavBar(),
              ],
            ),
            if (_isLoading) const _LoadingOverlayWidget(),
          ],
        ),
      ),
    );
  }

  // ── Header
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, __) => FadeTransition(
        opacity: _headerAnim,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _headerAnim,
                  curve: Curves.easeOutCubic,
                ),
              ),
          child: Container(
            decoration: const BoxDecoration(gradient: _DS.headerGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _buildStepCounter(),
                        const SizedBox(width: 12),
                        _CircleIconButton(
                          icon: Icons.more_vert_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title area
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _steps[_currentStep].accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _steps[_currentStep].accent.withOpacity(
                                0.5,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _steps[_currentStep].icon,
                            color: _steps[_currentStep].accent,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _steps[_currentStep].title,
                                  key: ValueKey(_currentStep),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _steps[_currentStep].subtitle,
                                  key: ValueKey('sub$_currentStep'),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.65),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Progress bar
                    _buildProgressBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        'الخطوة ${_currentStep + 1} من ${_steps.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _steps.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(_completedSteps.length / _steps.length * 100).toInt()}% مكتمل',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
            Text(
              '${_completedSteps.length}/${_steps.length} خطوات',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(_steps[_currentStep].accent),
          ),
        ),
      ],
    );
  }

  // ── Step Indicator Bar (scrollable dots)
  Widget _buildStepIndicatorBar() {
    return Container(
      height: 72,
      color: _DS.navy,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _steps.length,
        itemBuilder: (_, i) => _buildStepDot(i),
      ),
    );
  }

  Widget _buildStepDot(int index) {
    final isActive = index == _currentStep;
    final isDone = _completedSteps.contains(index);
    final accent = _steps[index].accent;
    return GestureDetector(
      onTap: () => _goToStep(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 8),
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 0),
        width: isActive ? 90 : 44,
        decoration: BoxDecoration(
          color: isActive
              ? accent
              : isDone
              ? accent.withOpacity(0.2)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isActive
                ? accent
                : isDone
                ? accent.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: isActive
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_steps[index].icon, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: isDone
                    ? Icon(Icons.check_rounded, color: accent, size: 18)
                    : Icon(
                        _steps[index].icon,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
              ),
      ),
    );
  }

  // ── Page Content
  Widget _buildPageContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildPage(_buildBasicInfoContent()),
        _buildPage(
          RunwaySectionWidget(
            evaluation: _runwayModel,
            onChanged: (u) => setState(() => _runwayModel = u),
          ),
        ),
        _buildPage(
          TaxiwaySectionWidget(
            evaluation: _taxiwayModel,
            onChanged: (u) => setState(() => _taxiwayModel = u),
          ),
        ),
        _buildPage(
          ApronSectionWidget(
            evaluation: _apronEvaluation,
            onChanged: (u) => setState(() => _apronEvaluation = u),
          ),
        ),
        _buildPage(
          RffsSectionWidget(
            evaluation: _rffsModel,
            onChanged: (u) => setState(() => _rffsModel = u),
          ),
        ),
        _buildPage(
          MetSectionWidget(
            evaluation: _metModel,
            onChanged: (u) => setState(() => _metModel = u),
          ),
        ),
        _buildPage(
          NavaidsSection(
            evaluation: _navaidsModel,
            onChanged: (u) => setState(() => _navaidsModel = u),
          ),
        ),
        _buildPage(
          _buildEvaluationSection(
            'العمليات التشغيلية',
            _operationalItems,
            _operationalEvaluation,
            (k, v) => setState(() => _operationalEvaluation[k] = v),
            Icons.control_point_outlined,
            const Color(0xFF8E44AD),
          ),
        ),
        _buildPage(
          SmsSectionWidget(
            evaluation: _smsModel,
            onChanged: (u) => setState(() => _smsModel = u),
          ),
        ),
        _buildPage(
          _buildEvaluationSection(
            'الوثائق',
            _documentsItems,
            _documentsEvaluation,
            (k, v) => setState(() => _documentsEvaluation[k] = v),
            Icons.folder_outlined,
            const Color(0xFF2980B9),
          ),
        ),
        _buildPage(_buildSummaryContent()),
      ],
    );
  }

  Widget _buildPage(Widget child) {
    return AnimatedBuilder(
      animation: _cardAnim,
      builder: (_, __) => FadeTransition(
        opacity: CurvedAnimation(parent: _cardAnim, curve: Curves.easeIn),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic),
              ),
          child: child is SingleChildScrollView
              ? child
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: child,
                ),
        ),
      ),
    );
  }

  // ── Bottom Nav Bar
  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              _OutlineNavButton(
                label: 'السابق',
                icon: Icons.arrow_forward_ios_rounded,
                onTap: _prevStep,
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: _currentStep < 10
                  ? _PrimaryNavButton(
                      label: 'التالي',
                      icon: Icons.arrow_back_ios_new_rounded,
                      accent: _steps[_currentStep].accent,
                      onTap: _nextStep,
                    )
                  : _PrimaryNavButton(
                      label: 'حفظ التقرير',
                      icon: Icons.save_outlined,
                      accent: _DS.gold,
                      onTap: _submitEvaluation,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STEP 0 — BASIC INFO
  // ══════════════════════════════════════════════════════════
  Widget _buildBasicInfoContent() {
    return MultiBlocListener(
      listeners: [
        BlocListener<AerodromeCubit, AerodromeState>(
          listener: (_, s) {
            if (s is AerodromeLoaded)
              setState(() => _aerodromes = s.aerodromes.cast());
          },
        ),
        BlocListener<ManagerCubit, ManagerState>(
          listener: (_, s) {
            if (s is ManagerLoaded) setState(() => _managers = s.managers);
          },
        ),
        BlocListener<TeamCubit, TeamState>(
          listener: (_, s) {
            if (s is TeamLoaded)
              setState(() {
                _heads = s.head;
                _members = s.members;
              });
          },
        ),
        BlocListener<AircraftCubit, AircraftState>(
          listener: (_, s) {
            if (s is AircraftLoaded) setState(() => _aircraft = s.aircraft);
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            icon: Icons.flight_takeoff_outlined,
            title: 'بيانات المطار والفريق',
            accent: const Color(0xFF4A90D9),
            children: [
              _ProDropdown<String>(
                label: 'المطار',
                icon: Icons.location_on_outlined,
                hint: 'اختر المطار',
                items: _aerodromes
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.arabicName),
                      ),
                    )
                    .toList(),
                value: _selectedAerodromeId,
                onChanged: (v) {
                  if (v == null) return;
                  final s = _aerodromes.firstWhere((a) => a.id == v);
                  setState(() {
                    _selectedAerodromeId = s.id;
                    _selectedAerodromeName = s.arabicName;
                  });
                },
              ),
              const SizedBox(height: 16),
              _ProDropdown<String>(
                label: 'قائد المطار',
                icon: Icons.manage_accounts_outlined,
                hint: 'اختر قائد المطار',
                items: _managers
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.fullName),
                      ),
                    )
                    .toList(),
                value: _selectedManagerId,
                onChanged: (v) {
                  if (v == null) return;
                  final s = _managers.firstWhere((m) => m.id == v);
                  setState(() {
                    _selectedManagerId = s.id;
                    _selectedManagerName = s.fullName;
                  });
                },
              ),
              const SizedBox(height: 16),
              _ProDropdown<String>(
                label: 'رئيس لجنة التفتيش',
                icon: Icons.badge_outlined,
                hint: 'اختر رئيس اللجنة',
                items: _heads
                    .map(
                      (h) => DropdownMenuItem(
                        value: h.id,
                        child: Text(h.fullName),
                      ),
                    )
                    .toList(),
                value: _selectedHeadId,
                onChanged: (v) {
                  if (v == null) return;
                  final s = _heads.firstWhere((h) => h.id == v);
                  setState(() {
                    _selectedHeadId = s.id;
                    _selectedHeadName = s.fullName;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Members section
          _SectionCard(
            icon: Icons.group_outlined,
            title: 'أعضاء لجنة التفتيش',
            accent: const Color(0xFF9B59B6),
            children: [
              _ProDropdown<String>(
                label: 'إضافة عضو',
                icon: Icons.person_add_outlined,
                hint: 'اختر عضواً وأضفه',
                items: _members
                    .where((m) => !_selectedMemberIds.contains(m.id))
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.fullName),
                      ),
                    )
                    .toList(),
                value: _pendingMemberId,
                onChanged: (v) {
                  if (v == null) return;
                  final s = _members.firstWhere((m) => m.id == v);
                  setState(() {
                    _pendingMemberId = null;
                    _selectedMemberIds = [..._selectedMemberIds, s.id];
                    _selectedMemberNames = [
                      ..._selectedMemberNames,
                      s.fullName,
                    ];
                  });
                },
              ),
              if (_selectedMemberNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._selectedMemberNames.asMap().entries.map(
                  (e) => _MemberChip(
                    name: e.value,
                    index: e.key + 1,
                    onRemove: () => setState(() {
                      _selectedMemberNames.removeAt(e.key);
                      _selectedMemberIds.removeAt(e.key);
                    }),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Date/Time
          _SectionCard(
            icon: Icons.calendar_today_outlined,
            title: 'تاريخ ووقت التقييم',
            accent: const Color(0xFF1ABC9C),
            children: [
              GestureDetector(
                onTap: _selectDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FBF7),
                    borderRadius: BorderRadius.circular(_DS.radiusSm),
                    border: Border.all(
                      color: const Color(0xFF1ABC9C).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1ABC9C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.event_outlined,
                          color: Color(0xFF1ABC9C),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'انقر لتغيير التاريخ والوقت',
                              style: TextStyle(
                                color: _DS.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTimeArabic(_evaluationDateTime),
                              style: const TextStyle(
                                color: _DS.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: _DS.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          _SectionCard(
            icon: Icons.notes_outlined,
            title: 'ملاحظات التقييم',
            accent: _DS.gold,
            children: [
              TextField(
                maxLines: 4,
                controller: TextEditingController(text: _notes),
                onChanged: (v) => _notes = v,
                style: const TextStyle(color: _DS.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'أدخل أي ملاحظات أو تعليقات إضافية...',
                  hintStyle: const TextStyle(color: _DS.textHint, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFFFFBF0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_DS.radiusSm),
                    borderSide: BorderSide(
                      color: _DS.gold.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_DS.radiusSm),
                    borderSide: BorderSide(
                      color: _DS.gold.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_DS.radiusSm),
                    borderSide: const BorderSide(color: _DS.gold, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EVALUATION SECTION (Operational & Documents)
  // ══════════════════════════════════════════════════════════
  Widget _buildEvaluationSection(
    String title,
    List<String> items,
    Map<String, dynamic> evaluation,
    Function(String, Map<String, dynamic>) onChanged,
    IconData icon,
    Color accent,
  ) {
    // Compute section average
    double avg = 0;
    if (items.isNotEmpty) {
      for (final item in items) {
        final d = evaluation[item] as Map<String, dynamic>?;
        avg += (d?['score'] as num?)?.toDouble() ?? 5.0;
      }
      avg /= items.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Score Summary Card
        _ScoreSummaryCard(score: avg, accent: accent),
        const SizedBox(height: 16),

        _SectionCard(
          icon: icon,
          title: title,
          accent: accent,
          children: items.map((item) {
            final d = evaluation[item] as Map<String, dynamic>?;
            final score = (d?['score'] as num?)?.toDouble() ?? 5.0;
            final note = d?['note'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _ProEvaluationSlider(
                label: item,
                value: score,
                note: note,
                accent: accent,
                onChanged: (val) =>
                    onChanged(item, {'score': val, 'note': note}),
                onNoteChanged: (n) =>
                    onChanged(item, {'score': score, 'note': n}),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // STEP 10 — SUMMARY
  // ══════════════════════════════════════════════════════════
  Widget _buildSummaryContent() {
    final cubit = context.read<EvaluationCubit>();
    final allData = {
      'runways': _runwayModel.toCompatibilityMap(),
      'taxiways': _taxiwayModel.toCompatibilityMap(),
      'aprons': _apronEvaluation.toCompatibilityMap(),
      'rescueFire': _rffsModel.toCompatibilityMap(),
      'meteorological': _metModel.toCompatibilityMap(),
      'navigationalAids': _navaidsModel.toCompatibilityMap(),
      'atc': _operationalEvaluation,
      'security': _smsModel.toCompatibilityMap(),
      'documentation': _documentsEvaluation,
    };
    final totalScore = cubit.calculateTotalScore(allData);
    final decision = cubit.getOperationalDecision(totalScore);
    final reinspection = cubit.calculateReinspectionDate(totalScore);
    final scoreColor = _DS.scoreColor(totalScore / 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big Score Card
        _AnimatedScoreCard(
          totalScore: totalScore,
          decision: decision,
          scoreColor: scoreColor,
        ),
        const SizedBox(height: 16),

        // Info Grid
        _SectionCard(
          icon: Icons.info_outline_rounded,
          title: 'تفاصيل التقرير',
          accent: _DS.gold,
          children: [
            _InfoRow(
              icon: Icons.flight_takeoff_outlined,
              label: 'المطار',
              value: _selectedAerodromeName ?? '—',
            ),
            _InfoRow(
              icon: Icons.manage_accounts_outlined,
              label: 'قائد المطار',
              value: _selectedManagerName ?? '—',
            ),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'رئيس اللجنة',
              value: _selectedHeadName ?? '—',
            ),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ التقييم',
              value: _formatDateTimeArabic(_evaluationDateTime),
            ),
            _InfoRow(
              icon: Icons.event_repeat_outlined,
              label: 'إعادة الفحص',
              value: app_date_utils.DateUtils.formatToArabic(reinspection),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Section Scores
        _SectionCard(
          icon: Icons.bar_chart_outlined,
          title: 'أداء كل قسم',
          accent: const Color(0xFF4A90D9),
          children: [
            _SectionScoreRow(
              label: 'المدرجات',
              icon: Icons.straighten_outlined,
              color: const Color(0xFF00C48C),
            ),
            _SectionScoreRow(
              label: 'ممرات التاكسي',
              icon: Icons.swap_horizontal_circle_outlined,
              color: const Color(0xFF9B59B6),
            ),
            _SectionScoreRow(
              label: 'ساحات الوقوف',
              icon: Icons.local_parking_outlined,
              color: const Color(0xFFF39C12),
            ),
            _SectionScoreRow(
              label: 'الإطفاء والإنقاذ',
              icon: Icons.local_fire_department_outlined,
              color: const Color(0xFFE74C3C),
            ),
            _SectionScoreRow(
              label: 'الأرصاد الجوية',
              icon: Icons.cloud_outlined,
              color: const Color(0xFF1ABC9C),
            ),
            _SectionScoreRow(
              label: 'المساعدات الملاحية',
              icon: Icons.navigation_outlined,
              color: const Color(0xFF3498DB),
            ),
            _SectionScoreRow(
              label: 'العمليات التشغيلية',
              icon: Icons.control_point_outlined,
              color: const Color(0xFF8E44AD),
            ),
            _SectionScoreRow(
              label: 'نظام السلامة',
              icon: Icons.security_outlined,
              color: const Color(0xFF27AE60),
            ),
            _SectionScoreRow(
              label: 'الوثائق',
              icon: Icons.folder_outlined,
              color: const Color(0xFF2980B9),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Warning if incomplete
        if (_completedSteps.length < 10)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(_DS.radiusSm),
              border: Border.all(
                color: const Color(0xFFFFC107).withOpacity(0.5),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF39C12),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'بعض الأقسام لم تكتمل بعد. يُنصح بمراجعتها قبل الحفظ.',
                    style: TextStyle(color: Color(0xFF856404), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════

/// Professional Section Card
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.accent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_DS.radius),
        border: Border.all(color: _DS.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_DS.radius),
              ),
              border: Border(
                bottom: BorderSide(color: accent.withOpacity(0.15)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Professional Dropdown
class _ProDropdown<T> extends StatelessWidget {
  final String label, hint;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _ProDropdown({
    required this.label,
    required this.icon,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _DS.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: _DS.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(
            hint,
            style: const TextStyle(color: _DS.textHint, fontSize: 13),
          ),
          style: const TextStyle(
            color: _DS.textPrimary,
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _DS.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusSm),
              borderSide: const BorderSide(color: _DS.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusSm),
              borderSide: const BorderSide(color: _DS.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.radiusSm),
              borderSide: const BorderSide(color: _DS.navyMid, width: 2),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _DS.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Professional Animated Evaluation Slider
class _ProEvaluationSlider extends StatefulWidget {
  final String label, note;
  final double value;
  final Color accent;
  final ValueChanged<double> onChanged;
  final ValueChanged<String> onNoteChanged;

  const _ProEvaluationSlider({
    required this.label,
    required this.value,
    required this.note,
    required this.accent,
    required this.onChanged,
    required this.onNoteChanged,
  });

  @override
  State<_ProEvaluationSlider> createState() => _ProEvaluationSliderState();
}

class _ProEvaluationSliderState extends State<_ProEvaluationSlider>
    with SingleTickerProviderStateMixin {
  late double _val;
  late AnimationController _pulse;
  bool _showNote = false;

  @override
  void initState() {
    super.initState();
    _val = widget.value;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _color => _DS.scoreColor(_val);
  String get _label => _DS.scoreLabel(_val);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(_DS.radiusSm),
        border: Border.all(color: _color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Score Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: _DS.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _val.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• $_label',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Slider Track
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              thumbShape: _CustomThumbShape(color: _color),
              activeTrackColor: _color,
              inactiveTrackColor: _color.withOpacity(0.15),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
              overlayColor: _color.withOpacity(0.15),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: _val,
              min: 0,
              max: 10,
              divisions: 20,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _val = v);
                widget.onChanged(v);
              },
            ),
          ),

          // Scale labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => Text(
                  '${i * 2}',
                  style: TextStyle(color: _DS.textHint, fontSize: 10),
                ),
              ),
            ),
          ),

          // Progress bar visualization
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _val / 10,
              minHeight: 4,
              backgroundColor: _color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),

          // Note toggle
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showNote = !_showNote),
            child: Row(
              children: [
                Icon(
                  _showNote
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _DS.textHint,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _showNote ? 'إخفاء الملاحظة' : 'إضافة ملاحظة',
                  style: const TextStyle(
                    color: _DS.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          if (_showNote) ...[
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: widget.note),
              onChanged: widget.onNoteChanged,
              maxLines: 2,
              style: const TextStyle(fontSize: 12, color: _DS.textPrimary),
              decoration: InputDecoration(
                hintText: 'ملاحظة حول هذا البند...',
                hintStyle: const TextStyle(color: _DS.textHint, fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _color.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _color.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: _color, width: 1.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom Thumb Shape for Slider
class _CustomThumbShape extends SliderComponentShape {
  final Color color;
  const _CustomThumbShape({required this.color});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(
    PaintingContext ctx,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = ctx.canvas;
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      center,
      4,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }
}

/// Score Summary Card
class _ScoreSummaryCard extends StatelessWidget {
  final double score;
  final Color accent;
  const _ScoreSummaryCard({required this.score, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.9), accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_DS.radius),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'متوسط القسم',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                _DS.scoreLabel(score),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated Total Score Card
class _AnimatedScoreCard extends StatefulWidget {
  final double totalScore;
  final String decision;
  final Color scoreColor;
  const _AnimatedScoreCard({
    required this.totalScore,
    required this.decision,
    required this.scoreColor,
  });

  @override
  State<_AnimatedScoreCard> createState() => _AnimatedScoreCardState();
}

class _AnimatedScoreCardState extends State<_AnimatedScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnim = Tween<double>(
      begin: 0,
      end: widget.totalScore,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_DS.navy, _DS.navyMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(_DS.radiusLg),
          boxShadow: [
            BoxShadow(
              color: _DS.navy.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Circular score indicator
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CustomPaint(
                      painter: _CircularScorePainter(
                        progress: _scoreAnim.value / 100,
                        color: widget.scoreColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_scoreAnim.value.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: widget.scoreColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'الدرجة الكلية',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: widget.scoreColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: widget.scoreColor.withOpacity(0.5)),
              ),
              child: Text(
                widget.decision,
                style: TextStyle(
                  color: widget.scoreColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular Score Painter
class _CircularScorePainter extends CustomPainter {
  final double progress;
  final Color color;
  _CircularScorePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularScorePainter old) => old.progress != progress;
}

/// Member Chip
class _MemberChip extends StatelessWidget {
  final String name;
  final int index;
  final VoidCallback onRemove;
  const _MemberChip({
    required this.name,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF9B59B6).withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF9B59B6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _DS.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: _DS.danger,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Row for summary
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _DS.gold),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: _DS.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _DS.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Score Row (placeholder — replace with real data)
class _SectionScoreRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionScoreRow({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _DS.textSecondary, fontSize: 12),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '—',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Circle icon button for appbar
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

/// Primary Nav Button
class _PrimaryNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  const _PrimaryNavButton({
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [accent, accent.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Outline Nav Button
class _OutlineNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineNavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _DS.borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _DS.textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: _DS.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading Overlay
class _LoadingOverlayWidget extends StatelessWidget {
  const _LoadingOverlayWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  color: _DS.navyMid,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'جاري حفظ التقرير...',
                style: TextStyle(
                  color: _DS.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'يرجى الانتظار',
                style: TextStyle(color: _DS.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success Dialog
class _SuccessDialog extends StatefulWidget {
  final double score;
  final String decision;
  final VoidCallback onClose;
  const _SuccessDialog({
    required this.score,
    required this.decision,
    required this.onClose,
  });

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _DS.scoreColor(widget.score / 10);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: color,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تم حفظ التقرير بنجاح',
                    style: TextStyle(
                      color: _DS.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الدرجة النهائية: ${widget.score.toStringAsFixed(1)}%  •  ${widget.decision}',
                    style: const TextStyle(
                      color: _DS.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _DS.navyMid,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

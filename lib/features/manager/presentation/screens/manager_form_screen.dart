/*import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/loading_overlay.dart';
import 'package:falcon_system/core/widgets/section_header.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/features/manager/presentation/cubit/manager_cubit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
                    subtitle: 'بيانات قائد المطار',
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
                      if (_signature != null)
                        SignatureDisplay(
                          signatureData: _signature,
                          onClear: () => setState(() => _signature = null),
                        )
                      else
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
                      if (_officialStamp != null)
                        SignatureDisplay(
                          signatureData: _officialStamp,
                          onClear: () => setState(() => _officialStamp = null),
                        )
                      else
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
}*/

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class ManagerFormScreen extends StatefulWidget {
  final AirportManager? manager;

  const ManagerFormScreen({super.key, this.manager});

  @override
  State<ManagerFormScreen> createState() => _ManagerFormScreenState();
}

class _ManagerFormScreenState extends State<ManagerFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _employeeNumberController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();

  // Data
  DateTime? _appointmentDate;
  Uint8List? _signature;
  List<String> _phoneNumbers = [];
  String? _cvPath;
  bool _nationalIdObscured = true;
  bool _isSaving = false;
  bool _isUploadingCV = false;
  double _uploadProgress = 0.0;

  // Animation Controllers
  late final AnimationController _headerAnimCtrl;
  late final AnimationController _fieldsAnimCtrl;
  late final AnimationController _saveAnimCtrl;

  late final Animation<double> _headerFadeAnim;
  late final Animation<Offset> _headerSlideAnim;
  late final List<Animation<Offset>> _fieldSlideAnims;
  late final Animation<double> _savePulseAnim;

  static const int _sectionCount = 5;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.manager != null) _loadManagerData();
  }

  void _setupAnimations() {
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fieldsAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _saveAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut));

    // staggered animations per section
    _fieldSlideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.15;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.4, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _fieldsAnimCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _savePulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _saveAnimCtrl, curve: Curves.easeInOut));

    _headerAnimCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _fieldsAnimCtrl.forward(),
    );
  }

  void _loadManagerData() {
    final m = widget.manager!;
    _fullNameController.text = m.fullName;
    _employeeNumberController.text = m.employeeNumber;
    _nationalIdController.text = m.nationalId ?? '';
    _notesController.text = m.notes ?? '';
    _appointmentDate = m.appointmentDate;
    _signature = m.signature;
    _phoneNumbers = List.from(m.phoneNumbers);
    _cvPath = m.cvPath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _employeeNumberController.dispose();
    _nationalIdController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    _headerAnimCtrl.dispose();
    _fieldsAnimCtrl.dispose();
    _saveAnimCtrl.dispose();
    super.dispose();
  }

  // ── Date Picker ──────────────────────────────────────────────────────────

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _appointmentDate = picked);
  }

  // ── CV Picker ─────────────────────────────────────────────────────────────

  Future<void> _pickCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: kIsWeb, // Required for Web
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        setState(() {
          _isUploadingCV = true;
          _uploadProgress = 0.0;
          _cvPath = null;
        });
        
        // Simulate upload progress
        for (int i = 1; i <= 100; i += 4) {
          await Future.delayed(const Duration(milliseconds: 30));
          if (mounted) setState(() => _uploadProgress = i / 100.0);
        }

        if (kIsWeb) {
          // On Web, we cannot use dart:io or local file system
          // We will just use the file name as a mock path for the UI
          if (mounted) {
            setState(() {
              _isUploadingCV = false;
              _uploadProgress = 1.0;
              _cvPath = file.name;
            });
          }
        } else {
          // Mobile/Desktop logic
          final originalPath = file.path;
          if (originalPath != null) {
            final appDir = await getApplicationDocumentsDirectory();
            final cvDir = Directory(p.join(appDir.path, 'cvs'));
            if (!await cvDir.exists()) {
              await cvDir.create(recursive: true);
            }
            
            final fileName = p.basename(originalPath);
            final savedPath = p.join(cvDir.path, '_');
            
            await File(originalPath).copy(savedPath);
            
            if (mounted) {
              setState(() {
                _isUploadingCV = false;
                _uploadProgress = 1.0;
                _cvPath = savedPath;
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingCV = false;
        });
      }
    }
  }

  // ── Phone Numbers ─────────────────────────────────────────────────────────

  void _addPhone() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    if (_phoneNumbers.contains(phone)) {
      _showSnack('الرقم مضاف بالفعل', AppColors.danger);
      return;
    }
    setState(() {
      _phoneNumbers.add(phone);
      _phoneController.clear();
    });
  }

  void _removePhone(int index) {
    setState(() => _phoneNumbers.removeAt(index));
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  void _saveManager() {
    if (!_formKey.currentState!.validate()) return;
    if (_appointmentDate == null) {
      _showSnack('يرجى اختيار تاريخ التعيين', AppColors.danger);
      return;
    }
    if (_phoneNumbers.isEmpty) {
      _showSnack('يرجى إضافة رقم هاتف واحد على الأقل', AppColors.danger);
      return;
    }

    setState(() => _isSaving = true);

    final manager = AirportManager(
      id: widget.manager?.id ?? '',
      fullName: _fullNameController.text.trim(),
      employeeNumber: _employeeNumberController.text.trim(),
      nationalId: _nationalIdController.text.trim().isEmpty
          ? null
          : _nationalIdController.text.trim(),
      appointmentDate: _appointmentDate!,
      signature: _signature,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      phoneNumbers: List.from(_phoneNumbers),
      cvPath: _cvPath,
      createdAt: widget.manager?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.manager == null) {
      context.read<ManagerCubit>().addManager(manager);
    } else {
      context.read<ManagerCubit>().updateManager(manager);
    }

    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isNew = widget.manager == null;

    return BlocListener<ManagerCubit, ManagerState>(
      listener: (context, state) {
        if (state is ManagerError) {
          _showSnack(state.message, AppColors.danger);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(isNew),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      _buildSection(0, _buildPersonalSection()),
                      const SizedBox(height: 16),
                      _buildSection(1, _buildContactSection()),
                      const SizedBox(height: 16),
                      _buildSection(2, _buildDateSection()),
                      const SizedBox(height: 16),
                      _buildSection(3, _buildDocumentsSection()),
                      const SizedBox(height: 16),
                      _buildSection(4, _buildNotesSection()),
                      const SizedBox(height: 32),
                      _buildSaveButton(isNew),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sliver AppBar ─────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(bool isNew) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withBlue(
                  (AppColors.primary.blue + 40).clamp(0, 255),
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SlideTransition(
                position: _headerSlideAnim,
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_pin,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isNew ? 'قائد جديد' : 'تعديل بيانات القائد',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                isNew
                                    ? 'إضافة قائد مطار جديد للنظام'
                                    : widget.manager?.fullName ?? '',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Wrapper ───────────────────────────────────────────────────────

  Widget _buildSection(int index, Widget child) {
    return SlideTransition(position: _fieldSlideAnims[index], child: child);
  }

  // ── Card Container ────────────────────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }

  // ── Personal Section ──────────────────────────────────────────────────────

  Widget _buildPersonalSection() {
    return _card(
      title: 'البيانات الشخصية',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          CustomTextField(
            label: AppStrings.fullName,
            hint: 'أدخل الاسم الكامل للقائد',
            controller: _fullNameController,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'يرجى إدخال الاسم الكامل';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: AppStrings.employeeNumber,
            hint: 'الرقم الوظيفي',
            controller: _employeeNumberController,
            isRequired: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'يرجى إدخال الرقم الوظيفي';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // National ID field
          _buildNationalIdField(),
        ],
      ),
    );
  }

  Widget _buildNationalIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'الرقم القومي',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nationalIdController,
          obscureText: _nationalIdObscured,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ],
          style: TextStyle(
            fontFamily: 'Cairo',
            letterSpacing: _nationalIdObscured ? 4 : 2,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'يرجى إدخال الرقم القومي';
            }
            if (v.trim().length != 14) {
              return 'الرقم القومي يجب أن يكون 14 رقمًا';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: '••••••••••••••',
            prefixIcon: const Icon(
              Icons.credit_card_outlined,
              color: AppColors.primary,
            ),
            suffixIcon: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  _nationalIdObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  key: ValueKey(_nationalIdObscured),
                  color: AppColors.textSecondary,
                ),
              ),
              onPressed: () =>
                  setState(() => _nationalIdObscured = !_nationalIdObscured),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FD),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              'الرقم القومي محمي ومشفّر',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Contact Section ───────────────────────────────────────────────────────

  Widget _buildContactSection() {
    return _card(
      title: 'أرقام التواصل',
      icon: Icons.phone_outlined,
      accentColor: const Color(0xFF2ECC71),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add phone row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontFamily: 'Cairo'),
                  decoration: InputDecoration(
                    hintText: 'أدخل رقم الهاتف',
                    hintStyle: const TextStyle(fontFamily: 'Cairo'),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xFF2ECC71),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FD),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2ECC71),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onFieldSubmitted: (_) => _addPhone(),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _addPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add, size: 22),
                ),
              ),
            ],
          ),
          if (_phoneNumbers.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(
              _phoneNumbers.length,
              (i) => TweenAnimationBuilder<double>(
                key: ValueKey(_phoneNumbers[i]),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 16,
                        color: Color(0xFF2ECC71),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _phoneNumbers[i],
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removePhone(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_disabled,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'لم يتم إضافة أرقام بعد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Date Section ──────────────────────────────────────────────────────────

  Widget _buildDateSection() {
    return _card(
      title: 'تاريخ التعيين',
      icon: Icons.calendar_month_outlined,
      accentColor: const Color(0xFFE67E22),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _appointmentDate != null
                ? const Color(0xFFE67E22).withOpacity(0.08)
                : const Color(0xFFF8F9FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _appointmentDate != null
                  ? const Color(0xFFE67E22).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFE67E22),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ التعيين',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _appointmentDate == null
                          ? 'اضغط لاختيار التاريخ'
                          : '${_appointmentDate!.day}  /  ${_appointmentDate!.month}  /  ${_appointmentDate!.year}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _appointmentDate == null
                            ? Colors.grey.shade400
                            : const Color(0xFFE67E22),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _appointmentDate != null
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF2ECC71),
                        size: 22,
                        key: ValueKey('checked'),
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16,
                        key: const ValueKey('arrow'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Documents Section ─────────────────────────────────────────────────────

  Widget _buildDocumentsSection() {
    return _card(
      title: 'المستندات والتوقيع',
      icon: Icons.description_outlined,
      accentColor: const Color(0xFF9B59B6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CV Upload
          Text(
            'السيرة الذاتية (CV)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_isUploadingCV)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'جاري رفع السيرة الذاتية...',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9B59B6),
                        ),
                      ),
                      Text(
                        '%${(_uploadProgress * 100).toInt()}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9B59B6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: const Color(0xFF9B59B6).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(const Color(0xFF9B59B6)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
            onTap: _pickCV,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cvPath != null
                    ? const Color(0xFF9B59B6).withOpacity(0.07)
                    : const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _cvPath != null
                      ? const Color(0xFF9B59B6).withOpacity(0.4)
                      : Colors.grey.withOpacity(0.2),
                  width: _cvPath != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B59B6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _cvPath != null
                          ? Icons.description
                          : Icons.upload_file_outlined,
                      color: const Color(0xFF9B59B6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _cvPath != null
                              ? 'تم رفع الملف'
                              : 'رفع السيرة الذاتية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _cvPath != null
                                ? const Color(0xFF9B59B6)
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (_cvPath != null)
                          Text(
                            p.basename(_cvPath!),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'PDF, DOC, DOCX مسموح بها',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_cvPath != null)
                    GestureDetector(
                      onTap: () => setState(() => _cvPath = null),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.danger,
                        size: 18,
                      ),
                    )
                  else
                    Icon(
                      Icons.upload_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Signature (single)
          Text(
            'التوقيع الرسمي',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_signature != null)
            SignatureDisplay(
              signatureData: _signature,
              onClear: () => setState(() => _signature = null),
            )
          else
            SignaturePad(
              onSignatureChanged: (sig) => setState(() => _signature = sig),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                'ارسم توقيعك داخل المربع أعلاه',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Notes Section ─────────────────────────────────────────────────────────

  Widget _buildNotesSection() {
    return _card(
      title: 'ملاحظات إضافية',
      icon: Icons.note_alt_outlined,
      accentColor: const Color(0xFF1ABC9C),
      child: CustomTextField(
        label: 'ملاحظات',
        hint: 'أدخل أي ملاحظات إضافية (اختياري)',
        controller: _notesController,
        maxLines: 3,
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton(bool isNew) {
    return ScaleTransition(
      scale: _savePulseAnim,
      child: SizedBox(
        width: 500,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveManager,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: AppColors.primary.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNew ? Icons.person_add : Icons.save_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isNew ? 'إضافة القائد' : 'حفظ التعديلات',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

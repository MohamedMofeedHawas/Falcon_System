import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/features/team/presentation/cubit/team_cubit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class HeadFormScreen extends StatefulWidget {
  final InspectionHead? head;
  const HeadFormScreen({super.key, this.head});

  @override
  State<HeadFormScreen> createState() => _HeadFormScreenState();
}

class _HeadFormScreenState extends State<HeadFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _rankController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  List<String> _phoneNumbers = [];
  String? _cvPath;

  Uint8List? _signature;
  bool _isSaving = false;
  bool _isUploadingCV = false;
  double _uploadProgress = 0.0;

  // ── Animations ─────────────────────────────────────────────────────────
  late final AnimationController _headerAnimCtrl;
  late final AnimationController _fieldsAnimCtrl;
  late final AnimationController _savePulseCtrl;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final List<Animation<Offset>> _sectionSlides;
  late final Animation<double> _savePulse;

  static const int _sectionCount = 5;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.head != null) _loadData();
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
    _savePulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _headerFade = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut));

    _sectionSlides = List.generate(_sectionCount, (i) {
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

    _savePulse = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _savePulseCtrl, curve: Curves.easeInOut));

    _headerAnimCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 200),
      () => _fieldsAnimCtrl.forward(),
    );
  }

  void _loadData() {
    final h = widget.head!;
    _fullNameController.text = h.fullName;
    _specializationController.text = h.specialization;
    _rankController.text = h.rank ?? '';
    _notesController.text = h.notes ?? '';
    _phoneNumbers = List.from(h.phoneNumbers);
    _cvPath = h.cvPath;
    _signature = h.signature;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _specializationController.dispose();
    _rankController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    _headerAnimCtrl.dispose();
    _fieldsAnimCtrl.dispose();
    _savePulseCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneNumbers.isEmpty) {
      _showSnack('يرجى إضافة رقم هاتف واحد على الأقل', AppColors.danger);
      return;
    }

    setState(() => _isSaving = true);

    final head = InspectionHead(
      id: widget.head?.id ?? '',
      fullName: _fullNameController.text.trim(),
      specialization: _specializationController.text.trim(),
      rank: _rankController.text.trim().isEmpty
          ? null
          : _rankController.text.trim(),
      signature: _signature,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      phoneNumbers: List.from(_phoneNumbers),
      cvPath: _cvPath,
      createdAt: widget.head?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.head == null) {
      context.read<TeamCubit>().addHead(head);
    } else {
      context.read<TeamCubit>().updateHead(head);
    }

    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

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

  // ── Accent color for head screens ─────────────────────────────────────
  static const Color _accent = Color(0xFF8E44AD); // purple

  @override
  Widget build(BuildContext context) {
    final isNew = widget.head == null;

    return BlocListener<TeamCubit, TeamState>(
      listener: (context, state) {
        if (state is TeamError) _showSnack(state.message, AppColors.danger);
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
                      _section(0, _buildPersonalCard()),
                      const SizedBox(height: 16),
                      _section(1, _buildRankCard()),
                      const SizedBox(height: 16),
                      _section(2, _buildContactSection()),
                      const SizedBox(height: 16),
                      _section(3, _buildDocumentsSection()),
                      const SizedBox(height: 16),
                      _section(4, _buildNotesCard()),
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

  // ── Sliver AppBar ──────────────────────────────────────────────────────

  Widget _buildSliverAppBar(bool isNew) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: _accent,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accent, const Color(0xFF6C3483)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _headerFade,
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
                                isNew ? 'رئيس لجنة جديد' : 'تعديل رئيس اللجنة',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                isNew
                                    ? 'إضافة رئيس لجنة التفتيش'
                                    : widget.head?.fullName ?? '',
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

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _section(int i, Widget child) =>
      SlideTransition(position: _sectionSlides[i], child: child);

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accent,
  }) {
    final c = accent ?? _accent;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: c.withOpacity(0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: c, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: c,
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

  // ── Cards ──────────────────────────────────────────────────────────────

  Widget _buildPersonalCard() => _card(
    title: 'البيانات الشخصية',
    icon: Icons.badge_outlined,
    child: Column(
      children: [
        CustomTextField(
          label: AppStrings.fullName,
          hint: 'أدخل الاسم الكامل',
          controller: _fullNameController,
          isRequired: true,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'يرجى إدخال الاسم الكامل'
              : null,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'التخصص',
          hint: 'أدخل التخصص',
          controller: _specializationController,
          isRequired: true,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'يرجى إدخال التخصص' : null,
        ),
      ],
    ),
  );

  Widget _buildRankCard() => _card(
    title: 'الرتبة الوظيفية',
    icon: Icons.military_tech_outlined,
    accent: const Color(0xFF2980B9),
    child: CustomTextField(
      label: AppStrings.rank,
      hint: 'أدخل الرتبة (اختياري)',
      controller: _rankController,
    ),
  );



  

  Widget _buildContactSection() {
    return _card(
      title: 'أرقام التواصل',
      icon: Icons.phone_outlined,
      accent: const Color(0xFF2ECC71),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  Widget _buildDocumentsSection() {
    return _card(
      title: 'المستندات والتوقيع',
      icon: Icons.description_outlined,
      accent: const Color(0xFF9B59B6),
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

          // Signature
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

  Widget _buildNotesCard() => _card(
    title: 'ملاحظات إضافية',
    icon: Icons.note_alt_outlined,
    accent: const Color(0xFF1ABC9C),
    child: CustomTextField(
      label: 'ملاحظات',
      hint: 'أي ملاحظات إضافية (اختياري)',
      controller: _notesController,
      maxLines: 3,
    ),
  );

  // ── Save Button ────────────────────────────────────────────────────────

  Widget _buildSaveButton(bool isNew) => ScaleTransition(
    scale: _savePulse,
    child: SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: _accent.withOpacity(0.4),
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
                    isNew ? 'إضافة رئيس اللجنة' : 'حفظ التعديلات',
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

import 'dart:typed_data';

import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/core/widgets/signature_pad.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/features/team/presentation/cubit/team_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Uint8List? _signature;
  bool _isSaving = false;

  // ── Animations ─────────────────────────────────────────────────────────
  late final AnimationController _headerAnimCtrl;
  late final AnimationController _fieldsAnimCtrl;
  late final AnimationController _savePulseCtrl;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final List<Animation<Offset>> _sectionSlides;
  late final Animation<double> _savePulse;

  static const int _sectionCount = 4;

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
    _signature = h.signature;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _specializationController.dispose();
    _rankController.dispose();
    _notesController.dispose();
    _headerAnimCtrl.dispose();
    _fieldsAnimCtrl.dispose();
    _savePulseCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

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
                      _section(2, _buildSignatureCard()),
                      const SizedBox(height: 16),
                      _section(3, _buildNotesCard()),
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

  Widget _buildSignatureCard() => _card(
    title: 'التوقيع الرسمي',
    icon: Icons.draw_outlined,
    accent: const Color(0xFF16A085),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

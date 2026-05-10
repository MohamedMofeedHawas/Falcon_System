import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/utils/pdf_generator.dart';
import 'package:falcon_system/core/widgets/empty_state.dart';
import 'package:falcon_system/data/models/evaluation_report.dart';
import 'package:falcon_system/features/evaluation/presentation/cubit/evaluation_cubit.dart';
import 'package:falcon_system/features/evaluation/presentation/screens/evaluation_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

class EvaluationListScreen extends StatefulWidget {
  const EvaluationListScreen({super.key});

  @override
  State<EvaluationListScreen> createState() => _EvaluationListScreenState();
}

class _EvaluationListScreenState extends State<EvaluationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<EvaluationCubit>().loadEvaluations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<EvaluationCubit, EvaluationState>(
                builder: (context, state) {
                  if (state is EvaluationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EvaluationError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.danger,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: AppFonts.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<EvaluationCubit>().loadEvaluations();
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is EvaluationLoaded) {
                    final evaluations = context
                        .read<EvaluationCubit>()
                        .searchEvaluations(_searchQuery);

                    if (evaluations.isEmpty) {
                      return EmptyState(
                        icon: Icons.assessment,
                        message: 'لا يوجد تقييمات',
                        subMessage: _searchQuery.isEmpty
                            ? 'اضغط على + لإضافة تقييم جديد'
                            : 'لم يتم العثور على نتائج',
                       
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: evaluations.length,
                      itemBuilder: (context, index) {
                        final evaluation =
                            evaluations[index] as EvaluationReport;
                        return _buildEvaluationCard(evaluation);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EvaluationFormScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('إضافة تقييم'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'البحث في التقييمات...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(EvaluationReport evaluation) {
    final scoreColor = _getScoreColor(evaluation.totalScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EvaluationFormScreen(evaluation: evaluation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evaluation.aerodromeName,
                          style: AppFonts.titleMedium,
                        ),

                        const SizedBox(height: 4),
                        Text(
                          '${evaluation.evaluationDate}',
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${evaluation.totalScore.toStringAsFixed(1)} / 10',
                      style: AppFonts.titleMedium.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusChip(evaluation.operationalDecision),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _exportPDF(evaluation),
                    icon: const Icon(Icons.picture_as_pdf),
                    color: AppColors.primary,
                    tooltip: 'تصدير PDF',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EvaluationFormScreen(evaluation: evaluation),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(evaluation);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(AppStrings.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.delete,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ],
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
    );
  }

  Widget _buildStatusChip(String decision) {
    Color chipColor;
    String chipText;

    switch (decision) {
      case 'آمن للتشغيل':
        chipColor = AppColors.success;
        chipText = decision;
        break;
      case 'يحتاج إلى إصلاحات':
        chipColor = AppColors.warning;
        chipText = decision;
        break;
      case 'غير آمن للتشغيل':
        chipColor = AppColors.danger;
        chipText = decision;
        break;
      default:
        chipColor = AppColors.textSecondary;
        chipText = decision;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        chipText,
        style: AppFonts.bodySmall.copyWith(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6) return AppColors.warning;
    if (score >= 4) return AppColors.danger;
    return AppColors.textSecondary;
  }

  Future<void> _exportPDF(EvaluationReport evaluation) async {
    try {
      final pdf = await PdfGenerator.generateFromEvaluationReport(evaluation);

      await Printing.sharePdf(
        bytes: pdf,
        filename: PdfGenerator.suggestedExportFileName(evaluation),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير ملف PDF بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تصدير PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(EvaluationReport evaluation) {
    final TextEditingController controller = TextEditingController();
    final ValueNotifier<bool> canDelete = ValueNotifier(false);
    final ValueNotifier<double> matchProgress = ValueNotifier(0.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: _DeleteDialogContent(
            aerodromeName: evaluation.aerodromeName,
            controller: controller,
            canDelete: canDelete,
            matchProgress: matchProgress,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () async {
              Navigator.of(dialogContext).pop();
              await context.read<EvaluationCubit>().deleteEvaluation(
                evaluation.id,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'تم حذف التقييم بنجاح',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF27500A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
}
class _DeleteDialogContent extends StatefulWidget {
  final String aerodromeName;
  final TextEditingController controller;
  final ValueNotifier<bool> canDelete;
  final ValueNotifier<double> matchProgress;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DeleteDialogContent({
    required this.aerodromeName,
    required this.controller,
    required this.canDelete,
    required this.matchProgress,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<_DeleteDialogContent> createState() => _DeleteDialogContentState();
}

class _DeleteDialogContentState extends State<_DeleteDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  bool _matched = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 6,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    final target = widget.aerodromeName.trim().toLowerCase();
    final input = value.trim().toLowerCase();
    final progress = (input.length / target.length).clamp(0.0, 1.0);
    widget.matchProgress.value = progress;
    final matched = input == target;
    widget.canDelete.value = matched;
    setState(() => _matched = matched);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Progress bar ──────────────────────────────────────────────
          ValueListenableBuilder<double>(
            valueListenable: widget.matchProgress,
            builder: (_, progress, _) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 200),
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: const Color(0xFFF7C1C1),
                valueColor: AlwaysStoppedAnimation(
                  _matched ? const Color(0xFF639922) : const Color(0xFFE24B4A),
                ),
              ),
            ),
          ),

          // ── Red header ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            color: const Color(0xFFFCEBEB),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF09595),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFCEBEB),
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 30,
                    color: Color(0xFF791F1F),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تأكيد حذف التقييم',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF501313),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'هذا الإجراء لا يمكن التراجع عنه.\nسيتم حذف جميع البيانات نهائياً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Color(0xFFA32D2D),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFAC775)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF854F0B),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'اكتب اسم المطار بالضبط لتفعيل زرار الحذف',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Color(0xFF633806),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Airport name display
                const Text(
                  'اسم المطار',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF7C1C1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.flight_outlined,
                        size: 16,
                        color: Color(0xFFA32D2D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.aerodromeName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF791F1F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Input
                const Text(
                  'اكتب الاسم للتأكيد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                      _shakeCtrl.isAnimating
                          ? _shakeAnim.value *
                                ((_shakeCtrl.value * 10).floor().isEven
                                    ? 1
                                    : -1)
                          : 0,
                      0,
                    ),
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _matched
                            ? const Color(0xFF639922)
                            : widget.controller.text.isNotEmpty
                            ? const Color(0xFFE24B4A)
                            : const Color(0xFFD3D1C7),
                        width: 1.5,
                      ),
                      boxShadow: _matched
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF639922,
                                ).withOpacity(0.15),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : widget.controller.text.isNotEmpty
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFE24B4A,
                                ).withOpacity(0.12),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: widget.controller,
                      onChanged: _onTextChanged,
                      style: const TextStyle(fontFamily: 'Cairo'),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم المطار هنا...',
                        hintStyle: const TextStyle(fontFamily: 'Cairo'),
                        prefixIcon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF888780),
                        ),
                        suffixIcon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _matched
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF639922),
                                  key: ValueKey('ok'),
                                )
                              : const SizedBox.shrink(key: ValueKey('none')),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Match hint
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _matched
                      ? const Row(
                          key: ValueKey('matched'),
                          children: [
                            Icon(
                              Icons.lock_open_outlined,
                              size: 12,
                              color: Color(0xFF3B6D11),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الاسم مطابق — يمكنك الحذف الآن',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Color(0xFF3B6D11),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          key: const ValueKey('locked'),
                          children: const [
                            Icon(
                              Icons.lock_outline,
                              size: 12,
                              color: Color(0xFF888780),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'الزر غير مفعّل حتى تكتب الاسم بالضبط',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: Color(0xFF888780),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFFD3D1C7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Color(0xFF5F5E5A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.canDelete,
                    builder: (_, enabled, _) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: enabled
                            ? const Color(0xFFE24B4A)
                            : const Color(0xFFB4B2A9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: enabled
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE24B4A,
                                  ).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: enabled ? widget.onConfirm : null,
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 17,
                        ),
                        label: const Text(
                          'حذف نهائي',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.7,
                          ),
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

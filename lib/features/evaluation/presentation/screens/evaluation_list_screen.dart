import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/utils/pdf_generator.dart';
import 'package:falcon_system/core/widgets/delete_dialog.dart';
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
          children: [            _buildSearchBar(),
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
                        actionLabel: 'إضافة تقييم',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EvaluationFormScreen(),
                            ),
                          );
                        },
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
  }  Widget _buildSearchBar() {
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
                        Text(evaluation.id, style: AppFonts.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          evaluation.aerodromeName,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
                      color: scoreColor.withOpacity(0.1),
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
        color: chipColor.withOpacity(0.1),
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
      final reportData = {
        'id': evaluation.id,
        'aerodromeName': evaluation.aerodromeName,
        'managerName': evaluation.managerName,
        'headName': evaluation.headName,
        'memberNames': evaluation.memberNames,
        'evaluationDate': evaluation.evaluationDate,
        'totalScore': evaluation.totalScore,
        'operationalDecision': evaluation.operationalDecision,
        'reinspectionDate': evaluation.reinspectionDate,
        'runwayEvaluation': evaluation.runwayEvaluation,
        'taxiwayEvaluation': evaluation.taxiwayEvaluation,
        'apronEvaluation': evaluation.apronEvaluation,
        'rffsEvaluation': evaluation.rffsEvaluation,
        'metEvaluation': evaluation.metEvaluation,
        'navaidsEvaluation': evaluation.navaidsEvaluation,
        'operationalEvaluation': evaluation.operationalEvaluation,
        'smsEvaluation': evaluation.smsEvaluation,
        'documentsEvaluation': evaluation.documentsEvaluation,
        'managerSignature': evaluation.managerSignature,
        'headSignature': evaluation.headSignature,
      };

      final pdf = await PdfGenerator.generateEvaluationReport(reportData);

      await Printing.sharePdf(
        bytes: pdf,
        filename: 'تقرير_تقييم_${evaluation.id}.pdf',
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
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        title: 'حذف التقييم',
        message: 'هل أنت متأكد من حذف هذا التقييم؟',
        itemName: evaluation.id,
        onConfirm: () {
          context.read<EvaluationCubit>().deleteEvaluation(evaluation.id);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف التقييم بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}


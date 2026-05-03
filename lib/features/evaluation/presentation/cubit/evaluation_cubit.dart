import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_keys.dart';
import '../../../../data/models/evaluation_report.dart';

part 'evaluation_state.dart';

class EvaluationCubit extends Cubit<EvaluationState> {
  EvaluationCubit() : super(EvaluationInitial());

  Box<dynamic> get _evaluationBox => Hive.box(HiveKeys.evaluationReportsBox);

  Future<void> loadEvaluations() async {
    emit(EvaluationLoading());
    try {
      final evaluations = _evaluationBox.values.toList();
      emit(EvaluationLoaded(evaluations: evaluations));
    } catch (e) {
      emit(EvaluationError(message: e.toString()));
    }
  }

  Future<void> saveEvaluation(EvaluationReport evaluation) async {
    emit(EvaluationLoading());
    try {
      await _evaluationBox.put(evaluation.id, evaluation);
      final evaluations = _evaluationBox.values.toList();
      emit(EvaluationLoaded(evaluations: evaluations));
    } catch (e) {
      emit(EvaluationError(message: e.toString()));
    }
  }

  Future<void> deleteEvaluation(String id) async {
    emit(EvaluationLoading());
    try {
      await _evaluationBox.delete(id);
      final evaluations = _evaluationBox.values.toList();
      emit(EvaluationLoaded(evaluations: evaluations));
    } catch (e) {
      emit(EvaluationError(message: e.toString()));
    }
  }

  EvaluationReport? getEvaluationById(String id) {
    final evaluation = _evaluationBox.get(id);
    if (evaluation != null && evaluation is EvaluationReport) {
      return evaluation;
    }
    return null;
  }

  List<dynamic> searchEvaluations(String query) {
    if (state is EvaluationLoaded) {
      final evaluations = (state as EvaluationLoaded).evaluations;
      return evaluations.where((e) {
        if (e is EvaluationReport) {
          return e.aerodromeName.contains(query) || e.id.contains(query);
        }
        return false;
      }).toList();
    }
    return [];
  }

  double calculateTotalScore(Map<String, dynamic> evaluations) {
    double totalScore = 0;
    double totalWeight = 0;

    // Section weights
    final Map<String, double> sectionWeights = {
      'runways': 0.15,
      'aprons': 0.12,
      'navigationalAids': 0.14,
      'atc': 0.13,
      'meteorological': 0.10,
      'rescueFire': 0.12,
      'security': 0.10,
      'maintenance': 0.08,
      'documentation': 0.06,
    };

    for (var entry in evaluations.entries) {
      final section = entry.key;
      final sectionData = entry.value as Map<String, dynamic>;
      final weight = sectionWeights[section] ?? 0.1;

      double sectionScore = 0;
      int itemCount = 0;

      for (var item in sectionData.values) {
        if (item is Map<String, dynamic>) {
          final score = item['score'] as double? ?? 0;
          sectionScore += score;
          itemCount++;
        }
      }

      if (itemCount > 0) {
        final averageScore = sectionScore / itemCount;
        totalScore += averageScore * weight;
        totalWeight += weight;
      }
    }

    return totalWeight > 0 ? (totalScore / totalWeight) * 10 : 0;
  }

  String getOperationalDecision(double score) {
    if (score >= 90) return 'ممتاز - آمن للتشغيل';
    if (score >= 75) return 'جيد - آمن للتشغيل';
    if (score >= 60) return 'مقبول - يحتاج مراقبة';
    return 'غير آمن - يحتاج إجراءات فورية';
  }

  DateTime calculateReinspectionDate(double score) {
    final now = DateTime.now();
    if (score >= 90) {
      return DateTime(now.year, now.month + 6, now.day);
    } else if (score >= 75) {
      return DateTime(now.year, now.month + 4, now.day);
    } else if (score >= 60) {
      return DateTime(now.year, now.month + 2, now.day);
    } else {
      return DateTime(now.year, now.month + 1, now.day);
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../data/models/evaluation_report.dart';

part 'evaluation_state.dart';

class EvaluationCubit extends Cubit<EvaluationState> {
  EvaluationCubit() : super(EvaluationInitial());

  Box<EvaluationReport> get _evaluationBox => HiveService.evaluationBox;

  Future<void> loadEvaluations() async {
    emit(EvaluationLoading());
    try {
      final evaluations = _evaluationBox.toMap().entries
          .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
          .map((entry) => entry.value)
          .toList();
      emit(EvaluationLoaded(evaluations: evaluations));
    } catch (e) {
      emit(EvaluationError(message: e.toString()));
    }
  }

  Future<void> saveEvaluation(EvaluationReport evaluation) async {
    emit(EvaluationLoading());
    try {
      await _evaluationBox.put(HiveService.scopedKey(evaluation.id), evaluation);
      final evaluations = _evaluationBox.toMap().entries
          .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
          .map((entry) => entry.value)
          .toList();
      emit(EvaluationLoaded(evaluations: evaluations));
    } catch (e) {
      emit(EvaluationError(message: e.toString()));
    }
  }

  Future<void> deleteEvaluation(String id) async {
    emit(EvaluationLoading());
    try {
      await _evaluationBox.delete(HiveService.scopedKey(id));
      final evaluations = _evaluationBox.toMap().entries
          .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
          .map((entry) => entry.value)
          .toList();
      emit(EvaluationLoaded(evaluations: evaluations));
    } catch (e) {
      emit(EvaluationError(message: e.toString()));
    }
  }

  EvaluationReport? getEvaluationById(String id) =>
      _evaluationBox.get(HiveService.scopedKey(id));

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

    // أوزان تتوافق مع ملخص التقرير الرسمي (المجموع = 1.0)
    final Map<String, double> sectionWeights = {
      'runways': 0.20,
      'taxiways': 0.15,
      'aprons': 0.15,
      'rescueFire': 0.20 / 3,
      'meteorological': 0.20 / 3,
      'navigationalAids': 0.20 / 3,
      'atc': 0.10,
      'security': 0.10,
      'documentation': 0.10,
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
    if (score >= 90) return 'صالح للتشغيل (≥ 90٪)';
    if (score >= 60) return 'يحتاج تصحيح (60٪ – 89٪)';
    return 'غير صالح (< 60٪) أو وجود عطل حرج دون خطة';
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

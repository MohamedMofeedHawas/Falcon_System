// lib/data/models/runway_element_score.dart

import 'package:hive/hive.dart';

part 'runway_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر تقييم المدرج
@HiveType(typeId: 19)
class RunwayElementScore extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  RunwayElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  RunwayElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return RunwayElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

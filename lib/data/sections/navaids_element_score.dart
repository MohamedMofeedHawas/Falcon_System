// lib/data/models/navaids_element_score.dart

import 'package:hive/hive.dart';

part 'navaids_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر المساعدات الملاحية
@HiveType(typeId: 17)
class NavaidsElementScore extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  NavaidsElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  NavaidsElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return NavaidsElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

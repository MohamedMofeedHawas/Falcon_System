// lib/data/models/rffs_element_score.dart

import 'package:hive/hive.dart';

part 'rffs_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر خدمات الإطفاء والإنقاذ
@HiveType(typeId: 11)
class RffsElementScore extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  RffsElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  RffsElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return RffsElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

// lib/data/sections/documents_element_score.dart

import 'package:hive/hive.dart';

part 'documents_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر الوثائق والتصاريح
@HiveType(typeId: 23)
class DocumentsElementScore extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  DocumentsElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  DocumentsElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return DocumentsElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

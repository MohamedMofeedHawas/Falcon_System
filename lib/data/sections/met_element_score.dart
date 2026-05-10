// lib/data/models/met_element_score.dart

import 'package:hive/hive.dart';

part 'met_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر خدمات الأرصاد الجوية
@HiveType(typeId: 9)
class MetElementScore extends HiveObject {
  /// مفتاح العنصر (ثابت للبرمجة)
  @override
  @HiveField(0)
  final String key;

  /// الدرجة من 0 إلى 10
  @HiveField(1)
  final int score;

  /// ملاحظات المفتش الحرة
  @HiveField(2)
  final String notes;

  /// قائمة المعايير الفرعية المُحققة (true = موجود / false = غائب)
  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  MetElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  MetElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return MetElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

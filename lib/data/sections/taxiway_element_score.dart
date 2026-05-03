// lib/data/models/taxiway_element_score.dart
/*
import 'package:hive/hive.dart';

part 'taxiway_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر ممر التاكسي
@HiveType(typeId: 7)
class TaxiwayElementScore extends HiveObject {
  /// مفتاح العنصر (ثابت للبرمجة)
  @HiveField(0)
  final String key;

  /// الدرجة من 0 إلى 10
  @HiveField(1)
  final int score;

  /// ملاحظات المفتش الحرة
  @HiveField(2)
  final String notes;

  /// قائمة المعايير الفرعية المُحققة (true = موجود / false = غائب)
  /// المفاتيح: رموز ثابتة للمعايير الفرعية
  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  TaxiwayElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  TaxiwayElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return TaxiwayElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}*/
// lib/data/models/taxiway_element_score.dart

import 'package:hive/hive.dart';

part 'taxiway_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر ممر التاكسي
@HiveType(typeId: 7)
class TaxiwayElementScore extends HiveObject {
  /// مفتاح العنصر (ثابت للبرمجة)
  @HiveField(0)
  final String key;

  /// الدرجة من 0 إلى 10
  @HiveField(1)
  final int score;

  /// ملاحظات المفتش الحرة
  @HiveField(2)
  final String notes;

  /// قائمة المعايير الفرعية المُحققة (true = موجود / false = غائب)
  /// المفاتيح: رموز ثابتة للمعايير الفرعية
  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  TaxiwayElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  TaxiwayElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return TaxiwayElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

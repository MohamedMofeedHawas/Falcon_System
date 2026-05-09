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
    int score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  })  : score = score.clamp(0, 10),
        subCriteriaChecked = subCriteriaChecked ?? {};

  TaxiwayElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    final nextScore = score ?? this.score;
    return TaxiwayElementScore(
      key: key ?? this.key,
      score: nextScore.clamp(0, 10),
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

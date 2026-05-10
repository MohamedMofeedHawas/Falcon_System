// lib/data/models/sms_element_score.dart

import 'package:hive/hive.dart';

part 'sms_element_score.g.dart';

/// درجة تقييم عنصر واحد من عناصر نظام إدارة السلامة
@HiveType(typeId: 15)
class SmsElementScore extends HiveObject {
  @override
  @HiveField(0)
  final String key;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final String notes;

  @HiveField(3)
  final Map<String, bool> subCriteriaChecked;

  SmsElementScore({
    required this.key,
    this.score = 5,
    this.notes = '',
    Map<String, bool>? subCriteriaChecked,
  }) : subCriteriaChecked = subCriteriaChecked ?? {};

  SmsElementScore copyWith({
    String? key,
    int? score,
    String? notes,
    Map<String, bool>? subCriteriaChecked,
  }) {
    return SmsElementScore(
      key: key ?? this.key,
      score: score ?? this.score,
      notes: notes ?? this.notes,
      subCriteriaChecked:
          subCriteriaChecked ?? Map.from(this.subCriteriaChecked),
    );
  }
}

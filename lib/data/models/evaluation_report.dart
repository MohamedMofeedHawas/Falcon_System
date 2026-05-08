import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'evaluation_report.g.dart';

@HiveType(typeId: HiveKeys.evaluationReportTypeId)
class EvaluationReport extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String aerodromeId;

  @HiveField(2)
  String aerodromeName;

  @HiveField(3)
  String managerId;

  @HiveField(4)
  String managerName;

  @HiveField(5)
  String headId;

  @HiveField(6)
  String headName;

  @HiveField(7)
  List<String> memberIds;

  @HiveField(8)
  List<String> memberNames;

  @HiveField(9)
  String? aircraftId;

  @HiveField(10)
  String? aircraftName;

  @HiveField(11)
  DateTime? evaluationDate; // ← غيرناها nullable

  @HiveField(12)
  double totalScore;

  @HiveField(13)
  String operationalDecision;

  @HiveField(14)
  Uint8List? managerSignature;

  @HiveField(15)
  Uint8List? headSignature;

  @HiveField(16)
  DateTime? reinspectionDate;

  @HiveField(17)
  String? notes;

  @HiveField(18)
  DateTime? createdAt; // ← غيرناها nullable

  @HiveField(19)
  DateTime? updatedAt; // ← غيرناها nullable

  @HiveField(20)
  Map<String, dynamic> runwayEvaluation;

  @HiveField(21)
  Map<String, dynamic> taxiwayEvaluation;

  @HiveField(22)
  Map<String, dynamic> apronEvaluation;

  @HiveField(23)
  Map<String, dynamic> rffsEvaluation;

  @HiveField(24)
  Map<String, dynamic> metEvaluation;

  @HiveField(25)
  Map<String, dynamic> navaidsEvaluation;

  @HiveField(26)
  Map<String, dynamic> operationalEvaluation;

  @HiveField(27)
  Map<String, dynamic> smsEvaluation;

  @HiveField(28)
  Map<String, dynamic> documentsEvaluation;

  // ← Safe getters بيحمي من null على Web
  DateTime get safeEvaluationDate => evaluationDate ?? DateTime.now();
  DateTime get safeCreatedAt => createdAt ?? DateTime.now();
  DateTime get safeUpdatedAt => updatedAt ?? DateTime.now();

  EvaluationReport({
    required this.id,
    required this.aerodromeId,
    required this.aerodromeName,
    required this.managerId,
    required this.managerName,
    required this.headId,
    required this.headName,
    List<String>? memberIds,
    List<String>? memberNames,
    this.aircraftId,
    this.aircraftName,
    DateTime? evaluationDate,
    required this.totalScore,
    required this.operationalDecision,
    this.managerSignature,
    this.headSignature,
    this.reinspectionDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? runwayEvaluation,
    Map<String, dynamic>? taxiwayEvaluation,
    Map<String, dynamic>? apronEvaluation,
    Map<String, dynamic>? rffsEvaluation,
    Map<String, dynamic>? metEvaluation,
    Map<String, dynamic>? navaidsEvaluation,
    Map<String, dynamic>? operationalEvaluation,
    Map<String, dynamic>? smsEvaluation,
    Map<String, dynamic>? documentsEvaluation,
  }) : evaluationDate = evaluationDate ?? DateTime.now(),
       memberIds = memberIds ?? [],
       memberNames = memberNames ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       runwayEvaluation = runwayEvaluation ?? {},
       taxiwayEvaluation = taxiwayEvaluation ?? {},
       apronEvaluation = apronEvaluation ?? {},
       rffsEvaluation = rffsEvaluation ?? {},
       metEvaluation = metEvaluation ?? {},
       navaidsEvaluation = navaidsEvaluation ?? {},
       operationalEvaluation = operationalEvaluation ?? {},
       smsEvaluation = smsEvaluation ?? {},
       documentsEvaluation = documentsEvaluation ?? {};

  EvaluationReport copyWith({
    String? id,
    String? aerodromeId,
    String? aerodromeName,
    String? managerId,
    String? managerName,
    String? headId,
    String? headName,
    List<String>? memberIds,
    List<String>? memberNames,
    String? aircraftId,
    String? aircraftName,
    DateTime? evaluationDate,
    double? totalScore,
    String? operationalDecision,
    Uint8List? managerSignature,
    Uint8List? headSignature,
    DateTime? reinspectionDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? runwayEvaluation,
    Map<String, dynamic>? taxiwayEvaluation,
    Map<String, dynamic>? apronEvaluation,
    Map<String, dynamic>? rffsEvaluation,
    Map<String, dynamic>? metEvaluation,
    Map<String, dynamic>? navaidsEvaluation,
    Map<String, dynamic>? operationalEvaluation,
    Map<String, dynamic>? smsEvaluation,
    Map<String, dynamic>? documentsEvaluation,
  }) {
    return EvaluationReport(
      id: id ?? this.id,
      aerodromeId: aerodromeId ?? this.aerodromeId,
      aerodromeName: aerodromeName ?? this.aerodromeName,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      headId: headId ?? this.headId,
      headName: headName ?? this.headName,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      aircraftId: aircraftId ?? this.aircraftId,
      aircraftName: aircraftName ?? this.aircraftName,
      evaluationDate: evaluationDate ?? safeEvaluationDate,
      totalScore: totalScore ?? this.totalScore,
      operationalDecision: operationalDecision ?? this.operationalDecision,
      managerSignature: managerSignature ?? this.managerSignature,
      headSignature: headSignature ?? this.headSignature,
      reinspectionDate: reinspectionDate ?? this.reinspectionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? safeCreatedAt,
      updatedAt: updatedAt ?? safeUpdatedAt,
      runwayEvaluation: runwayEvaluation ?? this.runwayEvaluation,
      taxiwayEvaluation: taxiwayEvaluation ?? this.taxiwayEvaluation,
      apronEvaluation: apronEvaluation ?? this.apronEvaluation,
      rffsEvaluation: rffsEvaluation ?? this.rffsEvaluation,
      metEvaluation: metEvaluation ?? this.metEvaluation,
      navaidsEvaluation: navaidsEvaluation ?? this.navaidsEvaluation,
      operationalEvaluation:
          operationalEvaluation ?? this.operationalEvaluation,
      smsEvaluation: smsEvaluation ?? this.smsEvaluation,
      documentsEvaluation: documentsEvaluation ?? this.documentsEvaluation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aerodromeId': aerodromeId,
      'aerodromeName': aerodromeName,
      'managerId': managerId,
      'managerName': managerName,
      'headId': headId,
      'headName': headName,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'aircraftId': aircraftId,
      'aircraftName': aircraftName,
      'evaluationDate': safeEvaluationDate.toIso8601String(),
      'totalScore': totalScore,
      'operationalDecision': operationalDecision,
      'managerSignature': managerSignature,
      'headSignature': headSignature,
      'reinspectionDate': reinspectionDate?.toIso8601String(),
      'notes': notes,
      'createdAt': safeCreatedAt.toIso8601String(),
      'updatedAt': safeUpdatedAt.toIso8601String(),
      'runwayEvaluation': runwayEvaluation,
      'taxiwayEvaluation': taxiwayEvaluation,
      'apronEvaluation': apronEvaluation,
      'rffsEvaluation': rffsEvaluation,
      'metEvaluation': metEvaluation,
      'navaidsEvaluation': navaidsEvaluation,
      'operationalEvaluation': operationalEvaluation,
      'smsEvaluation': smsEvaluation,
      'documentsEvaluation': documentsEvaluation,
    };
  }

  factory EvaluationReport.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value as String);
      } catch (_) {
        return null;
      }
    }

    Map<String, dynamic> safeMap(dynamic value) {
      if (value == null) return {};
      if (value is Map<String, dynamic>) return value;
      try {
        return Map<String, dynamic>.from(value as Map);
      } catch (_) {
        return {};
      }
    }

    return EvaluationReport(
      id: json['id'] as String? ?? '',
      aerodromeId: json['aerodromeId'] as String? ?? '',
      aerodromeName: json['aerodromeName'] as String? ?? '',
      managerId: json['managerId'] as String? ?? '',
      managerName: json['managerName'] as String? ?? '',
      headId: json['headId'] as String? ?? '',
      headName: json['headName'] as String? ?? '',
      memberIds: (json['memberIds'] as List<dynamic>?)?.cast<String>() ?? [],
      memberNames:
          (json['memberNames'] as List<dynamic>?)?.cast<String>() ?? [],
      aircraftId: json['aircraftId'] as String?,
      aircraftName: json['aircraftName'] as String?,
      evaluationDate: parseDate(json['evaluationDate']) ?? DateTime.now(),
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      operationalDecision: json['operationalDecision'] as String? ?? '',
      managerSignature: json['managerSignature'] as Uint8List?,
      headSignature: json['headSignature'] as Uint8List?,
      reinspectionDate: parseDate(json['reinspectionDate']),
      notes: json['notes'] as String?,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']) ?? DateTime.now(),
      runwayEvaluation: safeMap(json['runwayEvaluation']),
      taxiwayEvaluation: safeMap(json['taxiwayEvaluation']),
      apronEvaluation: safeMap(json['apronEvaluation']),
      rffsEvaluation: safeMap(json['rffsEvaluation']),
      metEvaluation: safeMap(json['metEvaluation']),
      navaidsEvaluation: safeMap(json['navaidsEvaluation']),
      operationalEvaluation: safeMap(json['operationalEvaluation']),
      smsEvaluation: safeMap(json['smsEvaluation']),
      documentsEvaluation: safeMap(json['documentsEvaluation']),
    );
  }
}

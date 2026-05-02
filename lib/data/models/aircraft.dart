import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'aircraft.g.dart';

@HiveType(typeId: HiveKeys.aircraftTypeId)
class Aircraft extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String registrationNumber;

  @HiveField(2)
  String manufacturer;

  @HiveField(3)
  String model;

  @HiveField(4)
  String type;

  @HiveField(5)
  int? year;

  @HiveField(6)
  String? engineType;

  @HiveField(7)
  int? maxTakeoffWeight;

  @HiveField(8)
  int? maxLandingWeight;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  Aircraft({
    required this.id,
    required this.registrationNumber,
    required this.manufacturer,
    required this.model,
    required this.type,
    this.year,
    this.engineType,
    this.maxTakeoffWeight,
    this.maxLandingWeight,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Aircraft copyWith({
    String? id,
    String? registrationNumber,
    String? manufacturer,
    String? model,
    String? type,
    int? year,
    String? engineType,
    int? maxTakeoffWeight,
    int? maxLandingWeight,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Aircraft(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      type: type ?? this.type,
      year: year ?? this.year,
      engineType: engineType ?? this.engineType,
      maxTakeoffWeight: maxTakeoffWeight ?? this.maxTakeoffWeight,
      maxLandingWeight: maxLandingWeight ?? this.maxLandingWeight,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'manufacturer': manufacturer,
      'model': model,
      'type': type,
      'year': year,
      'engineType': engineType,
      'maxTakeoffWeight': maxTakeoffWeight,
      'maxLandingWeight': maxLandingWeight,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Aircraft.fromJson(Map<String, dynamic> json) {
    return Aircraft(
      id: json['id'] as String,
      registrationNumber: json['registrationNumber'] as String,
      manufacturer: json['manufacturer'] as String,
      model: json['model'] as String,
      type: json['type'] as String,
      year: json['year'] as int?,
      engineType: json['engineType'] as String?,
      maxTakeoffWeight: json['maxTakeoffWeight'] as int?,
      maxLandingWeight: json['maxLandingWeight'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

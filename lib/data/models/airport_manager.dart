import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'airport_manager.g.dart';

@HiveType(typeId: HiveKeys.airportManagerTypeId)
class AirportManager extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String employeeNumber;

  @HiveField(3)
  DateTime appointmentDate;

  @HiveField(4)
  Uint8List? signature;

  @HiveField(5)
  Uint8List? officialStamp;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  AirportManager({
    required this.id,
    required this.fullName,
    required this.employeeNumber,
    required this.appointmentDate,
    this.signature,
    this.officialStamp,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  AirportManager copyWith({
    String? id,
    String? fullName,
    String? employeeNumber,
    DateTime? appointmentDate,
    Uint8List? signature,
    Uint8List? officialStamp,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AirportManager(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      signature: signature ?? this.signature,
      officialStamp: officialStamp ?? this.officialStamp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'employeeNumber': employeeNumber,
      'appointmentDate': appointmentDate.toIso8601String(),
      'signature': signature,
      'officialStamp': officialStamp,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AirportManager.fromJson(Map<String, dynamic> json) {
    return AirportManager(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      employeeNumber: json['employeeNumber'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      signature: json['signature'] as Uint8List?,
      officialStamp: json['officialStamp'] as Uint8List?,
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

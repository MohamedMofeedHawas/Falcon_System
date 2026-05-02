import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'inspection_head.g.dart';

@HiveType(typeId: HiveKeys.inspectionHeadTypeId)
class InspectionHead extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String specialization;

  @HiveField(3)
  String? rank;

  @HiveField(4)
  Uint8List? signature;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  InspectionHead({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.rank,
    this.signature,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  InspectionHead copyWith({
    String? id,
    String? fullName,
    String? specialization,
    String? rank,
    Uint8List? signature,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionHead(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialization: specialization ?? this.specialization,
      rank: rank ?? this.rank,
      signature: signature ?? this.signature,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'specialization': specialization,
      'rank': rank,
      'signature': signature,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InspectionHead.fromJson(Map<String, dynamic> json) {
    return InspectionHead(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      specialization: json['specialization'] as String,
      rank: json['rank'] as String?,
      signature: json['signature'] as Uint8List?,
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

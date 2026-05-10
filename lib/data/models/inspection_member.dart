import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'inspection_member.g.dart';

@HiveType(typeId: HiveKeys.inspectionMemberTypeId)
class InspectionMember extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String specialization;

  @HiveField(3)
  String? rank;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  List<String> phoneNumbers;

  @HiveField(8)
  String? cvPath;

  InspectionMember({
    required this.id,
    required this.fullName,
    required this.specialization,
    this.rank,
    this.notes,
    List<String>? phoneNumbers,
    this.cvPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : phoneNumbers = phoneNumbers ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  InspectionMember copyWith({
    String? id,
    String? fullName,
    String? specialization,
    String? rank,
    String? notes,
    List<String>? phoneNumbers,
    String? cvPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InspectionMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialization: specialization ?? this.specialization,
      rank: rank ?? this.rank,
      notes: notes ?? this.notes,
      phoneNumbers: phoneNumbers ?? List.from(this.phoneNumbers),
      cvPath: cvPath ?? this.cvPath,
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
      'notes': notes,
      'phoneNumbers': phoneNumbers,
      'cvPath': cvPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory InspectionMember.fromJson(Map<String, dynamic> json) {
    return InspectionMember(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      specialization: json['specialization'] as String,
      rank: json['rank'] as String?,
      notes: json['notes'] as String?,
      phoneNumbers:
          (json['phoneNumbers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      cvPath: json['cvPath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

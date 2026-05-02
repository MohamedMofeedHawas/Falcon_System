import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'admin_profile.g.dart';

@HiveType(typeId: HiveKeys.adminProfileTypeId)
class AdminProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  String email;

  @HiveField(3)
  String nationality;

  @HiveField(4)
  String nationalId;

  @HiveField(5)
  String? rank;

  @HiveField(6)
  int? age;

  @HiveField(7)
  int? flightHours;

  @HiveField(8)
  List<String> phones;

  @HiveField(9)
  String? governorate;

  @HiveField(10)
  String? workplace;

  @HiveField(11)
  DateTime? employmentDate;

  @HiveField(12)
  bool hasLicense;

  @HiveField(13)
  String? licenseNumber;

  @HiveField(14)
  DateTime? licenseIssueDate;

  @HiveField(15)
  DateTime? licenseExpiryDate;

  @HiveField(16)
  String? photo;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  DateTime updatedAt;

  AdminProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.nationality,
    required this.nationalId,
    this.rank,
    this.age,
    this.flightHours,
    List<String>? phones,
    this.governorate,
    this.workplace,
    this.employmentDate,
    this.hasLicense = false,
    this.licenseNumber,
    this.licenseIssueDate,
    this.licenseExpiryDate,
    this.photo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : phones = phones ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  AdminProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? nationality,
    String? nationalId,
    String? rank,
    int? age,
    int? flightHours,
    List<String>? phones,
    String? governorate,
    String? workplace,
    DateTime? employmentDate,
    bool? hasLicense,
    String? licenseNumber,
    DateTime? licenseIssueDate,
    DateTime? licenseExpiryDate,
    String? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      nationality: nationality ?? this.nationality,
      nationalId: nationalId ?? this.nationalId,
      rank: rank ?? this.rank,
      age: age ?? this.age,
      flightHours: flightHours ?? this.flightHours,
      phones: phones ?? this.phones,
      governorate: governorate ?? this.governorate,
      workplace: workplace ?? this.workplace,
      employmentDate: employmentDate ?? this.employmentDate,
      hasLicense: hasLicense ?? this.hasLicense,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseIssueDate: licenseIssueDate ?? this.licenseIssueDate,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'nationality': nationality,
      'nationalId': nationalId,
      'rank': rank,
      'age': age,
      'flightHours': flightHours,
      'phones': phones,
      'governorate': governorate,
      'workplace': workplace,
      'employmentDate': employmentDate?.toIso8601String(),
      'hasLicense': hasLicense,
      'licenseNumber': licenseNumber,
      'licenseIssueDate': licenseIssueDate?.toIso8601String(),
      'licenseExpiryDate': licenseExpiryDate?.toIso8601String(),
      'photo': photo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      nationality: json['nationality'] as String,
      nationalId: json['nationalId'] as String,
      rank: json['rank'] as String?,
      age: json['age'] as int?,
      flightHours: json['flightHours'] as int?,
      phones: (json['phones'] as List<dynamic>?)?.cast<String>() ?? [],
      governorate: json['governorate'] as String?,
      workplace: json['workplace'] as String?,
      employmentDate: json['employmentDate'] != null
          ? DateTime.parse(json['employmentDate'] as String)
          : null,
      hasLicense: json['hasLicense'] as bool? ?? false,
      licenseNumber: json['licenseNumber'] as String?,
      licenseIssueDate: json['licenseIssueDate'] != null
          ? DateTime.parse(json['licenseIssueDate'] as String)
          : null,
      licenseExpiryDate: json['licenseExpiryDate'] != null
          ? DateTime.parse(json['licenseExpiryDate'] as String)
          : null,
      photo: json['photo'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

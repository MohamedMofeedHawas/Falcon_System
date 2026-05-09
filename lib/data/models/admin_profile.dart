import 'dart:typed_data';

import 'package:hive/hive.dart';

/// Persisted with [AdminProfileHiveAdapter] (hand-written for safe reads of legacy/corrupt cells).
class AdminProfile extends HiveObject {
  String id;
  String fullName;
  String email;
  String nationality;
  String nationalId;
  String? rank;
  int? age; // kept for backward compat — prefer dateOfBirth
  int? flightHours;
  List<String> phones;
  String? governorate;
  String? workplace;
  DateTime? employmentDate;
  bool hasLicense;
  String? licenseNumber;
  DateTime? licenseIssueDate;
  DateTime? licenseExpiryDate;
  String? photo;
  DateTime createdAt;
  DateTime updatedAt;
  String? password;
  List<String> whatsappNumbers;
  String? residenceAddress;
  String? customNationality;
  String? adminSignatureText;
  Uint8List? adminSignatureImage;
  String? adminSignatureMode;
  DateTime? adminSignatureSavedAt;
  DateTime? dateOfBirth;
  String? licenseIssuingAuthority;

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
    this.password,
    List<String>? whatsappNumbers,
    this.residenceAddress,
    this.customNationality,
    this.adminSignatureText,
    this.adminSignatureImage,
    this.adminSignatureMode,
    this.adminSignatureSavedAt,
    this.dateOfBirth,
    this.licenseIssuingAuthority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : phones = phones ?? [],
       whatsappNumbers = whatsappNumbers ?? [],
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
    String? password,
    List<String>? whatsappNumbers,
    String? residenceAddress,
    String? customNationality,
    String? adminSignatureText,
    Uint8List? adminSignatureImage,
    String? adminSignatureMode,
    DateTime? adminSignatureSavedAt,
    DateTime? dateOfBirth,
    String? licenseIssuingAuthority,
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
      password: password ?? this.password,
      whatsappNumbers: whatsappNumbers ?? this.whatsappNumbers,
      residenceAddress: residenceAddress ?? this.residenceAddress,
      customNationality: customNationality ?? this.customNationality,
      adminSignatureText: adminSignatureText ?? this.adminSignatureText,
      adminSignatureImage: adminSignatureImage ?? this.adminSignatureImage,
      adminSignatureMode: adminSignatureMode ?? this.adminSignatureMode,
      adminSignatureSavedAt:
          adminSignatureSavedAt ?? this.adminSignatureSavedAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      licenseIssuingAuthority:
          licenseIssuingAuthority ?? this.licenseIssuingAuthority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Computed age from dateOfBirth (falls back to stored int age)
  int? get computedAge {
    if (dateOfBirth == null) return age;
    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      years--;
    }
    return years;
  }

  Map<String, dynamic> toJson() => {
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
    'password': password,
    'whatsappNumbers': whatsappNumbers,
    'residenceAddress': residenceAddress,
    'customNationality': customNationality,
    'adminSignatureText': adminSignatureText,
    'adminSignatureImage': adminSignatureImage,
    'adminSignatureMode': adminSignatureMode,
    'adminSignatureSavedAt': adminSignatureSavedAt?.toIso8601String(),
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'licenseIssuingAuthority': licenseIssuingAuthority,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AdminProfile.fromJson(Map<String, dynamic> json) => AdminProfile(
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
    password: json['password'] as String?,
    whatsappNumbers:
        (json['whatsappNumbers'] as List<dynamic>?)?.cast<String>() ?? [],
    residenceAddress: json['residenceAddress'] as String?,
    customNationality: json['customNationality'] as String?,
    adminSignatureText: json['adminSignatureText'] as String?,
    adminSignatureImage: json['adminSignatureImage'] as Uint8List?,
    adminSignatureMode: json['adminSignatureMode'] as String?,
    adminSignatureSavedAt: json['adminSignatureSavedAt'] != null
        ? DateTime.parse(json['adminSignatureSavedAt'] as String)
        : null,
    dateOfBirth: json['dateOfBirth'] != null
        ? DateTime.parse(json['dateOfBirth'] as String)
        : null,
    licenseIssuingAuthority: json['licenseIssuingAuthority'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now(),
  );
}

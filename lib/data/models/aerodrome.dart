import 'package:hive/hive.dart';

import '../../core/constants/hive_keys.dart';

part 'aerodrome.g.dart';

@HiveType(typeId: HiveKeys.aerodromeTypeId)
class Aerodrome extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String icaoCode;

  @HiveField(2)
  String arabicName;

  @HiveField(3)
  String englishName;

  @HiveField(4)
  DateTime creationDate;

  @HiveField(5)
  String airportType;

  @HiveField(6)
  String governorate;

  @HiveField(7)
  String city;

  @HiveField(8)
  double latitude;

  @HiveField(9)
  double longitude;

  @HiveField(10)
  double elevation;

  @HiveField(11)
  String operationalStatus;

  @HiveField(12)
  String registrationNumber;

  @HiveField(13)
  String operator;

  @HiveField(14)
  String supervisingAuthority;

  @HiveField(15)
  String icaoCategory;

  @HiveField(16)
  double longestRunway;

  @HiveField(17)
  int capacity;

  @HiveField(18)
  String? notes;

  @HiveField(19)
  DateTime? lastInspection;

  @HiveField(20)
  DateTime createdAt;

  @HiveField(21)
  DateTime updatedAt;

  Aerodrome({
    required this.id,
    required this.icaoCode,
    required this.arabicName,
    required this.englishName,
    required this.creationDate,
    required this.airportType,
    required this.governorate,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.operationalStatus,
    required this.registrationNumber,
    required this.operator,
    required this.supervisingAuthority,
    required this.icaoCategory,
    required this.longestRunway,
    required this.capacity,
    this.notes,
    this.lastInspection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Aerodrome copyWith({
    String? id,
    String? icaoCode,
    String? arabicName,
    String? englishName,
    DateTime? creationDate,
    String? airportType,
    String? governorate,
    String? city,
    double? latitude,
    double? longitude,
    double? elevation,
    String? operationalStatus,
    String? registrationNumber,
    String? operator,
    String? supervisingAuthority,
    String? icaoCategory,
    double? longestRunway,
    int? capacity,
    String? notes,
    DateTime? lastInspection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Aerodrome(
      id: id ?? this.id,
      icaoCode: icaoCode ?? this.icaoCode,
      arabicName: arabicName ?? this.arabicName,
      englishName: englishName ?? this.englishName,
      creationDate: creationDate ?? this.creationDate,
      airportType: airportType ?? this.airportType,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      operator: operator ?? this.operator,
      supervisingAuthority: supervisingAuthority ?? this.supervisingAuthority,
      icaoCategory: icaoCategory ?? this.icaoCategory,
      longestRunway: longestRunway ?? this.longestRunway,
      capacity: capacity ?? this.capacity,
      notes: notes ?? this.notes,
      lastInspection: lastInspection ?? this.lastInspection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icaoCode': icaoCode,
      'arabicName': arabicName,
      'englishName': englishName,
      'creationDate': creationDate.toIso8601String(),
      'airportType': airportType,
      'governorate': governorate,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'operationalStatus': operationalStatus,
      'registrationNumber': registrationNumber,
      'operator': operator,
      'supervisingAuthority': supervisingAuthority,
      'icaoCategory': icaoCategory,
      'longestRunway': longestRunway,
      'capacity': capacity,
      'notes': notes,
      'lastInspection': lastInspection?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Aerodrome.fromJson(Map<String, dynamic> json) {
    return Aerodrome(
      id: json['id'] as String,
      icaoCode: json['icaoCode'] as String,
      arabicName: json['arabicName'] as String,
      englishName: json['englishName'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      airportType: json['airportType'] as String,
      governorate: json['governorate'] as String,
      city: json['city'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      elevation: json['elevation'] as double,
      operationalStatus: json['operationalStatus'] as String,
      registrationNumber: json['registrationNumber'] as String,
      operator: json['operator'] as String,
      supervisingAuthority: json['supervisingAuthority'] as String,
      icaoCategory: json['icaoCategory'] as String,
      longestRunway: json['longestRunway'] as double,
      capacity: json['capacity'] as int,
      notes: json['notes'] as String?,
      lastInspection: json['lastInspection'] != null
          ? DateTime.parse(json['lastInspection'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

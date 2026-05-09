import 'dart:typed_data';

import 'package:hive/hive.dart';

import 'admin_profile.dart';

/// Tolerant decoding for [AdminProfile]: older DBs may store ints where the
/// current model expects strings (e.g. rank / IDs), which used to crash
/// `openBox` with a cast error.
class AdminProfileHiveAdapter extends TypeAdapter<AdminProfile> {
  @override
  final int typeId = 0;

  static String _str(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    return v.toString();
  }

  static String? _strN(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    return v.toString();
  }

  static int? _intN(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static bool _bool(dynamic v, [bool fallback = false]) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return fallback;
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(v);
      } catch (_) {
        return null;
      }
    }
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static DateTime _dtReq(dynamic v) {
    return _dt(v) ?? DateTime.now();
  }

  static List<String> _strList(dynamic v) {
    if (v == null) return [];
    if (v is! List) return [];
    return [
      for (final e in v)
        if (e != null) _str(e, ''),
    ];
  }

  @override
  AdminProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdminProfile(
      id: _str(fields[0], ''),
      fullName: _str(fields[1], ''),
      email: _str(fields[2], ''),
      nationality: _str(fields[3], ''),
      nationalId: _str(fields[4], ''),
      rank: _strN(fields[5]),
      age: _intN(fields[6]),
      flightHours: _intN(fields[7]),
      phones: _strList(fields[8]),
      governorate: _strN(fields[9]),
      workplace: _strN(fields[10]),
      employmentDate: _dt(fields[11]),
      hasLicense: _bool(fields[12], false),
      licenseNumber: _strN(fields[13]),
      licenseIssueDate: _dt(fields[14]),
      licenseExpiryDate: _dt(fields[15]),
      photo: _strN(fields[16]),
      password: _strN(fields[19]),
      whatsappNumbers: _strList(fields[20]),
      residenceAddress: _strN(fields[21]),
      customNationality: _strN(fields[22]),
      adminSignatureText: _strN(fields[23]),
      adminSignatureImage: fields[24] is Uint8List ? fields[24] as Uint8List : null,
      adminSignatureMode: _strN(fields[25]),
      adminSignatureSavedAt: _dt(fields[26]),
      dateOfBirth: _dt(fields[27]),
      licenseIssuingAuthority: _strN(fields[28]),
      createdAt: _dtReq(fields[17]),
      updatedAt: _dtReq(fields[18]),
    );
  }

  @override
  void write(BinaryWriter writer, AdminProfile obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.nationality)
      ..writeByte(4)
      ..write(obj.nationalId)
      ..writeByte(5)
      ..write(obj.rank)
      ..writeByte(6)
      ..write(obj.age)
      ..writeByte(7)
      ..write(obj.flightHours)
      ..writeByte(8)
      ..write(obj.phones)
      ..writeByte(9)
      ..write(obj.governorate)
      ..writeByte(10)
      ..write(obj.workplace)
      ..writeByte(11)
      ..write(obj.employmentDate)
      ..writeByte(12)
      ..write(obj.hasLicense)
      ..writeByte(13)
      ..write(obj.licenseNumber)
      ..writeByte(14)
      ..write(obj.licenseIssueDate)
      ..writeByte(15)
      ..write(obj.licenseExpiryDate)
      ..writeByte(16)
      ..write(obj.photo)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.password)
      ..writeByte(20)
      ..write(obj.whatsappNumbers)
      ..writeByte(21)
      ..write(obj.residenceAddress)
      ..writeByte(22)
      ..write(obj.customNationality)
      ..writeByte(23)
      ..write(obj.adminSignatureText)
      ..writeByte(24)
      ..write(obj.adminSignatureImage)
      ..writeByte(25)
      ..write(obj.adminSignatureMode)
      ..writeByte(26)
      ..write(obj.adminSignatureSavedAt)
      ..writeByte(27)
      ..write(obj.dateOfBirth)
      ..writeByte(28)
      ..write(obj.licenseIssuingAuthority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminProfileHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

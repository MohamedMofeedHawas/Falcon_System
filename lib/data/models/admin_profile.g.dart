// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdminProfileAdapter extends TypeAdapter<AdminProfile> {
  @override
  final int typeId = 0;

  @override
  AdminProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdminProfile(
      id: fields[0] as String,
      fullName: fields[1] as String,
      email: fields[2] as String,
      nationality: fields[3] as String,
      nationalId: fields[4] as String,
      rank: fields[5] as String?,
      age: fields[6] as int?,
      flightHours: fields[7] as int?,
      phones: (fields[8] as List?)?.cast<String>(),
      governorate: fields[9] as String?,
      workplace: fields[10] as String?,
      employmentDate: fields[11] as DateTime?,
      hasLicense: fields[12] as bool,
      licenseNumber: fields[13] as String?,
      licenseIssueDate: fields[14] as DateTime?,
      licenseExpiryDate: fields[15] as DateTime?,
      photo: fields[16] as String?,
      createdAt: fields[17] as DateTime?,
      updatedAt: fields[18] as DateTime?,
      password: fields[19] as String?,
      whatsappNumbers: (fields[20] as List?)?.cast<String>(),
      residenceAddress: fields[21] as String?,
      customNationality: fields[22] as String?,
      adminSignatureText: fields[23] as String?,
      adminSignatureImage: fields[24] as Uint8List?,
      adminSignatureMode: fields[25] as String?,
      adminSignatureSavedAt: fields[26] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AdminProfile obj) {
    writer
      ..writeByte(27)
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
      ..write(obj.adminSignatureSavedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

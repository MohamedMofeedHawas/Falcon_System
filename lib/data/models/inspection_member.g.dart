// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionMemberAdapter extends TypeAdapter<InspectionMember> {
  @override
  final int typeId = 4;

  @override
  InspectionMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionMember(
      id: fields[0] as String,
      fullName: fields[1] as String,
      specialization: fields[2] as String,
      rank: fields[3] as String?,
      notes: fields[4] as String?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
      phoneNumbers: (fields[7] as List?)?.cast<String>(),
      cvPath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InspectionMember obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.specialization)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.phoneNumbers)
      ..writeByte(8)
      ..write(obj.cvPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

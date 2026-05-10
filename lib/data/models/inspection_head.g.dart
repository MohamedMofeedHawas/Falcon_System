// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_head.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionHeadAdapter extends TypeAdapter<InspectionHead> {
  @override
  final int typeId = 3;

  @override
  InspectionHead read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionHead(
      id: fields[0] as String,
      fullName: fields[1] as String,
      specialization: fields[2] as String,
      rank: fields[3] as String?,
      signature: fields[4] as Uint8List?,
      notes: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
      phoneNumbers: (fields[8] as List?)?.cast<String>(),
      cvPath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InspectionHead obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.specialization)
      ..writeByte(3)
      ..write(obj.rank)
      ..writeByte(4)
      ..write(obj.signature)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.phoneNumbers)
      ..writeByte(9)
      ..write(obj.cvPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionHeadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

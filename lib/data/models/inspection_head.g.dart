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
    );
  }

  @override
  void write(BinaryWriter writer, InspectionHead obj) {
    writer
      ..writeByte(8)
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
      ..write(obj.updatedAt);
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

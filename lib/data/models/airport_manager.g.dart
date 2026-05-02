// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'airport_manager.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AirportManagerAdapter extends TypeAdapter<AirportManager> {
  @override
  final int typeId = 2;

  @override
  AirportManager read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AirportManager(
      id: fields[0] as String,
      fullName: fields[1] as String,
      employeeNumber: fields[2] as String,
      appointmentDate: fields[3] as DateTime,
      signature: fields[4] as Uint8List?,
      officialStamp: fields[5] as Uint8List?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AirportManager obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.employeeNumber)
      ..writeByte(3)
      ..write(obj.appointmentDate)
      ..writeByte(4)
      ..write(obj.signature)
      ..writeByte(5)
      ..write(obj.officialStamp)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirportManagerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

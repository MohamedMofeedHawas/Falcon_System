// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AircraftAdapter extends TypeAdapter<Aircraft> {
  @override
  final int typeId = 5;

  @override
  Aircraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Aircraft(
      id: fields[0] as String,
      registrationNumber: fields[1] as String,
      manufacturer: fields[2] as String,
      model: fields[3] as String,
      type: fields[4] as String,
      year: fields[5] as int?,
      engineType: fields[6] as String?,
      maxTakeoffWeight: fields[7] as int?,
      maxLandingWeight: fields[8] as int?,
      notes: fields[9] as String?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Aircraft obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.registrationNumber)
      ..writeByte(2)
      ..write(obj.manufacturer)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.year)
      ..writeByte(6)
      ..write(obj.engineType)
      ..writeByte(7)
      ..write(obj.maxTakeoffWeight)
      ..writeByte(8)
      ..write(obj.maxLandingWeight)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AircraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

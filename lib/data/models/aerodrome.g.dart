// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aerodrome.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AerodromeAdapter extends TypeAdapter<Aerodrome> {
  @override
  final int typeId = 1;

  @override
  Aerodrome read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Aerodrome(
      id: fields[0] as String,
      icaoCode: fields[1] as String,
      arabicName: fields[2] as String,
      englishName: fields[3] as String,
      creationDate: fields[4] as DateTime,
      airportType: fields[5] as String,
      governorate: fields[6] as String,
      city: fields[7] as String,
      latitude: fields[8] as double,
      longitude: fields[9] as double,
      elevation: fields[10] as double,
      operationalStatus: fields[11] as String,
      registrationNumber: fields[12] as String,
      operator: fields[13] as String,
      supervisingAuthority: fields[14] as String,
      icaoCategory: fields[15] as String,
      longestRunway: fields[16] as double,
      capacity: fields[17] as int,
      notes: fields[18] as String?,
      lastInspection: fields[19] as DateTime?,
      createdAt: fields[20] as DateTime?,
      updatedAt: fields[21] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Aerodrome obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.icaoCode)
      ..writeByte(2)
      ..write(obj.arabicName)
      ..writeByte(3)
      ..write(obj.englishName)
      ..writeByte(4)
      ..write(obj.creationDate)
      ..writeByte(5)
      ..write(obj.airportType)
      ..writeByte(6)
      ..write(obj.governorate)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.latitude)
      ..writeByte(9)
      ..write(obj.longitude)
      ..writeByte(10)
      ..write(obj.elevation)
      ..writeByte(11)
      ..write(obj.operationalStatus)
      ..writeByte(12)
      ..write(obj.registrationNumber)
      ..writeByte(13)
      ..write(obj.operator)
      ..writeByte(14)
      ..write(obj.supervisingAuthority)
      ..writeByte(15)
      ..write(obj.icaoCategory)
      ..writeByte(16)
      ..write(obj.longestRunway)
      ..writeByte(17)
      ..write(obj.capacity)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.lastInspection)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AerodromeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

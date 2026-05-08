// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apron_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApronEvaluationAdapter extends TypeAdapter<ApronEvaluation> {
  @override
  final int typeId = 14;

  @override
  ApronEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApronEvaluation(
      parkingStands: fields[0] as ApronElementScore?,
      vehicleMovement: fields[1] as ApronElementScore?,
      guidanceSystems: fields[2] as ApronElementScore?,
      floodLighting: fields[3] as ApronElementScore?,
      surfaceCondition: fields[4] as ApronElementScore?,
      supportFacilities: fields[5] as ApronElementScore?,
      waterDrainage: fields[6] as ApronElementScore?,
      conflictPoints: fields[7] as ApronElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, ApronEvaluation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.parkingStands)
      ..writeByte(1)
      ..write(obj.vehicleMovement)
      ..writeByte(2)
      ..write(obj.guidanceSystems)
      ..writeByte(3)
      ..write(obj.floodLighting)
      ..writeByte(4)
      ..write(obj.surfaceCondition)
      ..writeByte(5)
      ..write(obj.supportFacilities)
      ..writeByte(6)
      ..write(obj.waterDrainage)
      ..writeByte(7)
      ..write(obj.conflictPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApronEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runway_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunwayEvaluationAdapter extends TypeAdapter<RunwayEvaluation> {
  @override
  final int typeId = 20;

  @override
  RunwayEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RunwayEvaluation(
      runwayLength: fields[0] as RunwayElementScore?,
      runwayWidth: fields[1] as RunwayElementScore?,
      surfaceCondition: fields[2] as RunwayElementScore?,
      resa: fields[3] as RunwayElementScore?,
      markings: fields[4] as RunwayElementScore?,
      lighting: fields[5] as RunwayElementScore?,
      ofz: fields[6] as RunwayElementScore?,
      pcn: fields[7] as RunwayElementScore?,
      drainage: fields[8] as RunwayElementScore?,
      signs: fields[9] as RunwayElementScore?,
      fuelDrainage: fields[10] as RunwayElementScore?,
      edgesShoulders: fields[11] as RunwayElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, RunwayEvaluation obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.runwayLength)
      ..writeByte(1)
      ..write(obj.runwayWidth)
      ..writeByte(2)
      ..write(obj.surfaceCondition)
      ..writeByte(3)
      ..write(obj.resa)
      ..writeByte(4)
      ..write(obj.markings)
      ..writeByte(5)
      ..write(obj.lighting)
      ..writeByte(6)
      ..write(obj.ofz)
      ..writeByte(7)
      ..write(obj.pcn)
      ..writeByte(8)
      ..write(obj.drainage)
      ..writeByte(9)
      ..write(obj.signs)
      ..writeByte(10)
      ..write(obj.fuelDrainage)
      ..writeByte(11)
      ..write(obj.edgesShoulders);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunwayEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

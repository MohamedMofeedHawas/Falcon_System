// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rffs_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RffsEvaluationAdapter extends TypeAdapter<RffsEvaluation> {
  @override
  final int typeId = 12;

  @override
  RffsEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RffsEvaluation(
      icaoCategory: fields[0] as RffsElementScore?,
      fireVehicles: fields[1] as RffsElementScore?,
      extinguishingAgents: fields[2] as RffsElementScore?,
      crewReadiness: fields[3] as RffsElementScore?,
      responseTime: fields[4] as RffsElementScore?,
      communicationSystem: fields[5] as RffsElementScore?,
      trainingCoordination: fields[6] as RffsElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, RffsEvaluation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.icaoCategory)
      ..writeByte(1)
      ..write(obj.fireVehicles)
      ..writeByte(2)
      ..write(obj.extinguishingAgents)
      ..writeByte(3)
      ..write(obj.crewReadiness)
      ..writeByte(4)
      ..write(obj.responseTime)
      ..writeByte(5)
      ..write(obj.communicationSystem)
      ..writeByte(6)
      ..write(obj.trainingCoordination);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RffsEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

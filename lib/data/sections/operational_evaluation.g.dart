// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operational_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationalEvaluationAdapter extends TypeAdapter<OperationalEvaluation> {
  @override
  final int typeId = 22;

  @override
  OperationalEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OperationalEvaluation(
      groundMovement: fields[0] as OperationalElementScore?,
      aircraftMovement: fields[1] as OperationalElementScore?,
      vehicleMovement: fields[2] as OperationalElementScore?,
      emergencyPlan: fields[3] as OperationalElementScore?,
      periodicDrills: fields[4] as OperationalElementScore?,
      wildlifeManagement: fields[5] as OperationalElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, OperationalEvaluation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.groundMovement)
      ..writeByte(1)
      ..write(obj.aircraftMovement)
      ..writeByte(2)
      ..write(obj.vehicleMovement)
      ..writeByte(3)
      ..write(obj.emergencyPlan)
      ..writeByte(4)
      ..write(obj.periodicDrills)
      ..writeByte(5)
      ..write(obj.wildlifeManagement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationalEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

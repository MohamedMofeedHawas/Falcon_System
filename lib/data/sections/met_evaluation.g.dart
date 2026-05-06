// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'met_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MetEvaluationAdapter extends TypeAdapter<MetEvaluation> {
  @override
  final int typeId = 10;

  @override
  MetEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MetEvaluation(
      aviationReports: fields[0] as MetElementScore?,
      basicEquipment: fields[1] as MetElementScore?,
      advancedEquipment: fields[2] as MetElementScore?,
      informationTransfer: fields[3] as MetElementScore?,
      maintenanceCalibration: fields[4] as MetElementScore?,
      aviationForecasts: fields[5] as MetElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, MetEvaluation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.aviationReports)
      ..writeByte(1)
      ..write(obj.basicEquipment)
      ..writeByte(2)
      ..write(obj.advancedEquipment)
      ..writeByte(3)
      ..write(obj.informationTransfer)
      ..writeByte(4)
      ..write(obj.maintenanceCalibration)
      ..writeByte(5)
      ..write(obj.aviationForecasts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxiway_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaxiwayEvaluationAdapter extends TypeAdapter<TaxiwayEvaluation> {
  @override
  final int typeId = 8;

  @override
  TaxiwayEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxiwayEvaluation(
      widthClearances: fields[0] as TaxiwayElementScore?,
      groundMarkings: fields[1] as TaxiwayElementScore?,
      lighting: fields[2] as TaxiwayElementScore?,
      surfaceCondition: fields[3] as TaxiwayElementScore?,
      directionalSigns: fields[4] as TaxiwayElementScore?,
      lateralStrip: fields[5] as TaxiwayElementScore?,
      drainage: fields[6] as TaxiwayElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, TaxiwayEvaluation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.widthClearances)
      ..writeByte(1)
      ..write(obj.groundMarkings)
      ..writeByte(2)
      ..write(obj.lighting)
      ..writeByte(3)
      ..write(obj.surfaceCondition)
      ..writeByte(4)
      ..write(obj.directionalSigns)
      ..writeByte(5)
      ..write(obj.lateralStrip)
      ..writeByte(6)
      ..write(obj.drainage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxiwayEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

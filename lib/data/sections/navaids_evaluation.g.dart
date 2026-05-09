// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navaids_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NavaidsEvaluationAdapter extends TypeAdapter<NavaidsEvaluation> {
  @override
  final int typeId = 18;

  @override
  NavaidsEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NavaidsEvaluation(
      papiVasi: fields[0] as NavaidsElementScore?,
      vor: fields[1] as NavaidsElementScore?,
      dme: fields[2] as NavaidsElementScore?,
      ils: fields[3] as NavaidsElementScore?,
      atisVolmet: fields[4] as NavaidsElementScore?,
      flightInspection: fields[5] as NavaidsElementScore?,
      hasILS: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NavaidsEvaluation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.papiVasi)
      ..writeByte(1)
      ..write(obj.vor)
      ..writeByte(2)
      ..write(obj.dme)
      ..writeByte(3)
      ..write(obj.ils)
      ..writeByte(4)
      ..write(obj.atisVolmet)
      ..writeByte(5)
      ..write(obj.flightInspection)
      ..writeByte(6)
      ..write(obj.hasILS);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavaidsEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

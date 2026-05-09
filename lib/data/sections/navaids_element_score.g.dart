// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navaids_element_score.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NavaidsElementScoreAdapter extends TypeAdapter<NavaidsElementScore> {
  @override
  final int typeId = 17;

  @override
  NavaidsElementScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NavaidsElementScore(
      key: fields[0] as String,
      score: fields[1] as int,
      notes: fields[2] as String,
      subCriteriaChecked: (fields[3] as Map?)?.cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, NavaidsElementScore obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.subCriteriaChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavaidsElementScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

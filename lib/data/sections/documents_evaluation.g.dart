// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentsEvaluationAdapter extends TypeAdapter<DocumentsEvaluation> {
  @override
  final int typeId = 24;

  @override
  DocumentsEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentsEvaluation(
      aerodromeManual: fields[0] as DocumentsElementScore?,
      regularUpdates: fields[1] as DocumentsElementScore?,
      licensesValidity: fields[2] as DocumentsElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentsEvaluation obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.aerodromeManual)
      ..writeByte(1)
      ..write(obj.regularUpdates)
      ..writeByte(2)
      ..write(obj.licensesValidity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentsEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

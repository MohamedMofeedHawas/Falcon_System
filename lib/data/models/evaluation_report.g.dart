// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evaluation_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvaluationReportAdapter extends TypeAdapter<EvaluationReport> {
  @override
  final int typeId = 6;

  @override
  EvaluationReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EvaluationReport(
      id: fields[0] as String,
      aerodromeId: fields[1] as String,
      aerodromeName: fields[2] as String,
      managerId: fields[3] as String,
      managerName: fields[4] as String,
      headId: fields[5] as String,
      headName: fields[6] as String,
      memberIds: (fields[7] as List?)?.cast<String>(),
      memberNames: (fields[8] as List?)?.cast<String>(),
      aircraftId: fields[9] as String?,
      aircraftName: fields[10] as String?,
      evaluationDate: fields[11] as DateTime?,
      totalScore: fields[12] as double,
      operationalDecision: fields[13] as String,
      managerSignature: fields[14] as Uint8List?,
      headSignature: fields[15] as Uint8List?,
      reinspectionDate: fields[16] as DateTime?,
      notes: fields[17] as String?,
      createdAt: fields[18] as DateTime?,
      updatedAt: fields[19] as DateTime?,
      runwayEvaluation: (fields[20] as Map?)?.cast<String, dynamic>(),
      taxiwayEvaluation: (fields[21] as Map?)?.cast<String, dynamic>(),
      apronEvaluation: (fields[22] as Map?)?.cast<String, dynamic>(),
      rffsEvaluation: (fields[23] as Map?)?.cast<String, dynamic>(),
      metEvaluation: (fields[24] as Map?)?.cast<String, dynamic>(),
      navaidsEvaluation: (fields[25] as Map?)?.cast<String, dynamic>(),
      operationalEvaluation: (fields[26] as Map?)?.cast<String, dynamic>(),
      smsEvaluation: (fields[27] as Map?)?.cast<String, dynamic>(),
      documentsEvaluation: (fields[28] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, EvaluationReport obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.aerodromeId)
      ..writeByte(2)
      ..write(obj.aerodromeName)
      ..writeByte(3)
      ..write(obj.managerId)
      ..writeByte(4)
      ..write(obj.managerName)
      ..writeByte(5)
      ..write(obj.headId)
      ..writeByte(6)
      ..write(obj.headName)
      ..writeByte(7)
      ..write(obj.memberIds)
      ..writeByte(8)
      ..write(obj.memberNames)
      ..writeByte(9)
      ..write(obj.aircraftId)
      ..writeByte(10)
      ..write(obj.aircraftName)
      ..writeByte(11)
      ..write(obj.evaluationDate)
      ..writeByte(12)
      ..write(obj.totalScore)
      ..writeByte(13)
      ..write(obj.operationalDecision)
      ..writeByte(14)
      ..write(obj.managerSignature)
      ..writeByte(15)
      ..write(obj.headSignature)
      ..writeByte(16)
      ..write(obj.reinspectionDate)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.runwayEvaluation)
      ..writeByte(21)
      ..write(obj.taxiwayEvaluation)
      ..writeByte(22)
      ..write(obj.apronEvaluation)
      ..writeByte(23)
      ..write(obj.rffsEvaluation)
      ..writeByte(24)
      ..write(obj.metEvaluation)
      ..writeByte(25)
      ..write(obj.navaidsEvaluation)
      ..writeByte(26)
      ..write(obj.operationalEvaluation)
      ..writeByte(27)
      ..write(obj.smsEvaluation)
      ..writeByte(28)
      ..write(obj.documentsEvaluation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

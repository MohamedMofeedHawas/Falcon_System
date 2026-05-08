// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_evaluation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SmsEvaluationAdapter extends TypeAdapter<SmsEvaluation> {
  @override
  final int typeId = 16;

  @override
  SmsEvaluation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsEvaluation(
      safetyPolicy: fields[0] as SmsElementScore?,
      riskAssessment: fields[1] as SmsElementScore?,
      reportingSystem: fields[2] as SmsElementScore?,
      safetyPerformance: fields[3] as SmsElementScore?,
      smsTraining: fields[4] as SmsElementScore?,
    );
  }

  @override
  void write(BinaryWriter writer, SmsEvaluation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.safetyPolicy)
      ..writeByte(1)
      ..write(obj.riskAssessment)
      ..writeByte(2)
      ..write(obj.reportingSystem)
      ..writeByte(3)
      ..write(obj.safetyPerformance)
      ..writeByte(4)
      ..write(obj.smsTraining);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsEvaluationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

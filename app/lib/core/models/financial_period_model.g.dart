// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_period_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialPeriodModel _$FinancialPeriodModelFromJson(
  Map<String, dynamic> json,
) => FinancialPeriodModel(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  name: json['name'] as String,
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FinancialPeriodModelToJson(
  FinancialPeriodModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'name': instance.name,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

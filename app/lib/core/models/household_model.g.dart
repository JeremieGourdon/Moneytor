// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HouseholdModel _$HouseholdModelFromJson(Map<String, dynamic> json) =>
    HouseholdModel(
      id: json['id'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String? ?? 'EUR',
      defaultMonthStartDay:
          (json['default_month_start_day'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$HouseholdModelToJson(HouseholdModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'currency': instance.currency,
      'default_month_start_day': instance.defaultMonthStartDay,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

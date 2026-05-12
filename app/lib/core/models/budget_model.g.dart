// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  accountId: json['account_id'] as String,
  name: json['name'] as String,
  defaultAmount: (json['default_amount'] as num).toInt(),
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  isSystem: json['is_system'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'account_id': instance.accountId,
      'name': instance.name,
      'default_amount': instance.defaultAmount,
      'icon': instance.icon,
      'color': instance.color,
      'is_system': instance.isSystem,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

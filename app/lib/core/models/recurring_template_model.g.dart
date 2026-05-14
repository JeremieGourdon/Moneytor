// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringTemplateModel _$RecurringTemplateModelFromJson(
  Map<String, dynamic> json,
) => RecurringTemplateModel(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  accountId: json['account_id'] as String,
  budgetId: json['budget_id'] as String?,
  projectId: json['project_id'] as String?,
  amount: (json['amount'] as num).toInt(),
  description: json['description'] as String,
  type: json['type'] as String,
  cronSchedule: json['cron_schedule'] as String,
  nextExecutionDate: json['next_execution_date'] == null
      ? null
      : DateTime.parse(json['next_execution_date'] as String),
  isActive: json['is_active'] == null
      ? true
      : const SQLiteBoolConverter().fromJson(json['is_active']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$RecurringTemplateModelToJson(
  RecurringTemplateModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'account_id': instance.accountId,
  'budget_id': instance.budgetId,
  'project_id': instance.projectId,
  'amount': instance.amount,
  'description': instance.description,
  'type': instance.type,
  'cron_schedule': instance.cronSchedule,
  'next_execution_date': instance.nextExecutionDate?.toIso8601String(),
  'is_active': const SQLiteBoolConverter().toJson(instance.isActive),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  name: json['name'] as String,
  targetAmount: (json['target_amount'] as num?)?.toInt() ?? 0,
  isPinnedToDashboard: json['is_pinned_to_dashboard'] == null
      ? false
      : const SQLiteBoolConverter().fromJson(json['is_pinned_to_dashboard']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'name': instance.name,
      'target_amount': instance.targetAmount,
      'is_pinned_to_dashboard': const SQLiteBoolConverter().toJson(
        instance.isPinnedToDashboard,
      ),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

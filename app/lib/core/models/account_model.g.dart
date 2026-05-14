// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  ownerId: json['owner_id'] as String?,
  name: json['name'] as String,
  type: json['type'] as String? ?? 'checking',
  isPublic: json['is_public'] == null
      ? true
      : const SQLiteBoolConverter().fromJson(json['is_public']),
  isDefault: json['is_default'] == null
      ? false
      : const SQLiteBoolConverter().fromJson(json['is_default']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'type': instance.type,
      'is_public': const SQLiteBoolConverter().toJson(instance.isPublic),
      'is_default': const SQLiteBoolConverter().toJson(instance.isDefault),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

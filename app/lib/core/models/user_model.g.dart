// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  householdId: json['household_id'] as String,
  sharedHouseholdId: json['shared_household_id'] as String?,
  firstName: json['first_name'] as String,
  role: json['role'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'household_id': instance.householdId,
  'shared_household_id': instance.sharedHouseholdId,
  'first_name': instance.firstName,
  'role': instance.role,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

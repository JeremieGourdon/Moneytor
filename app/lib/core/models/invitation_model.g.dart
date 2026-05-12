// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) =>
    InvitationModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      invitedBy: json['invited_by'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$InvitationModelToJson(InvitationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'email': instance.email,
      'token': instance.token,
      'invited_by': instance.invitedBy,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
    };

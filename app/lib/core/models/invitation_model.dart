import 'package:json_annotation/json_annotation.dart';

part 'invitation_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InvitationModel {
  final String id;
  final String householdId;
  final String email;
  final String token;
  final String invitedBy;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;

  InvitationModel({
    required this.id,
    required this.householdId,
    required this.email,
    required this.token,
    required this.invitedBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationModelToJson(this);
}

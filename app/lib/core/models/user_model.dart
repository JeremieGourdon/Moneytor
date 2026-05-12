import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  final String id;
  final String householdId;
  final String firstName;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  UserModel({
    required this.id,
    required this.householdId,
    required this.firstName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

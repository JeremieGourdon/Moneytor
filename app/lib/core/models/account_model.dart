import 'package:json_annotation/json_annotation.dart';
import '../database/sqlite_bool_converter.dart';

part 'account_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AccountModel {
  final String id;
  final String householdId;
  final String? ownerId;
  final String name;
  final String type;

  @SQLiteBoolConverter()
  final bool isPublic;

  @SQLiteBoolConverter()
  final bool isDefault;

  final DateTime createdAt;

  final DateTime updatedAt;
  final DateTime? deletedAt;

  AccountModel({
    required this.id,
    required this.householdId,
    this.ownerId,
    required this.name,
    this.type = 'checking',
    this.isPublic = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  AccountModel copyWith({
    String? name,
    String? type,
    bool? isPublic,
    bool? isDefault,
  }) {
    return AccountModel(
      id: id,
      householdId: householdId,
      ownerId: ownerId,
      name: name ?? this.name,
      type: type ?? this.type,
      isPublic: isPublic ?? this.isPublic,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: deletedAt,
    );
  }
}

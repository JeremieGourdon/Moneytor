import 'package:json_annotation/json_annotation.dart';
import '../database/sqlite_bool_converter.dart';

part 'project_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProjectModel {
  final String id;
  final String householdId;
  final String? accountId;
  final String name;
  final int targetAmount;

  @SQLiteBoolConverter()
  final bool isPinnedToDashboard;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ProjectModel({
    required this.id,
    required this.householdId,
    this.accountId,
    required this.name,
    this.targetAmount = 0,
    this.isPinnedToDashboard = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  ProjectModel copyWith({
    String? name,
    String? accountId,
    int? targetAmount,
    bool? isPinnedToDashboard,
  }) {
    return ProjectModel(
      id: id,
      householdId: householdId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      isPinnedToDashboard: isPinnedToDashboard ?? this.isPinnedToDashboard,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: deletedAt,
    );
  }
}

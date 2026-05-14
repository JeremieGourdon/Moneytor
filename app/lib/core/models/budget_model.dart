import 'package:json_annotation/json_annotation.dart';
import '../database/sqlite_bool_converter.dart';

part 'budget_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BudgetModel {
  final String id;
  final String householdId;
  final String accountId;
  final String name;
  final int defaultAmount; // in cents
  final String? icon;
  final String? color;

  @SQLiteBoolConverter()
  final bool isDefault;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  BudgetModel({
    required this.id,
    required this.householdId,
    required this.accountId,
    required this.name,
    required this.defaultAmount,
    this.icon,
    this.color,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);
}

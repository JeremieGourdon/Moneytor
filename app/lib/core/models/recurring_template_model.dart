import 'package:json_annotation/json_annotation.dart';
import '../database/sqlite_bool_converter.dart';

part 'recurring_template_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RecurringTemplateModel {
  final String id;
  final String householdId;
  final String accountId;
  final String? budgetId;
  final String? projectId;
  final int amount;
  final String description;
  final String type; // 'income', 'expense', 'transfer'
  final String cronSchedule; // 'monthly', 'weekly'
  final DateTime? nextExecutionDate;
  
  @SQLiteBoolConverter()
  final bool isActive;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  RecurringTemplateModel({
    required this.id,
    required this.householdId,
    required this.accountId,
    this.budgetId,
    this.projectId,
    required this.amount,
    required this.description,
    required this.type,
    required this.cronSchedule,
    this.nextExecutionDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory RecurringTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringTemplateModelFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringTemplateModelToJson(this);

  RecurringTemplateModel copyWith({
    String? accountId,
    String? budgetId,
    String? projectId,
    int? amount,
    String? description,
    String? type,
    String? cronSchedule,
    DateTime? nextExecutionDate,
    bool? isActive,
  }) {
    return RecurringTemplateModel(
      id: id,
      householdId: householdId,
      accountId: accountId ?? this.accountId,
      budgetId: budgetId ?? this.budgetId,
      projectId: projectId ?? this.projectId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      cronSchedule: cronSchedule ?? this.cronSchedule,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: deletedAt,
    );
  }
}

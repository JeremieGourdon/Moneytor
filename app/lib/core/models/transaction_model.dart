import 'package:json_annotation/json_annotation.dart';
import '../database/sqlite_bool_converter.dart';

part 'transaction_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionModel {
  final String id;
  final String householdId;
  final String accountId;
  final String budgetId;
  final String? categoryId;
  final String? projectId;
  final String createdBy;
  final int amount; // In cents
  final DateTime transactionDate;
  final String? description;
  final String type; // 'income', 'expense', 'transfer'
  final String status; // 'pending', 'cleared'

  @SQLiteBoolConverter()
  final bool isReconciliation;

  @SQLiteBoolConverter()
  final bool ignoreInBalances;

  final String? linkedTransactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TransactionModel({
    required this.id,
    required this.householdId,
    required this.accountId,
    required this.budgetId,
    this.categoryId,
    this.projectId,
    required this.createdBy,
    required this.amount,
    required this.transactionDate,
    this.description,
    this.type = 'expense',
    this.status = 'cleared',
    this.isReconciliation = false,
    this.ignoreInBalances = false,
    this.linkedTransactionId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}

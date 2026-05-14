// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      householdId: json['household_id'] as String,
      accountId: json['account_id'] as String,
      budgetId: json['budget_id'] as String,
      categoryId: json['category_id'] as String?,
      projectId: json['project_id'] as String?,
      createdBy: json['created_by'] as String,
      amount: (json['amount'] as num).toInt(),
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'expense',
      status: json['status'] as String? ?? 'cleared',
      isReconciliation: json['is_reconciliation'] == null
          ? false
          : const SQLiteBoolConverter().fromJson(json['is_reconciliation']),
      ignoreInBalances: json['ignore_in_balances'] == null
          ? false
          : const SQLiteBoolConverter().fromJson(json['ignore_in_balances']),
      linkedTransactionId: json['linked_transaction_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'household_id': instance.householdId,
      'account_id': instance.accountId,
      'budget_id': instance.budgetId,
      'category_id': instance.categoryId,
      'project_id': instance.projectId,
      'created_by': instance.createdBy,
      'amount': instance.amount,
      'transaction_date': instance.transactionDate.toIso8601String(),
      'description': instance.description,
      'type': instance.type,
      'status': instance.status,
      'is_reconciliation': const SQLiteBoolConverter().toJson(
        instance.isReconciliation,
      ),
      'ignore_in_balances': const SQLiteBoolConverter().toJson(
        instance.ignoreInBalances,
      ),
      'linked_transaction_id': instance.linkedTransactionId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };

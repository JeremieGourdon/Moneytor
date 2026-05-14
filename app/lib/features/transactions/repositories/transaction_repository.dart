import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/transaction_model.dart';

part 'transaction_repository.g.dart';

class TransactionRepository {
  final DatabaseService _db;

  TransactionRepository(this._db);

  DatabaseService get dbService => _db;

  /// Streams transactions for a specific account and period.
  Stream<List<TransactionModel>> watchTransactions(
    String accountId,
    DateTime start,
    DateTime? end,
  ) {
    String sql =
        'SELECT * FROM transactions WHERE account_id = ? AND transaction_date >= ? AND deleted_at IS NULL';
    List<dynamic> params = [accountId, start.toIso8601String()];

    if (end != null) {
      sql += ' AND transaction_date < ?';
      params.add(end.toIso8601String());
    }

    sql += ' ORDER BY transaction_date DESC';

    return _db
        .watch(sql, params)
        .map(
          (rows) => rows.map((row) => TransactionModel.fromJson(row)).toList(),
        );
  }

  /// Creates a new transaction.
  Future<void> createTransaction(TransactionModel tx) async {
    await _db.execute(
      '''INSERT INTO transactions (
        id, household_id, account_id, budget_id, category_id, project_id, 
        created_by, amount, transaction_date, description, type, status, 
        is_reconciliation, ignore_in_balances, linked_transaction_id, 
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        tx.id,
        tx.householdId,
        tx.accountId,
        tx.budgetId,
        tx.categoryId,
        tx.projectId,
        tx.createdBy,
        tx.amount,
        tx.transactionDate.toIso8601String(),
        tx.description,
        tx.type,
        tx.status,
        tx.isReconciliation ? 1 : 0,
        tx.ignoreInBalances ? 1 : 0,
        tx.linkedTransactionId,
        tx.createdAt.toIso8601String(),
        tx.updatedAt.toIso8601String(),
      ],
    );
  }

  /// Calculates real balance for an account (sum of cleared transactions).
  Future<int> getRealBalance(String accountId) async {
    final row = await _db.get(
      "SELECT SUM(amount) as total FROM transactions WHERE account_id = ? AND status = 'cleared' AND deleted_at IS NULL",
      [accountId],
    );
    return row?['total'] ?? 0;
  }

  /// Updates a transaction's status and date (used for clearing pending transactions).
  Future<void> clearTransaction(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      "UPDATE transactions SET status = 'cleared', transaction_date = ?, updated_at = ? WHERE id = ?",
      [now, now, id],
    );
  }

  /// Soft deletes a transaction.
  Future<void> deleteTransaction(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      "UPDATE transactions SET deleted_at = ?, updated_at = ? WHERE id = ?",
      [now, now, id],
    );
  }

  /// Streams pending transactions for the household.
  Stream<List<TransactionModel>> watchPendingTransactions(String householdId) {
    return _db
        .watch(
          "SELECT * FROM transactions WHERE household_id = ? AND status = 'pending' AND deleted_at IS NULL ORDER BY transaction_date ASC",
          [householdId],
        )
        .map((rows) => rows.map((row) => TransactionModel.fromJson(row)).toList());
  }
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(ref.watch(databaseServiceProvider.notifier));
}

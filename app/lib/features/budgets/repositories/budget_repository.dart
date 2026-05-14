import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/budget_model.dart';

part 'budget_repository.g.dart';

class BudgetRepository {
  final DatabaseService _db;

  BudgetRepository(this._db);

  /// Streams all budgets for the household.
  Stream<List<BudgetModel>> watchBudgets(String householdId) {
    return _db
        .watch(
          'SELECT * FROM budgets WHERE household_id = ? AND deleted_at IS NULL',
          [householdId],
        )
        .map((rows) => rows.map((row) => BudgetModel.fromJson(row)).toList());
  }

  /// Streams budgets linked to a specific account.
  Stream<List<BudgetModel>> watchAccountBudgets(String accountId) {
    return _db
        .watch(
          'SELECT * FROM budgets WHERE account_id = ? AND deleted_at IS NULL',
          [accountId],
        )
        .map((rows) => rows.map((row) => BudgetModel.fromJson(row)).toList());
  }

  /// Creates a new budget.
  Future<void> createBudget(BudgetModel budget) async {
    await _db.execute(
      '''INSERT INTO budgets (
        id, household_id, account_id, name, default_amount, icon, color, is_default, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        budget.id,
        budget.householdId,
        budget.accountId,
        budget.name,
        budget.defaultAmount,
        budget.icon,
        budget.color,
        budget.isDefault ? 1 : 0,
        budget.createdAt.toIso8601String(),
        budget.updatedAt.toIso8601String(),
      ],
    );
  }

  /// Updates a budget. Default budgets cannot be modified.
  Future<void> updateBudget(BudgetModel budget) async {
    if (budget.isDefault) {
      throw Exception('Default budgets cannot be modified');
    }

    await _db.execute(
      '''UPDATE budgets SET name = ?, default_amount = ?, icon = ?, color = ?, updated_at = ?
         WHERE id = ?''',
      [
        budget.name,
        budget.defaultAmount,
        budget.icon,
        budget.color,
        DateTime.now().toUtc().toIso8601String(),
        budget.id,
      ],
    );
  }

  /// Soft deletes a budget. Default budgets cannot be deleted.
  Future<void> deleteBudget(String id) async {
    final budget = await _getBudget(id);
    if (budget?.isDefault ?? false) {
      throw Exception('Default budgets cannot be deleted');
    }

    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      'UPDATE budgets SET deleted_at = ?, updated_at = ? WHERE id = ?',
      [now, now, id],
    );
  }

  /// Sets a budget as the default for its account.
  Future<void> setAsDefault(String budgetId, String accountId) async {
    await _db.execute(
      'UPDATE budgets SET is_default = 0, updated_at = ? WHERE account_id = ? AND is_default = 1',
      [DateTime.now().toUtc().toIso8601String(), accountId],
    );
    await _db.execute(
      'UPDATE budgets SET is_default = 1, updated_at = ? WHERE id = ?',
      [DateTime.now().toUtc().toIso8601String(), budgetId],
    );
  }

  Future<BudgetModel?> _getBudget(String id) async {
    final row = await _db.get('SELECT * FROM budgets WHERE id = ?', [id]);
    if (row == null) return null;
    return BudgetModel.fromJson(row);
  }
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  return BudgetRepository(ref.watch(databaseServiceProvider.notifier));
}

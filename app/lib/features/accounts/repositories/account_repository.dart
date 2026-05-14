import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/account_model.dart';

part 'account_repository.g.dart';

class AccountRepository {
  final DatabaseService _db;

  AccountRepository(this._db);

  /// Streams all accounts for the household.
  Stream<List<AccountModel>> watchAccounts(String householdId) {
    return _db
        .watch(
          'SELECT * FROM accounts WHERE household_id = ? AND deleted_at IS NULL',
          [householdId],
        )
        .map((rows) => rows.map((row) => AccountModel.fromJson(row)).toList());
  }

  /// Fetches a single account by ID.
  Future<AccountModel?> getAccount(String id) async {
    final row = await _db.get('SELECT * FROM accounts WHERE id = ?', [id]);
    if (row == null) return null;
    return AccountModel.fromJson(row);
  }

  /// Creates a new account.
  Future<void> createAccount(AccountModel account) async {
    await _db.execute(
      'INSERT INTO accounts (id, household_id, owner_id, name, type, is_public, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        account.id,
        account.householdId,
        account.ownerId,
        account.name,
        account.type,
        account.isPublic ? 1 : 0,
        account.createdAt.toIso8601String(),
        account.updatedAt.toIso8601String(),
      ],
    );
  }

  /// Updates an account.
  Future<void> updateAccount(AccountModel account) async {
    await _db.execute(
      'UPDATE accounts SET name = ?, type = ?, is_public = ?, updated_at = ? WHERE id = ?',
      [
        account.name,
        account.type,
        account.isPublic ? 1 : 0,
        DateTime.now().toUtc().toIso8601String(),
        account.id,
      ],
    );
  }

  /// Updates an account's name.
  Future<void> updateAccountName(String id, String name) async {
    await _db.execute(
      'UPDATE accounts SET name = ?, updated_at = ? WHERE id = ?',
      [name, DateTime.now().toUtc().toIso8601String(), id],
    );
  }

  /// Soft deletes an account.
  Future<void> deleteAccount(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      'UPDATE accounts SET deleted_at = ?, updated_at = ? WHERE id = ?',
      [now, now, id],
    );
    // Cascade: Deleting account deletes all linked transactions
    await _db.execute(
      'UPDATE transactions SET deleted_at = ?, updated_at = ? WHERE account_id = ?',
      [now, now, id],
    );
  }

  /// Calculates the real-time balance of an account.
  Future<int> getBalance(String accountId) async {
    final row = await _db.get(
      "SELECT SUM(amount) as balance FROM transactions WHERE account_id = ? AND status = 'cleared' AND deleted_at IS NULL",
      [accountId],
    );
    return row?['balance'] ?? 0;
  }

  /// Executes a raw SQL command.
  Future<void> execute(String sql, [List<dynamic>? params]) async {
    await _db.execute(sql, params);
  }
}

@Riverpod(keepAlive: true)
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(ref.watch(databaseServiceProvider.notifier));
}

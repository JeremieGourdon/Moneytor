import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/account_model.dart';
import '../../household/providers/household_provider.dart';
import '../../auth/providers/profile_provider.dart';
import '../repositories/account_repository.dart';

part 'account_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<AccountModel>> accounts(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref.watch(accountRepositoryProvider).watchAccounts(household.id);
}

@riverpod
Future<int> accountBalance(Ref ref, String accountId) {
  return ref.watch(accountRepositoryProvider).getBalance(accountId);
}

@Riverpod(keepAlive: true)
class AccountNotifier extends _$AccountNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> createAccount(
    String name, {
    String type = 'checking',
    bool isPublic = false,
    int initialBalance = 0,
    bool isDefault = false,
  }) async {
    final household = await ref.read(householdProvider.future);
    if (!ref.mounted) return;

    final profile = await ref.read(profileProvider.future);
    if (!ref.mounted || household == null || profile == null) return;

    final accountId = const Uuid().v4();
    final now = DateTime.now().toUtc();

    final account = AccountModel(
      id: accountId,
      householdId: household.id,
      ownerId: isPublic ? null : profile.id, // Set owner if private
      name: name,
      type: type,
      isPublic: isPublic,
      isDefault: isDefault,
      createdAt: now,
      updatedAt: now,
    );

    final db = ref.read(databaseServiceProvider.notifier);

    await db.writeTransaction((tx) async {
      // 1. Create the account
      await tx.execute(
        'INSERT INTO accounts (id, household_id, owner_id, name, type, is_public, is_default, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          account.id,
          account.householdId,
          account.ownerId,
          account.name,
          account.type,
          account.isPublic ? 1 : 0,
          account.isDefault ? 1 : 0,
          account.createdAt.toIso8601String(),
          account.updatedAt.toIso8601String(),
        ],
      );

      // 2. Automatically create the "Unplanned" default budget for this account
      final budgetId = const Uuid().v4();
      await tx.execute(
        'INSERT INTO budgets (id, household_id, account_id, name, default_amount, icon, color, is_default, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          budgetId,
          household.id,
          accountId,
          'Unplanned',
          0,
          'help-circle',
          '#71717A',
          1, // is_default
          now.toIso8601String(),
          now.toIso8601String(),
        ],
      );

      // 3. If it's a savings account, automatically create a "Monthly Saving" project
      if (type == 'savings') {
        await tx.execute(
          'INSERT INTO projects (id, household_id, account_id, name, target_amount, is_pinned_to_dashboard, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            const Uuid().v4(),
            household.id,
            accountId,
            'Épargne Mensuelle - $name',
            0,
            0,
            now.toIso8601String(),
            now.toIso8601String(),
          ],
        );
      }

      // 4. If initial balance is set, create a reconciliation transaction
      if (initialBalance != 0) {
        await tx.execute(
          'INSERT INTO transactions (id, household_id, account_id, budget_id, created_by, amount, transaction_date, description, type, status, is_reconciliation, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            const Uuid().v4(),
            household.id,
            accountId,
            budgetId,
            profile.id,
            initialBalance,
            now.toIso8601String(),
            'Initial Balance',
            'income',
            'cleared',
            1, // is_reconciliation = true
            now.toIso8601String(),
            now.toIso8601String(),
          ],
        );
      }
    });
  }

  Future<void> updateAccountName(String id, String name) async {
    await ref.read(accountRepositoryProvider).updateAccountName(id, name);
  }

  Future<void> deleteAccount(AccountModel account) async {
    if (account.isDefault) {
      throw Exception('Impossible de supprimer le compte par défaut.');
    }
    await ref.read(accountRepositoryProvider).deleteAccount(account.id);
  }

  Future<void> setAsDefault(AccountModel account) async {
    await ref
        .read(accountRepositoryProvider)
        .setAsDefault(account.id, account.householdId);
  }

  Future<void> togglePrivacy(AccountModel account) async {
    final updated = account.copyWith(isPublic: !account.isPublic);
    await ref.read(accountRepositoryProvider).updateAccount(updated);
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/transaction_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../household/providers/household_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../periods/providers/period_provider.dart';
import '../../accounts/providers/account_provider.dart';
import '../repositories/transaction_repository.dart';

part 'transaction_provider.g.dart';

@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> addTransaction({
    required String accountId,
    required String budgetId,
    required int amount, // in cents
    required bool isExpense,
    String? note,
  }) async {
    final household = await ref.read(householdProvider.future);
    final user = await ref.read(authStateProvider.future);
    if (household == null || user == null) return;

    final tx = TransactionModel(
      id: const Uuid().v4(),
      householdId: household.id,
      accountId: accountId,
      budgetId: budgetId,
      createdBy: user.id,
      amount: isExpense ? -amount.abs() : amount.abs(),
      transactionDate: DateTime.now().toUtc(),
      description: note,
      status: 'cleared', // Default to cleared for manual entry
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await ref.read(transactionRepositoryProvider).createTransaction(tx);
  }
}

/// A provider that calculates the RAV (Disposable Income) for an account.
@Riverpod(keepAlive: true)
Stream<int> disposableIncome(Ref ref, String accountId) async* {
  final household = ref.watch(householdProvider).value;
  final period = ref.watch(currentPeriodProvider).value;
  if (household == null || period == null) {
    yield 0;
    return;
  }

  final repository = ref.watch(transactionRepositoryProvider);
  final budgets = ref.watch(allBudgetsProvider).value ?? [];
  final accountBudgets = budgets
      .where((b) => b.accountId == accountId)
      .toList();

  Future<int> calculate() async {
    // 1. Get Real Balance (sum of cleared transactions for the account)
    final realBalance = await repository.getRealBalance(accountId);

    // 2. For each budget linked to the account, calculate current spending in period
    int plannedDeduction = 0;

    for (final budget in accountBudgets) {
      final spentInPeriodRow = await repository.dbService.get(
        '''SELECT SUM(amount) as total FROM transactions 
           WHERE budget_id = ? 
           AND transaction_date >= ? 
           AND (transaction_date < ? OR ? IS NULL)
           AND deleted_at IS NULL''',
        [
          budget.id,
          period.startDate.toIso8601String(),
          period.endDate?.toIso8601String(),
          period.endDate,
        ],
      );

      final spentInPeriod = (spentInPeriodRow?['total'] as int? ?? 0).abs();

      if (spentInPeriod < budget.defaultAmount) {
        plannedDeduction += (budget.defaultAmount - spentInPeriod);
      }
    }

    return realBalance - plannedDeduction;
  }

  // Yield initial value immediately
  yield await calculate();

  // Then watch for ANY transaction changes in the household to trigger recalculation
  yield* repository.dbService
      .watch('SELECT 1 FROM transactions WHERE household_id = ? LIMIT 1', [
        household.id,
      ])
      .asyncMap((_) => calculate());
}

@Riverpod(keepAlive: true)
int totalDisposableIncome(Ref ref) {
  final accountsAsync = ref.watch(accountsProvider);

  // Use .value to get the latest data, or return 0 if still loading initial list
  final accountsList = accountsAsync.value ?? [];
  // Include both checking and savings as they are considered liquid "available" money
  final liquidAccounts = accountsList
      .where((a) => a.type == 'checking' || a.type == 'savings')
      .toList();

  if (liquidAccounts.isEmpty) {
    return 0;
  }

  int total = 0;

  for (final account in liquidAccounts) {
    final ravAsync = ref.watch(disposableIncomeProvider(account.id));
    // If it's loading, we just use 0 for now to avoid the whole total being "loading"
    total += ravAsync.value ?? 0;
  }

  return total;
}

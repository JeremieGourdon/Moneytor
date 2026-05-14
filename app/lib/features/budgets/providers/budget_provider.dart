import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/budget_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/budget_repository.dart';

part 'budget_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<BudgetModel>> allBudgets(Ref ref) {
  final household = ref.watch(householdProvider).value;
  developer.log('allBudgetsProvider: household is ${household?.id}', name: 'budget.provider');
  if (household == null) return Stream.value([]);

  return ref.watch(budgetRepositoryProvider).watchBudgets(household.id);
}

@riverpod
Stream<List<BudgetModel>> accountBudgets(Ref ref, String accountId) {
  return ref.watch(budgetRepositoryProvider).watchAccountBudgets(accountId);
}

@riverpod
class BudgetNotifier extends _$BudgetNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> createBudget({
    required String accountId,
    required String name,
    required int amount,
    String? icon,
    String? color,
  }) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final budget = BudgetModel(
      id: const Uuid().v4(),
      householdId: household.id,
      accountId: accountId,
      name: name,
      defaultAmount: amount,
      icon: icon,
      color: color,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await ref.read(budgetRepositoryProvider).createBudget(budget);
  }

  Future<void> updateBudget(BudgetModel budget) async {
    await ref.read(budgetRepositoryProvider).updateBudget(budget);
  }

  Future<void> deleteBudget(BudgetModel budget) async {
    if (budget.isDefault) {
      throw Exception('Impossible de supprimer le budget par défaut.');
    }
    await ref.read(budgetRepositoryProvider).deleteBudget(budget.id);
  }

  Future<void> setAsDefault(BudgetModel budget) async {
    await ref
        .read(budgetRepositoryProvider)
        .setAsDefault(budget.id, budget.accountId);
  }
}

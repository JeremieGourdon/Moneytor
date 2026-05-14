import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/budget_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/budget_repository.dart';

part 'budget_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<BudgetModel>> allBudgets(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref.watch(budgetRepositoryProvider).watchBudgets(household.id);
}

@riverpod
Stream<List<BudgetModel>> accountBudgets(Ref ref, String accountId) {
  return ref.watch(budgetRepositoryProvider).watchAccountBudgets(accountId);
}

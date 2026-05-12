import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/financial_period_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/financial_period_repository.dart';

part 'period_provider.g.dart';

@riverpod
Stream<FinancialPeriodModel?> currentPeriod(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value(null);

  return ref.watch(financialPeriodRepositoryProvider).watchCurrentPeriod(household.id);
}

@riverpod
class PeriodNotifier extends _$PeriodNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> delayPeriod() async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final current = await ref.read(currentPeriodProvider.future);
    if (current == null) return;

    // Delay start of next period by +1 day = update current period's projected end?
    // Our spec says: "Pushes the start of the next period by +1 day. This extends the current period's duration."
    // Since end_date of current is NULL until next starts, we might need a way to track the projected start.
    // For now, let's just log or implement a simple metadata update if we had a 'projected_end_date'.
  }

  Future<void> startNextPeriod() async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final now = DateTime.now().toUtc();
    final name = '${now.month}/${now.year}'; // Simple naming

    await ref.read(financialPeriodRepositoryProvider).startNewPeriod(
      household.id,
      name,
      now,
    );
  }
}

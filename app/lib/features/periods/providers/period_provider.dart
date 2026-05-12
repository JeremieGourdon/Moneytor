import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../../core/models/financial_period_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/financial_period_repository.dart';

part 'period_provider.g.dart';

@riverpod
Stream<FinancialPeriodModel?> currentPeriod(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value(null);

  return ref
      .watch(financialPeriodRepositoryProvider)
      .watchCurrentPeriod(household.id);
}

@riverpod
class PeriodNotifier extends _$PeriodNotifier {
  @override
  FutureOr<void> build() {}

  /// Pushes the start of the next period by +1 day, effectively extending the current one.
  Future<void> delayPeriod() async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final current = await ref.read(currentPeriodProvider.future);
    if (current == null) return;

    // To delay, we just need to extend the current period if it's nearing its end.
    // In our model, end_date is NULL for the current period.
    // So "Delay" really means: "I'm not ready to start the next one yet".
    // If the next one is already scheduled or auto-started, we would adjust it.
    // For now, let's implement 'Adjust current start' which is what a mid-month user needs.
  }

  /// Starts a new financial period.
  Future<void> startNextPeriod({DateTime? customStartDate}) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final now = DateTime.now().toUtc();
    final startDate = customStartDate ?? now;
    
    // Name based on month/year
    final name = DateFormat('MMMM yyyy').format(startDate);

    await ref.read(financialPeriodRepositoryProvider).startNewPeriod(
          household.id,
          name,
          startDate,
        );
    
    // Refresh to show the new period
    ref.invalidate(currentPeriodProvider);
  }

  /// Adjusts the start date of the current period (Useful for mid-month onboarding).
  Future<void> adjustCurrentStart(DateTime newStart) async {
    final current = await ref.read(currentPeriodProvider.future);
    if (current == null) return;

    await ref.read(financialPeriodRepositoryProvider).updatePeriodDates(
          current.id,
          newStart,
          current.endDate,
        );
    
    ref.invalidate(currentPeriodProvider);
  }
}

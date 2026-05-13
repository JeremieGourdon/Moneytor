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
Stream<List<FinancialPeriodModel>> allPeriods(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref
      .watch(financialPeriodRepositoryProvider)
      .watchPeriods(household.id);
}

@riverpod
class PeriodNotifier extends _$PeriodNotifier {
  @override
  FutureOr<void> build() async {
    // Check if we need to auto-initialize the first period
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final current = await ref.read(currentPeriodProvider.future);
    if (current == null) {
      // Auto-start on the 1st of the current month by default
      final now = DateTime.now().toUtc();
      final start = DateTime.utc(now.year, now.month, 1);
      await startNextPeriod(customStartDate: start);
    }
  }

  /// Pushes the start of the next period by +1 day.
  /// Effectively, if the next period hasn't started yet, we just wait.
  /// In our model, we just need to know when we WANT to start.
  Future<void> delayPeriod() async {
    // This will be handled by the UI "Start Next" action.
    // If user clicks "Delay", they simply don't click "Start Next".
  }

  /// Starts a new financial period, automatically closing the previous one.
  Future<void> startNextPeriod({DateTime? customStartDate}) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final startDate = (customStartDate ?? DateTime.now()).toUtc();
    final name = DateFormat('MMMM yyyy').format(startDate);

    await ref.read(financialPeriodRepositoryProvider).startNewPeriod(
          household.id,
          name,
          startDate,
        );
    
    ref.invalidate(currentPeriodProvider);
    ref.invalidate(allPeriodsProvider);
  }

  /// Adjusts the end date of a period, which shifts the start of the next one.
  Future<void> adjustPeriodEnd(String periodId, DateTime newEnd) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    await ref.read(financialPeriodRepositoryProvider).updatePeriodEnd(
      periodId,
      newEnd.toUtc(),
      household.id,
    );

    ref.invalidate(currentPeriodProvider);
    ref.invalidate(allPeriodsProvider);
  }

  /// Global setting: update the default month start day.
  Future<void> updateDefaultStartDay(int day) async {
    await ref.read(householdProvider.notifier).updateDefaultStartDay(day);
  }
}

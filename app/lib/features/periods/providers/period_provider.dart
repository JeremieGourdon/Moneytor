import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../../core/models/financial_period_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/financial_period_repository.dart';

part 'period_provider.g.dart';

@Riverpod(keepAlive: true)
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
      // Auto-start on the 1st of the current month,
      // but NOT before the household was created.
      final now = DateTime.now().toUtc();
      DateTime start = DateTime.utc(now.year, now.month, 1);

      if (start.isBefore(household.createdAt)) {
        start = household.createdAt;
      }

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

    DateTime startDate = (customStartDate ?? DateTime.now()).toUtc();

    // Clamp to household creation date
    if (startDate.isBefore(household.createdAt)) {
      startDate = household.createdAt;
    }

    // Improve Naming: Try to increment from the last period's name
    final periods = await ref.read(allPeriodsProvider.future);
    String name;

    if (periods.isNotEmpty) {
      final lastPeriod =
          periods.first; // allPeriods is ORDER BY start_date DESC
      try {
        final lastDate = DateFormat('MMMM yyyy').parse(lastPeriod.name);
        final nextDate = DateTime(lastDate.year, lastDate.month + 1);
        name = DateFormat('MMMM yyyy').format(nextDate);
      } catch (_) {
        name = DateFormat('MMMM yyyy').format(startDate);
      }
    } else {
      // First period ever
      name = DateFormat('MMMM yyyy').format(startDate);
    }

    await ref
        .read(financialPeriodRepositoryProvider)
        .startNewPeriod(household.id, name, startDate);

    ref.invalidate(currentPeriodProvider);
    ref.invalidate(allPeriodsProvider);
  }

  /// Adjusts the end date of a period, which shifts the start of the next one.
  Future<void> adjustPeriodEnd(String periodId, DateTime newEnd) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    DateTime adjustedEnd = newEnd.toUtc();

    // Safety check: Cannot end a period before it starts or before household creation
    // The repository handles contiguity, but we can clamp here too.
    if (adjustedEnd.isBefore(household.createdAt)) {
      adjustedEnd = household.createdAt;
    }

    await ref
        .read(financialPeriodRepositoryProvider)
        .updatePeriodEnd(periodId, adjustedEnd, household.id);

    ref.invalidate(currentPeriodProvider);
    ref.invalidate(allPeriodsProvider);
  }

  /// Global setting: update the default month start day.
  Future<void> updateDefaultStartDay(int day) async {
    await ref.read(householdProvider.notifier).updateDefaultStartDay(day);
  }
}

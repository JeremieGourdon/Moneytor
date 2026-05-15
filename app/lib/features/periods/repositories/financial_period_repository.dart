import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/financial_period_model.dart';

part 'financial_period_repository.g.dart';

class FinancialPeriodRepository {
  final DatabaseService _db;

  FinancialPeriodRepository(this._db);

  /// Streams the current active financial period.
  Stream<FinancialPeriodModel?> watchCurrentPeriod(String householdId) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _db
        .watch(
          'SELECT * FROM financial_periods WHERE household_id = ? AND start_date <= ? AND end_date > ? ORDER BY start_date DESC LIMIT 1',
          [householdId, now, now],
        )
        .map(
          (rows) => rows.isNotEmpty
              ? FinancialPeriodModel.fromJson(rows.first)
              : null,
        );
  }

  /// Streams all periods for history.
  Stream<List<FinancialPeriodModel>> watchPeriods(String householdId) {
    return _db
        .watch(
          'SELECT * FROM financial_periods WHERE household_id = ? ORDER BY start_date DESC',
          [householdId],
        )
        .map(
          (rows) =>
              rows.map((row) => FinancialPeriodModel.fromJson(row)).toList(),
        );
  }

  /// Creates a new financial period and closes the previous one.
  Future<void> startNewPeriod(
    String householdId,
    String name,
    DateTime startDate,
  ) async {
    // 1. Close current period
    await _db.execute(
      'UPDATE financial_periods SET end_date = ?, updated_at = ? WHERE household_id = ? AND end_date IS NULL',
      [
        startDate.toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
        householdId,
      ],
    );

    // 2. Insert new period
    await _db.execute(
      'INSERT INTO financial_periods (id, household_id, name, start_date, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      [
        const Uuid().v4(),
        householdId,
        name,
        startDate.toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
      ],
    );
  }

  /// Updates a period's dates and ensures contiguity with neighbours.
  Future<void> updatePeriodEnd(
    String periodId,
    DateTime newEnd,
    String householdId,
  ) async {
    // 1. Update the end_date of this period
    await _db.execute(
      'UPDATE financial_periods SET end_date = ?, updated_at = ? WHERE id = ?',
      [
        newEnd.toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
        periodId,
      ],
    );

    // 2. Update the start_date of the NEXT period (the one whose start_date matches previous end_date)
    // In our chained model, the next period's start_date should be updated to newEnd.
    await _db.execute(
      'UPDATE financial_periods SET start_date = ?, updated_at = ? WHERE household_id = ? AND start_date > (SELECT start_date FROM financial_periods WHERE id = ?) ORDER BY start_date ASC LIMIT 1',
      [
        newEnd.toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
        householdId,
        periodId,
      ],
    );
  }

  /// Helper to update a single period (Error correction)
  Future<void> updatePeriodDates(
    String id,
    DateTime start,
    DateTime? end,
  ) async {
    await _db.execute(
      'UPDATE financial_periods SET start_date = ?, end_date = ?, updated_at = ? WHERE id = ?',
      [
        start.toIso8601String(),
        end?.toIso8601String(),
        DateTime.now().toUtc().toIso8601String(),
        id,
      ],
    );
  }
}

@Riverpod(keepAlive: true)
FinancialPeriodRepository financialPeriodRepository(Ref ref) {
  return FinancialPeriodRepository(ref.watch(databaseServiceProvider.notifier));
}

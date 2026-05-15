import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/recurring_template_model.dart';

part 'recurring_template_repository.g.dart';

class RecurringTemplateRepository {
  final DatabaseService _db;

  RecurringTemplateRepository(this._db);

  /// Streams all recurring templates for the household.
  Stream<List<RecurringTemplateModel>> watchTemplates(String householdId) {
    return _db
        .watch(
          'SELECT * FROM recurring_templates WHERE household_id = ? AND deleted_at IS NULL',
          [householdId],
        )
        .map(
          (rows) =>
              rows.map((row) => RecurringTemplateModel.fromJson(row)).toList(),
        );
  }

  /// Creates a new recurring template.
  Future<void> createTemplate(RecurringTemplateModel template) async {
    await _db.execute(
      '''INSERT INTO recurring_templates (
        id, household_id, account_id, budget_id, project_id, amount, description, 
        type, cron_schedule, next_execution_date, is_active, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        template.id,
        template.householdId,
        template.accountId,
        template.budgetId,
        template.projectId,
        template.amount.toString(),
        template.description,
        template.type,
        template.cronSchedule,
        template.nextExecutionDate?.toIso8601String(),
        template.isActive ? 1 : 0,
        template.createdAt.toIso8601String(),
        template.updatedAt.toIso8601String(),
      ],
    );
  }

  /// Updates a recurring template.
  Future<void> updateTemplate(RecurringTemplateModel template) async {
    await _db.execute(
      '''UPDATE recurring_templates SET 
        account_id = ?, budget_id = ?, project_id = ?, amount = ?, 
        description = ?, type = ?, cron_schedule = ?, next_execution_date = ?, 
        is_active = ?, updated_at = ?
         WHERE id = ?''',
      [
        template.accountId,
        template.budgetId,
        template.projectId,
        template.amount.toString(),
        template.description,
        template.type,
        template.cronSchedule,
        template.nextExecutionDate?.toIso8601String(),
        template.isActive ? 1 : 0,
        DateTime.now().toUtc().toIso8601String(),
        template.id,
      ],
    );
  }

  /// Soft deletes a recurring template.
  Future<void> deleteTemplate(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      'UPDATE recurring_templates SET deleted_at = ?, updated_at = ? WHERE id = ?',
      [now, now, id],
    );
  }
}

@Riverpod(keepAlive: true)
RecurringTemplateRepository recurringTemplateRepository(Ref ref) {
  return RecurringTemplateRepository(
    ref.watch(databaseServiceProvider.notifier),
  );
}

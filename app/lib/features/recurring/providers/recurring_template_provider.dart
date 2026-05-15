import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/recurring_template_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/recurring_template_repository.dart';

part 'recurring_template_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<RecurringTemplateModel>> allRecurringTemplates(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref
      .watch(recurringTemplateRepositoryProvider)
      .watchTemplates(household.id);
}

@riverpod
class RecurringTemplateNotifier extends _$RecurringTemplateNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> createTemplate({
    required String accountId,
    String? budgetId,
    String? projectId,
    required String description,
    required int amount,
    required String type,
    required String frequency, // 'monthly', 'weekly'
    required DateTime startDate,
  }) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final template = RecurringTemplateModel(
      id: const Uuid().v4(),
      householdId: household.id,
      accountId: accountId,
      budgetId: budgetId,
      projectId: projectId,
      amount: amount,
      description: description,
      type: type,
      cronSchedule: frequency,
      nextExecutionDate: startDate,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await ref
        .read(recurringTemplateRepositoryProvider)
        .createTemplate(template);
  }

  Future<void> updateTemplate(RecurringTemplateModel template) async {
    await ref
        .read(recurringTemplateRepositoryProvider)
        .updateTemplate(template);
  }

  Future<void> deleteTemplate(String id) async {
    await ref.read(recurringTemplateRepositoryProvider).deleteTemplate(id);
  }

  Future<void> toggleStatus(RecurringTemplateModel template) async {
    final updated = template.copyWith(isActive: !template.isActive);
    await ref.read(recurringTemplateRepositoryProvider).updateTemplate(updated);
  }
}

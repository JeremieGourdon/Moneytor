import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/project_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/project_repository.dart';

part 'project_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<ProjectModel>> allProjects(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref.watch(projectRepositoryProvider).watchProjects(household.id);
}

@Riverpod(keepAlive: true)
Stream<int> projectSpent(Ref ref, String projectId) {
  return ref.watch(projectRepositoryProvider).watchProjectSpent(projectId);
}

@Riverpod(keepAlive: true)
Stream<int> projectDebt(Ref ref, String projectId) {
  final repository = ref.watch(projectRepositoryProvider);

  // Debt = Sum of transactions for this project paid by PERSONAL accounts
  // where ignore_in_balances is false.
  return repository.dbService
      .watch(
        '''
    SELECT SUM(t.amount) as total 
    FROM transactions t
    JOIN accounts a ON t.account_id = a.id
    WHERE t.project_id = ? 
    AND a.owner_id IS NOT NULL 
    AND t.ignore_in_balances = 0
    AND t.deleted_at IS NULL
    ''',
        [projectId],
      )
      .map((rows) => rows.first['total'] ?? 0);
}

@riverpod
class ProjectNotifier extends _$ProjectNotifier {
  @override
  FutureOr<void> build() async {}

  Future<void> createProject(String name, int targetAmount) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final project = ProjectModel(
      id: const Uuid().v4(),
      householdId: household.id,
      name: name,
      targetAmount: targetAmount,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await ref.read(projectRepositoryProvider).createProject(project);
  }

  Future<void> absorbDebt(String projectId) async {
    // Flag all transactions for this project as "ignored in balances" (gift)
    await ref
        .read(projectRepositoryProvider)
        .dbService
        .execute(
          '''
      UPDATE transactions 
      SET ignore_in_balances = 1, updated_at = ?
      WHERE project_id = ? AND ignore_in_balances = 0 AND deleted_at IS NULL
      ''',
          [DateTime.now().toUtc().toIso8601String(), projectId],
        );
  }
}

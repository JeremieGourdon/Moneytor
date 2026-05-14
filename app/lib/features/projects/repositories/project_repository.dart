import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/project_model.dart';

part 'project_repository.g.dart';

class ProjectRepository {
  final DatabaseService _db;

  ProjectRepository(this._db);

  /// Streams all projects for the household.
  Stream<List<ProjectModel>> watchProjects(String householdId) {
    return _db
        .watch(
          'SELECT * FROM projects WHERE household_id = ? AND deleted_at IS NULL',
          [householdId],
        )
        .map((rows) => rows.map((row) => ProjectModel.fromJson(row)).toList());
  }

  /// Creates a new project.
  Future<void> createProject(ProjectModel project) async {
    await _db.execute(
      '''INSERT INTO projects (
        id, household_id, name, target_amount, is_pinned_to_dashboard, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        project.id,
        project.householdId,
        project.name,
        project.targetAmount.toString(), // SQLite BIGINT mapping
        project.isPinnedToDashboard ? 1 : 0,
        project.createdAt.toIso8601String(),
        project.updatedAt.toIso8601String(),
      ],
    );
  }

  /// Updates a project.
  Future<void> updateProject(ProjectModel project) async {
    await _db.execute(
      '''UPDATE projects SET name = ?, target_amount = ?, is_pinned_to_dashboard = ?, updated_at = ?
         WHERE id = ?''',
      [
        project.name,
        project.targetAmount.toString(),
        project.isPinnedToDashboard ? 1 : 0,
        DateTime.now().toUtc().toIso8601String(),
        project.id,
      ],
    );
  }

  /// Soft deletes a project.
  Future<void> deleteProject(String id) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.execute(
      'UPDATE projects SET deleted_at = ?, updated_at = ? WHERE id = ?',
      [now, now, id],
    );
  }

  DatabaseService get dbService => _db;

  /// Streams the total spent for a project.
  Stream<int> watchProjectSpent(String projectId) {
    return _db
        .watch(
          "SELECT SUM(amount) as total FROM transactions WHERE project_id = ? AND deleted_at IS NULL",
          [projectId],
        )
        .map((rows) => rows.first['total'] ?? 0);
  }

  /// Calculates the total spent for a project.
  /// Detects transactions where project_id matches.
  Future<int> getProjectSpent(String projectId) async {
    final row = await _db.get(
      "SELECT SUM(amount) as total FROM transactions WHERE project_id = ? AND deleted_at IS NULL",
      [projectId],
    );
    return row?['total'] ?? 0;
  }

  /// Detects "debt" (Vegas Rule): Transactions where Account X pays for Project Y.
  /// In this app, all transactions for a project that are NOT reconciliations
  /// contribute to the "spent" amount.
  /// Debt specifically refers to the imbalance between Joint Accounts and Personal Accounts
  /// if they contribute to the same project.
  /// Wait, the spec says: "Detects when Account X pays for Project Y."
  /// "Mini-Tricount: A conditional warning box: 'Déséquilibre : The Joint Account owes you [Amount]'"

  // To implement this, we need to know:
  // 1. Who paid (account_id -> owner_id)
  // 2. For what (project_id)
  // 3. Is it a joint account? (account.owner_id == null)
}

@Riverpod(keepAlive: true)
ProjectRepository projectRepository(Ref ref) {
  return ProjectRepository(ref.watch(databaseServiceProvider.notifier));
}

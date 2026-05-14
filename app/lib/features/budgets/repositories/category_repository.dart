import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/category_model.dart';

part 'category_repository.g.dart';

class CategoryRepository {
  final DatabaseService _db;

  CategoryRepository(this._db);

  /// Streams all categories for the household.
  Stream<List<CategoryModel>> watchCategories(String householdId) {
    return _db
        .watch(
          'SELECT * FROM categories WHERE household_id = ? AND deleted_at IS NULL',
          [householdId],
        )
        .map((rows) => rows.map((row) => CategoryModel.fromJson(row)).toList());
  }

  /// Creates a new category.
  Future<void> createCategory(CategoryModel category) async {
    await _db.execute(
      '''INSERT INTO categories (
        id, household_id, name, icon, color, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [
        category.id,
        category.householdId,
        category.name,
        category.icon,
        category.color,
        category.createdAt.toIso8601String(),
        category.updatedAt.toIso8601String(),
      ],
    );
  }
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(ref.watch(databaseServiceProvider.notifier));
}

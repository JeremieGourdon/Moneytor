import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/category_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/category_repository.dart';

part 'category_provider.g.dart';

@riverpod
Stream<List<CategoryModel>> categories(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref.watch(categoryRepositoryProvider).watchCategories(household.id);
}

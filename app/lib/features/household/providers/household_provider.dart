import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/household_model.dart';
import '../../auth/providers/profile_provider.dart';
import '../repositories/household_repository.dart';

part 'household_provider.g.dart';

@riverpod
class HouseholdNotifier extends _$HouseholdNotifier {
  @override
  FutureOr<HouseholdModel?> build() async {
    final profile = await ref.watch(profileProvider.future);
    if (profile == null) return null;

    final repository = ref.watch(householdRepositoryProvider);
    return await repository.getHousehold(profile.householdId);
  }

  Future<void> createHousehold(String name) async {
    final profile = await ref.read(profileProvider.future);
    if (profile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final household = await ref
          .read(householdRepositoryProvider)
          .createHousehold(name, profile.id);
      
      // Refresh profile to get updated household_id
      ref.invalidate(profileProvider);
      return household;
    });
  }

  Future<void> acceptInvitation(String token) async {
    final profile = await ref.read(profileProvider.future);
    if (profile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(householdRepositoryProvider)
          .acceptInvitation(token, profile.id);
      
      ref.invalidate(profileProvider);
      return await ref.read(householdRepositoryProvider).getHousehold(token); // Temporary
    });
  }
}

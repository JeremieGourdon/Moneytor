import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/household_model.dart';
import '../../auth/providers/profile_provider.dart';
import '../repositories/household_repository.dart';

part 'household_provider.g.dart';

@Riverpod(keepAlive: true)
class HouseholdNotifier extends _$HouseholdNotifier {
  @override
  FutureOr<HouseholdModel?> build() async {
    final profile = await ref.watch(profileProvider.future);
    if (profile == null) return null;

    final repository = ref.watch(householdRepositoryProvider);
    return await repository.getHousehold(profile.householdId);
  }

  Future<void> createHousehold(String name, {int startDay = 1}) async {
    final profile = await ref.read(profileProvider.future);
    if (profile == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final household = await ref
          .read(householdRepositoryProvider)
          .createHousehold(name, profile.id, startDay: startDay);

      ref.invalidate(profileProvider);
      return household;
    });
  }

  Future<void> updateDefaultStartDay(int day) async {
    final household = state.value;
    if (household == null) return;

    final updated = household.copyWith(defaultMonthStartDay: day);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(householdRepositoryProvider).updateHousehold(updated);
      return updated;
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
      // After accepting, we need to fetch the newly joined household
      final newProfile = await ref.read(profileProvider.future);
      return await ref
          .read(householdRepositoryProvider)
          .getHousehold(newProfile!.householdId);
    });
  }
}

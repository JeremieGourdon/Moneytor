import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/household_model.dart';
import '../../auth/providers/auth_provider.dart';
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
    // Returns the personal household by default
    return await repository.getHousehold(profile.householdId);
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
    final User? authState = await ref.read(authStateProvider.future);
    if (authState == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(householdRepositoryProvider)
          .acceptInvitation(token, authState.id);

      ref.invalidate(profileProvider);
      // After accepting, we return the personal one as the main context,
      // but the shared data will start syncing automatically.
      final newProfile = await ref.read(profileProvider.future);
      return await ref
          .read(householdRepositoryProvider)
          .getHousehold(newProfile!.householdId);
    });
  }
}

@Riverpod(keepAlive: true)
Future<HouseholdModel?> sharedHousehold(Ref ref) async {
  final profile = await ref.watch(profileProvider.future);
  if (profile?.sharedHouseholdId == null) return null;

  final repository = ref.watch(householdRepositoryProvider);
  return await repository.getHousehold(profile!.sharedHouseholdId!);
}

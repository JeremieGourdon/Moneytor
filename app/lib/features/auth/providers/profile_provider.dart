import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/user_model.dart';
import '../repositories/profile_repository.dart';
import 'auth_provider.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<UserModel?> build() async {
    final authState = await ref.watch(authStateProvider.future);
    if (authState == null) return null;

    final repository = ref.watch(profileRepositoryProvider);
    return await repository.getProfile(authState.id);
  }

  Future<void> updateProfile(UserModel user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).updateProfile(user);
      return user;
    });
  }
}

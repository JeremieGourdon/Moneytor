import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  Stream<User?> build() {
    final repository = ref.watch(authRepositoryProvider);
    return repository.authStateChanges
        .map((event) => event.session?.user)
        .asBroadcastStream();
  }

  Future<void> signIn(String email, String password) async {
    await ref.read(authRepositoryProvider).signIn(email, password);
  }

  Future<void> signUp(String email, String password) async {
    await ref.read(authRepositoryProvider).signUp(email, password);
  }

  Future<void> signInWithMagicLink(String email) async {
    await ref.read(authRepositoryProvider).signInWithMagicLink(email);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthState extends _$AuthState {
  @override
  User? build() {
    final client = Supabase.instance.client;

    // Listen for auth state changes and update our state
    final subscription = client.auth.onAuthStateChange.listen((data) {
      state = data.session?.user;
    });

    ref.onDispose(() => subscription.cancel());

    // IMPORTANT: Return the current user immediately if already available
    // after Supabase.initialize() has completed.
    return client.auth.currentUser;
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

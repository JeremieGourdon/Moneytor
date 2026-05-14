import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// Returns the current authenticated user from Supabase.
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign in with Email and Password (for MVP, we'll use this alongside Magic Link).
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with Email and Password.
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  /// Sign in with Magic Link.
  Future<void> signInWithMagicLink(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'com.moneytor.app://login-callback',
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

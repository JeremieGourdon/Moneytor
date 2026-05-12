import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/user_model.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  /// Fetches the profile for the given user ID.
  Future<UserModel?> getProfile(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Updates the user's profile.
  Future<void> updateProfile(UserModel user) async {
    await _supabase.from('users').upsert(user.toJson());
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(Supabase.instance.client);
}

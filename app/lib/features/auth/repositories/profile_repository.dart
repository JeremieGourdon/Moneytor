import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/user_model.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final DatabaseService _db;

  ProfileRepository(this._db);

  /// Fetches the profile for the given user ID from local SQLite (PowerSync).
  Future<UserModel?> getProfile(String userId) async {
    final response = await _db.get(
      'SELECT * FROM users WHERE id = ?',
      [userId],
    );

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Updates the user's profile.
  Future<void> updateProfile(UserModel user) async {
    await _db.execute(
      '''UPDATE users SET 
         household_id = ?, 
         shared_household_id = ?, 
         first_name = ?, 
         role = ?, 
         updated_at = ?
         WHERE id = ?''',
      [
        user.householdId,
        user.sharedHouseholdId,
        user.firstName,
        user.role,
        DateTime.now().toUtc().toIso8601String(),
        user.id,
      ],
    );
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  // Use the notifier to get the DatabaseService instance
  return ProfileRepository(ref.watch(databaseServiceProvider.notifier));
}

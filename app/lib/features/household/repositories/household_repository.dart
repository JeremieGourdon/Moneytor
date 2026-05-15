import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/household_model.dart';
import '../../../core/models/invitation_model.dart';

part 'household_repository.g.dart';

class HouseholdRepository {
  final DatabaseService _db;
  final SupabaseClient _supabase;

  HouseholdRepository(this._db, this._supabase);

  /// Fetches household by ID from local SQLite (PowerSync).
  Future<HouseholdModel?> getHousehold(String id) async {
    final response = await _db.get(
      'SELECT * FROM households WHERE id = ?',
      [id],
    );

    if (response == null) return null;
    return HouseholdModel.fromJson(response);
  }

  /// Updates household settings.
  Future<void> updateHousehold(HouseholdModel household) async {
    await _db.execute(
      '''UPDATE households SET 
         name = ?, 
         currency = ?, 
         default_month_start_day = ?, 
         updated_at = ?
         WHERE id = ?''',
      [
        household.name,
        household.currency,
        household.defaultMonthStartDay,
        DateTime.now().toUtc().toIso8601String(),
        household.id,
      ],
    );
  }

  /// Creates an invitation. (Requires Internet - Direct Supabase)
  Future<InvitationModel> createInvitation(
    String householdId,
    String email,
    String invitedBy,
  ) async {
    final data = await _supabase
        .from('invitations')
        .insert({
          'household_id': householdId,
          'email': email,
          'invited_by': invitedBy,
        })
        .select()
        .single();

    return InvitationModel.fromJson(data);
  }

  /// Accepts an invitation. (Requires Internet - Direct Supabase)
  Future<void> acceptInvitation(String token, String userId) async {
    final invitationData = await _supabase
        .from('invitations')
        .select()
        .eq('token', token)
        .eq('status', 'pending')
        .maybeSingle();

    if (invitationData == null) {
      throw Exception('Invitation invalid or expired');
    }
    final invitation = InvitationModel.fromJson(invitationData);

    // Update the USER to link to the shared household
    await _supabase
        .from('users')
        .update({'shared_household_id': invitation.householdId})
        .eq('id', userId);

    await _supabase
        .from('invitations')
        .update({'status': 'accepted'})
        .eq('id', invitation.id);
  }
}

@Riverpod(keepAlive: true)
HouseholdRepository householdRepository(Ref ref) {
  return HouseholdRepository(
    ref.watch(databaseServiceProvider.notifier),
    Supabase.instance.client,
  );
}

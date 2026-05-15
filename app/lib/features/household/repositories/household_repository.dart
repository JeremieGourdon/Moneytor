import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/household_model.dart';
import '../../../core/models/invitation_model.dart';

part 'household_repository.g.dart';

class HouseholdRepository {
  final SupabaseClient _supabase;

  HouseholdRepository(this._supabase);

  /// Fetches household by ID.
  Future<HouseholdModel?> getHousehold(String id) async {
    final response = await _supabase
        .from('households')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return HouseholdModel.fromJson(response);
  }

  /// Updates household settings.
  Future<void> updateHousehold(HouseholdModel household) async {
    await _supabase
        .from('households')
        .update(household.toJson())
        .eq('id', household.id);
  }

  /// Creates an invitation.
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

  /// Accepts an invitation.
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
  return HouseholdRepository(Supabase.instance.client);
}

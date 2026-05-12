import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
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

  /// Creates a new household and initializes default data.
  Future<HouseholdModel> createHousehold(String name, String userId) async {
    // 1. Create household
    final householdData = await _supabase
        .from('households')
        .insert({'name': name})
        .select()
        .single();
    
    final household = HouseholdModel.fromJson(householdData);

    // 2. Update user with household_id
    await _supabase
        .from('users')
        .update({'household_id': household.id})
        .eq('id', userId);

    // 3. Initialize Default Data (Headless approach)
    // We could do this via a Postgres function, but for now we'll do it here
    
    // a. Create "General" Category
    await _supabase.from('categories').insert({
      'id': const Uuid().v4(),
      'household_id': household.id,
      'name': 'General',
      'icon': 'folder',
      'color': '#71717A',
    });

    // Note: We don't create "Unplanned" budget yet because it needs an account_id.
    // The first budget will be created when the first account is added or manually.
    // OR we could create a dummy account, but better wait for user action.

    return household;
  }

  /// Creates an invitation.
  Future<InvitationModel> createInvitation(String householdId, String email, String invitedBy) async {
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

    if (invitationData == null) throw Exception('Invitation invalid or expired');
    final invitation = InvitationModel.fromJson(invitationData);

    await _supabase
        .from('users')
        .update({'household_id': invitation.householdId})
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

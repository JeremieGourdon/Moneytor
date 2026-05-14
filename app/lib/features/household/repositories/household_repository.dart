import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
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
  Future<HouseholdModel> createHousehold(
    String name,
    String userId, {
    int startDay = 1,
  }) async {
    // 1. Create household
    final householdData = await _supabase
        .from('households')
        .insert({'name': name, 'default_month_start_day': startDay})
        .select()
        .single();

    final household = HouseholdModel.fromJson(householdData);

    // 2. Update user with household_id
    await _supabase
        .from('users')
        .update({'household_id': household.id})
        .eq('id', userId);

    // 3. Initialize Default Financial Period
    final now = DateTime.now().toUtc();
    final firstOfNextMonth = DateTime.utc(now.year, now.month + 1, 1);
    final periodName = DateFormat('MMMM yyyy').format(now);

    await _supabase.from('financial_periods').insert({
      'id': const Uuid().v4(),
      'household_id': household.id,
      'name': periodName,
      'start_date': now.toIso8601String(),
      'end_date': firstOfNextMonth.toIso8601String(),
    });

    // 4. Initialize Default Account (Private)
    final accountId = const Uuid().v4();
    await _supabase.from('accounts').insert({
      'id': accountId,
      'household_id': household.id,
      'owner_id': userId, // Private by default
      'name': 'Current Account',
      'type': 'checking',
      'is_public': false,
    });

    // 5. Initialize "Unplanned" System Budget for this account
    // This is mandatory for every account to handle unsorted transactions.
    await _supabase.from('budgets').insert({
      'id': const Uuid().v4(),
      'household_id': household.id,
      'account_id': accountId,
      'name': 'Unplanned',
      'default_amount': 0,
      'icon': 'help-circle',
      'color': '#71717A',
      'is_system': true,
    });

    return household;
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

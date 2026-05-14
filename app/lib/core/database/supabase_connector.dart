import 'dart:developer' as developer;
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Connector to bridge PowerSync with Supabase Auth and Functions.
class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient supabase;

  SupabaseConnector(this.supabase);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    var session = supabase.auth.currentSession;
    if (session == null) return null;

    // Check if the session is expired or close to expiring
    if (session.isExpired) {
      try {
        final response = await supabase.auth.refreshSession();
        session = response.session;
      } catch (e) {
        developer.log(
          'Failed to refresh Supabase session: $e',
          name: 'powersync.auth',
          error: e,
        );
        return null;
      }
    }

    if (session == null) return null;

    final user = session.user;

    // PowerSync expects the Supabase JWT
    return PowerSyncCredentials(
      endpoint: 'https://6a04476f234fa2bf51a24c72.powersync.journeyapps.com',
      token: session.accessToken,
      userId: user.id,
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // Get the next transaction to upload
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    CrudEntry? currentOp;
    try {
      for (final operation in transaction.crud) {
        currentOp = operation;
        final table = operation.table;
        final row = operation.opData;

        switch (operation.op) {
          case UpdateType.put:
            await supabase.from(table).upsert(row!);
            break;
          case UpdateType.patch:
            await supabase.from(table).update(row!).eq('id', operation.id);
            break;
          case UpdateType.delete:
            await supabase.from(table).delete().eq('id', operation.id);
            break;
        }
      }

      // Mark transaction as completed after successful upload
      await transaction.complete();
    } catch (e) {
      if (e is PostgrestException) {
        developer.log(
          'Upload error for table "${currentOp?.table}" (ID: ${currentOp?.id}): ${e.message}\n'
          'Op: ${currentOp?.op}, Data: ${currentOp?.opData}\n'
          'Code: ${e.code}, Details: ${e.details}, Hint: ${e.hint}',
          name: 'powersync.upload',
          error: e,
          level: 1000,
        );
      } else {
        developer.log(
          'Unexpected upload error: $e',
          name: 'powersync.upload',
          error: e,
          level: 1000,
        );
      }

      // Re-throwing will cause PowerSync to retry
      rethrow;
    }
  }
}

import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Connector to bridge PowerSync with Supabase Auth and Functions.
class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient supabase;

  SupabaseConnector(this.supabase);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = supabase.auth.currentSession;
    if (session == null) return null;

    // PowerSync expects the Supabase JWT
    return PowerSyncCredentials(
      endpoint: 'YOUR_POWERSYNC_ENDPOINT_HERE', // TODO: Add endpoint
      token: session.accessToken,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // Get the next transaction to upload
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) return;

    try {
      for (final operation in transaction.crud) {
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
      // Re-throwing will cause PowerSync to retry
      rethrow;
    }
  }
}

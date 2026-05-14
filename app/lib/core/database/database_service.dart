import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'schema.dart';
import 'supabase_connector.dart';

part 'database_service.g.dart';

@Riverpod(keepAlive: true)
class DatabaseService extends _$DatabaseService {
  @override
  Future<PowerSyncDatabase> build() async {
    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, 'moneytor.db');

    final db = PowerSyncDatabase(schema: schema, path: path);
    await db.initialize();

    // Connect to Supabase for sync
    final connector = SupabaseConnector(Supabase.instance.client);
    db.connect(connector: connector);

    // Listen for auth state changes to invalidate credentials
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      connector.invalidateCredentials();
    });

    return db;
  }

  /// Helper to watch a query
  Stream<List<Map<String, dynamic>>> watch(
    String sql, [
    List<dynamic>? params,
  ]) async* {
    final db = await future; // Wait for the build() method to finish
    yield* db.watch(sql, parameters: params ?? []);
  }

  /// Helper to execute a query
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? params,
  ]) async {
    final db = await future;
    return db.getAll(sql, params ?? []);
  }

  /// Helper to execute a single row query
  Future<Map<String, dynamic>?> get(String sql, [List<dynamic>? params]) async {
    final db = await future;
    return db.getOptional(sql, params ?? []);
  }

  /// Helper to execute a write operation
  Future<void> execute(String sql, [List<dynamic>? params]) async {
    final db = await future;
    await db.execute(sql, params ?? []);
  }

  /// Helper to run a transaction
  Future<T> writeTransaction<T>(Future<T> Function(dynamic tx) callback) async {
    final db = await future;
    return db.writeTransaction((tx) => callback(tx));
  }
}

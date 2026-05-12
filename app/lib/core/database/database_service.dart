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
  late final PowerSyncDatabase _db;
  
  PowerSyncDatabase get db => _db;

  @override
  Future<PowerSyncDatabase> build() async {
    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, 'moneytor.db');

    _db = PowerSyncDatabase(schema: schema, path: path);
    await _db.initialize();

    // Connect to Supabase for sync
    final connector = SupabaseConnector(Supabase.instance.client);
    _db.connect(connector: connector);

    return _db;
  }

  /// Helper to watch a query
  Stream<List<Map<String, dynamic>>> watch(String sql, [List<dynamic>? params]) {
    return _db.watch(sql, parameters: params ?? []);
  }

  /// Helper to execute a query
  Future<List<Map<String, dynamic>>> query(String sql,
      [List<dynamic>? params]) async {
    await future; // Ensure initialized
    return _db.getAll(sql, params ?? []);
  }

  /// Helper to execute a single row query
  Future<Map<String, dynamic>?> get(String sql, [List<dynamic>? params]) async {
    await future;
    return _db.getOptional(sql, params ?? []);
  }

  /// Helper to execute a write operation
  Future<void> execute(String sql, [List<dynamic>? params]) async {
    await future;
    await _db.execute(sql, params ?? []);
  }
}

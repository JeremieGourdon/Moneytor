// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DatabaseService)
final databaseServiceProvider = DatabaseServiceProvider._();

final class DatabaseServiceProvider
    extends $AsyncNotifierProvider<DatabaseService, PowerSyncDatabase> {
  DatabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  DatabaseService create() => DatabaseService();
}

String _$databaseServiceHash() => r'7f15a53fc59e53aac9da9b8f5893a88d8d71d3ff';

abstract class _$DatabaseService extends $AsyncNotifier<PowerSyncDatabase> {
  FutureOr<PowerSyncDatabase> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PowerSyncDatabase>, PowerSyncDatabase>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PowerSyncDatabase>, PowerSyncDatabase>,
              AsyncValue<PowerSyncDatabase>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

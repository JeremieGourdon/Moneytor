// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HouseholdNotifier)
final householdProvider = HouseholdNotifierProvider._();

final class HouseholdNotifierProvider
    extends $AsyncNotifierProvider<HouseholdNotifier, HouseholdModel?> {
  HouseholdNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'householdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$householdNotifierHash();

  @$internal
  @override
  HouseholdNotifier create() => HouseholdNotifier();
}

String _$householdNotifierHash() => r'be0d83d7edcec2ab6b83ce315ff5dae545ccea4a';

abstract class _$HouseholdNotifier extends $AsyncNotifier<HouseholdModel?> {
  FutureOr<HouseholdModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HouseholdModel?>, HouseholdModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HouseholdModel?>, HouseholdModel?>,
              AsyncValue<HouseholdModel?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

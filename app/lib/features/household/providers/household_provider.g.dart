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
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$householdNotifierHash();

  @$internal
  @override
  HouseholdNotifier create() => HouseholdNotifier();
}

String _$householdNotifierHash() => r'0acc4c1433d26362b74649df8e70a3ba8bbd13d0';

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

@ProviderFor(sharedHousehold)
final sharedHouseholdProvider = SharedHouseholdProvider._();

final class SharedHouseholdProvider
    extends
        $FunctionalProvider<
          AsyncValue<HouseholdModel?>,
          HouseholdModel?,
          FutureOr<HouseholdModel?>
        >
    with $FutureModifier<HouseholdModel?>, $FutureProvider<HouseholdModel?> {
  SharedHouseholdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedHouseholdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedHouseholdHash();

  @$internal
  @override
  $FutureProviderElement<HouseholdModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HouseholdModel?> create(Ref ref) {
    return sharedHousehold(ref);
  }
}

String _$sharedHouseholdHash() => r'0c0fb8014fefdabe7d4014f7d433a694681f2481';

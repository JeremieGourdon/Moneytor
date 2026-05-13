// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentPeriod)
final currentPeriodProvider = CurrentPeriodProvider._();

final class CurrentPeriodProvider
    extends
        $FunctionalProvider<
          AsyncValue<FinancialPeriodModel?>,
          FinancialPeriodModel?,
          Stream<FinancialPeriodModel?>
        >
    with
        $FutureModifier<FinancialPeriodModel?>,
        $StreamProvider<FinancialPeriodModel?> {
  CurrentPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPeriodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPeriodHash();

  @$internal
  @override
  $StreamProviderElement<FinancialPeriodModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FinancialPeriodModel?> create(Ref ref) {
    return currentPeriod(ref);
  }
}

String _$currentPeriodHash() => r'8222ce886c4722ed0aec58ab8d0d54ec15974b33';

@ProviderFor(allPeriods)
final allPeriodsProvider = AllPeriodsProvider._();

final class AllPeriodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FinancialPeriodModel>>,
          List<FinancialPeriodModel>,
          Stream<List<FinancialPeriodModel>>
        >
    with
        $FutureModifier<List<FinancialPeriodModel>>,
        $StreamProvider<List<FinancialPeriodModel>> {
  AllPeriodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allPeriodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allPeriodsHash();

  @$internal
  @override
  $StreamProviderElement<List<FinancialPeriodModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FinancialPeriodModel>> create(Ref ref) {
    return allPeriods(ref);
  }
}

String _$allPeriodsHash() => r'ebb1cce519131f30486b34d5a5b6a947626bebb7';

@ProviderFor(PeriodNotifier)
final periodProvider = PeriodNotifierProvider._();

final class PeriodNotifierProvider
    extends $AsyncNotifierProvider<PeriodNotifier, void> {
  PeriodNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periodProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periodNotifierHash();

  @$internal
  @override
  PeriodNotifier create() => PeriodNotifier();
}

String _$periodNotifierHash() => r'63c98fd55776ba5e8f4f704068f0bd0f48bff5e1';

abstract class _$PeriodNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

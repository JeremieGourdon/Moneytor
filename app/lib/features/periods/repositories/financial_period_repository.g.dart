// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_period_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(financialPeriodRepository)
final financialPeriodRepositoryProvider = FinancialPeriodRepositoryProvider._();

final class FinancialPeriodRepositoryProvider
    extends
        $FunctionalProvider<
          FinancialPeriodRepository,
          FinancialPeriodRepository,
          FinancialPeriodRepository
        >
    with $Provider<FinancialPeriodRepository> {
  FinancialPeriodRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financialPeriodRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financialPeriodRepositoryHash();

  @$internal
  @override
  $ProviderElement<FinancialPeriodRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinancialPeriodRepository create(Ref ref) {
    return financialPeriodRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinancialPeriodRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinancialPeriodRepository>(value),
    );
  }
}

String _$financialPeriodRepositoryHash() =>
    r'1e521a526f8f1c6aba52eeee4f5a7af3309f271a';

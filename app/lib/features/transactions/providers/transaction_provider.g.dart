// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionNotifier)
final transactionProvider = TransactionNotifierProvider._();

final class TransactionNotifierProvider
    extends $AsyncNotifierProvider<TransactionNotifier, void> {
  TransactionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionNotifierHash();

  @$internal
  @override
  TransactionNotifier create() => TransactionNotifier();
}

String _$transactionNotifierHash() =>
    r'786cdc0dbea5563724daeadf35ae4cac4847343e';

abstract class _$TransactionNotifier extends $AsyncNotifier<void> {
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

/// A provider that calculates the RAV (Disposable Income) for an account.

@ProviderFor(disposableIncome)
final disposableIncomeProvider = DisposableIncomeFamily._();

/// A provider that calculates the RAV (Disposable Income) for an account.

final class DisposableIncomeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// A provider that calculates the RAV (Disposable Income) for an account.
  DisposableIncomeProvider._({
    required DisposableIncomeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'disposableIncomeProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$disposableIncomeHash();

  @override
  String toString() {
    return r'disposableIncomeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return disposableIncome(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DisposableIncomeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$disposableIncomeHash() => r'bafe42ecc054c91f91fbeeb3c4bdd148d7e9d04a';

/// A provider that calculates the RAV (Disposable Income) for an account.

final class DisposableIncomeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  DisposableIncomeFamily._()
    : super(
        retry: null,
        name: r'disposableIncomeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// A provider that calculates the RAV (Disposable Income) for an account.

  DisposableIncomeProvider call(String accountId) =>
      DisposableIncomeProvider._(argument: accountId, from: this);

  @override
  String toString() => r'disposableIncomeProvider';
}

@ProviderFor(totalDisposableIncome)
final totalDisposableIncomeProvider = TotalDisposableIncomeProvider._();

final class TotalDisposableIncomeProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  TotalDisposableIncomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalDisposableIncomeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalDisposableIncomeHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return totalDisposableIncome(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$totalDisposableIncomeHash() =>
    r'2229c2824b93ce273c045e2c2a517c1a8db493d1';

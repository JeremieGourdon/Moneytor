// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accounts)
final accountsProvider = AccountsProvider._();

final class AccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountModel>>,
          List<AccountModel>,
          Stream<List<AccountModel>>
        >
    with
        $FutureModifier<List<AccountModel>>,
        $StreamProvider<List<AccountModel>> {
  AccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsHash();

  @$internal
  @override
  $StreamProviderElement<List<AccountModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AccountModel>> create(Ref ref) {
    return accounts(ref);
  }
}

String _$accountsHash() => r'35dfd65ef3418a0bd84c9a794890c61d76e9c77c';

@ProviderFor(accountBalance)
final accountBalanceProvider = AccountBalanceFamily._();

final class AccountBalanceProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  AccountBalanceProvider._({
    required AccountBalanceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountBalanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountBalanceHash();

  @override
  String toString() {
    return r'accountBalanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return accountBalance(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBalanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountBalanceHash() => r'050365647925ea86e6d434d167b6a31cc588699c';

final class AccountBalanceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  AccountBalanceFamily._()
    : super(
        retry: null,
        name: r'accountBalanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountBalanceProvider call(String accountId) =>
      AccountBalanceProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountBalanceProvider';
}

@ProviderFor(AccountNotifier)
final accountProvider = AccountNotifierProvider._();

final class AccountNotifierProvider
    extends $AsyncNotifierProvider<AccountNotifier, void> {
  AccountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountNotifierHash();

  @$internal
  @override
  AccountNotifier create() => AccountNotifier();
}

String _$accountNotifierHash() => r'3604151b8d6ba5458977d22e844456294eefa1f3';

abstract class _$AccountNotifier extends $AsyncNotifier<void> {
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

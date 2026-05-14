// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedAccountId)
final selectedAccountIdProvider = SelectedAccountIdProvider._();

final class SelectedAccountIdProvider
    extends $NotifierProvider<SelectedAccountId, String?> {
  SelectedAccountIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAccountIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAccountIdHash();

  @$internal
  @override
  SelectedAccountId create() => SelectedAccountId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedAccountIdHash() => r'be53ec7edc6a358a5a841dcb755884b87cc76c43';

abstract class _$SelectedAccountId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(selectedAccount)
final selectedAccountProvider = SelectedAccountProvider._();

final class SelectedAccountProvider
    extends $FunctionalProvider<AccountModel?, AccountModel?, AccountModel?>
    with $Provider<AccountModel?> {
  SelectedAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAccountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAccountHash();

  @$internal
  @override
  $ProviderElement<AccountModel?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccountModel? create(Ref ref) {
    return selectedAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountModel?>(value),
    );
  }
}

String _$selectedAccountHash() => r'0018805e0979f0e8edfa4d5594638c7733400da2';

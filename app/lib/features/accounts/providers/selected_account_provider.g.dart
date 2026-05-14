// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedAccount)
final selectedAccountProvider = SelectedAccountProvider._();

final class SelectedAccountProvider
    extends $NotifierProvider<SelectedAccount, AccountModel?> {
  SelectedAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAccountHash();

  @$internal
  @override
  SelectedAccount create() => SelectedAccount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountModel?>(value),
    );
  }
}

String _$selectedAccountHash() => r'77c7816d5c785c2984c7f9ce9e1dd87e9bd6ec29';

abstract class _$SelectedAccount extends $Notifier<AccountModel?> {
  AccountModel? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AccountModel?, AccountModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountModel?, AccountModel?>,
              AccountModel?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allBudgets)
final allBudgetsProvider = AllBudgetsProvider._();

final class AllBudgetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetModel>>,
          List<BudgetModel>,
          Stream<List<BudgetModel>>
        >
    with
        $FutureModifier<List<BudgetModel>>,
        $StreamProvider<List<BudgetModel>> {
  AllBudgetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBudgetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBudgetsHash();

  @$internal
  @override
  $StreamProviderElement<List<BudgetModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BudgetModel>> create(Ref ref) {
    return allBudgets(ref);
  }
}

String _$allBudgetsHash() => r'42e8690d75069bd1a4cc0868fdbc3681562d9f6b';

@ProviderFor(accountBudgets)
final accountBudgetsProvider = AccountBudgetsFamily._();

final class AccountBudgetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetModel>>,
          List<BudgetModel>,
          Stream<List<BudgetModel>>
        >
    with
        $FutureModifier<List<BudgetModel>>,
        $StreamProvider<List<BudgetModel>> {
  AccountBudgetsProvider._({
    required AccountBudgetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountBudgetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountBudgetsHash();

  @override
  String toString() {
    return r'accountBudgetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BudgetModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BudgetModel>> create(Ref ref) {
    final argument = this.argument as String;
    return accountBudgets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBudgetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountBudgetsHash() => r'b997a9b0822c2d7c37e93dbeafd68746defa82ba';

final class AccountBudgetsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BudgetModel>>, String> {
  AccountBudgetsFamily._()
    : super(
        retry: null,
        name: r'accountBudgetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountBudgetsProvider call(String accountId) =>
      AccountBudgetsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountBudgetsProvider';
}

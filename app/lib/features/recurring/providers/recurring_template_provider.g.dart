// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_template_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allRecurringTemplates)
final allRecurringTemplatesProvider = AllRecurringTemplatesProvider._();

final class AllRecurringTemplatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecurringTemplateModel>>,
          List<RecurringTemplateModel>,
          Stream<List<RecurringTemplateModel>>
        >
    with
        $FutureModifier<List<RecurringTemplateModel>>,
        $StreamProvider<List<RecurringTemplateModel>> {
  AllRecurringTemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allRecurringTemplatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allRecurringTemplatesHash();

  @$internal
  @override
  $StreamProviderElement<List<RecurringTemplateModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecurringTemplateModel>> create(Ref ref) {
    return allRecurringTemplates(ref);
  }
}

String _$allRecurringTemplatesHash() =>
    r'3e14d9ce028ea620f38219eee16681bcecef0c34';

@ProviderFor(RecurringTemplateNotifier)
final recurringTemplateProvider = RecurringTemplateNotifierProvider._();

final class RecurringTemplateNotifierProvider
    extends $AsyncNotifierProvider<RecurringTemplateNotifier, void> {
  RecurringTemplateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTemplateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTemplateNotifierHash();

  @$internal
  @override
  RecurringTemplateNotifier create() => RecurringTemplateNotifier();
}

String _$recurringTemplateNotifierHash() =>
    r'b3911f7e50951cf58c684433b151de4ca271654c';

abstract class _$RecurringTemplateNotifier extends $AsyncNotifier<void> {
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

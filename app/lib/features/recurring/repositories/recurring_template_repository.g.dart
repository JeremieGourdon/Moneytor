// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_template_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recurringTemplateRepository)
final recurringTemplateRepositoryProvider =
    RecurringTemplateRepositoryProvider._();

final class RecurringTemplateRepositoryProvider
    extends
        $FunctionalProvider<
          RecurringTemplateRepository,
          RecurringTemplateRepository,
          RecurringTemplateRepository
        >
    with $Provider<RecurringTemplateRepository> {
  RecurringTemplateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringTemplateRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringTemplateRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecurringTemplateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecurringTemplateRepository create(Ref ref) {
    return recurringTemplateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecurringTemplateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecurringTemplateRepository>(value),
    );
  }
}

String _$recurringTemplateRepositoryHash() =>
    r'2af252fcbc1d714bb45a5fd0b49a9063f48a39c3';

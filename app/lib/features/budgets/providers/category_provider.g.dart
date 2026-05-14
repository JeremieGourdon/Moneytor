// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          Stream<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $StreamProvider<List<CategoryModel>> {
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryModel>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'3233feeeafa0f1316c79329a0e92beef275136b9';

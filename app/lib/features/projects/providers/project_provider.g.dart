// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allProjects)
final allProjectsProvider = AllProjectsProvider._();

final class AllProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectModel>>,
          List<ProjectModel>,
          Stream<List<ProjectModel>>
        >
    with
        $FutureModifier<List<ProjectModel>>,
        $StreamProvider<List<ProjectModel>> {
  AllProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allProjectsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allProjectsHash();

  @$internal
  @override
  $StreamProviderElement<List<ProjectModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProjectModel>> create(Ref ref) {
    return allProjects(ref);
  }
}

String _$allProjectsHash() => r'4e189ab4d107b36765cfd57f1b92c4a3683fbb30';

@ProviderFor(accountProjects)
final accountProjectsProvider = AccountProjectsFamily._();

final class AccountProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectModel>>,
          List<ProjectModel>,
          Stream<List<ProjectModel>>
        >
    with
        $FutureModifier<List<ProjectModel>>,
        $StreamProvider<List<ProjectModel>> {
  AccountProjectsProvider._({
    required AccountProjectsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountProjectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountProjectsHash();

  @override
  String toString() {
    return r'accountProjectsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ProjectModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProjectModel>> create(Ref ref) {
    final argument = this.argument as String;
    return accountProjects(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountProjectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountProjectsHash() => r'1e109a741c29273aed20d4f971349f9033d36524';

final class AccountProjectsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ProjectModel>>, String> {
  AccountProjectsFamily._()
    : super(
        retry: null,
        name: r'accountProjectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountProjectsProvider call(String accountId) =>
      AccountProjectsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountProjectsProvider';
}

@ProviderFor(projectSpent)
final projectSpentProvider = ProjectSpentFamily._();

final class ProjectSpentProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  ProjectSpentProvider._({
    required ProjectSpentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectSpentProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectSpentHash();

  @override
  String toString() {
    return r'projectSpentProvider'
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
    return projectSpent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectSpentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectSpentHash() => r'1078e0f6f0c01b289aba6c59a7c6ec6040ea22c4';

final class ProjectSpentFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  ProjectSpentFamily._()
    : super(
        retry: null,
        name: r'projectSpentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ProjectSpentProvider call(String projectId) =>
      ProjectSpentProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectSpentProvider';
}

@ProviderFor(projectDebt)
final projectDebtProvider = ProjectDebtFamily._();

final class ProjectDebtProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  ProjectDebtProvider._({
    required ProjectDebtFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectDebtProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectDebtHash();

  @override
  String toString() {
    return r'projectDebtProvider'
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
    return projectDebt(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectDebtProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectDebtHash() => r'bb6a53628db820b664bc2c1d29a18264ef94aed2';

final class ProjectDebtFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  ProjectDebtFamily._()
    : super(
        retry: null,
        name: r'projectDebtProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ProjectDebtProvider call(String projectId) =>
      ProjectDebtProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectDebtProvider';
}

@ProviderFor(ProjectNotifier)
final projectProvider = ProjectNotifierProvider._();

final class ProjectNotifierProvider
    extends $AsyncNotifierProvider<ProjectNotifier, void> {
  ProjectNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectNotifierHash();

  @$internal
  @override
  ProjectNotifier create() => ProjectNotifier();
}

String _$projectNotifierHash() => r'b6e43b846bce621f657115779940d72f40f5507c';

abstract class _$ProjectNotifier extends $AsyncNotifier<void> {
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

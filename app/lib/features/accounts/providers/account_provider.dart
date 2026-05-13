import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/account_model.dart';
import '../../household/providers/household_provider.dart';
import '../repositories/account_repository.dart';

part 'account_provider.g.dart';

@riverpod
Stream<List<AccountModel>> accounts(Ref ref) {
  final household = ref.watch(householdProvider).value;
  if (household == null) return Stream.value([]);

  return ref.watch(accountRepositoryProvider).watchAccounts(household.id);
}

@riverpod
Future<int> accountBalance(Ref ref, String accountId) {
  return ref.watch(accountRepositoryProvider).getBalance(accountId);
}

@riverpod
class AccountNotifier extends _$AccountNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> createAccount(String name,
      {String type = 'checking', bool isPublic = false}) async {
    final household = await ref.read(householdProvider.future);
    if (household == null) return;

    final account = AccountModel(
      id: const Uuid().v4(),
      householdId: household.id,
      name: name,
      type: type,
      isPublic: isPublic, // Now defaults to false (Private)
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await ref.read(accountRepositoryProvider).createAccount(account);
  }

  Future<void> togglePrivacy(AccountModel account) async {
    final updated = account.copyWith(isPublic: !account.isPublic);
    await ref.read(accountRepositoryProvider).updateAccount(updated);
  }
}

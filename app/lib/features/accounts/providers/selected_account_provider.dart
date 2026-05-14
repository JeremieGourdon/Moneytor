import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/account_model.dart';
import 'account_provider.dart';

part 'selected_account_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedAccountId extends _$SelectedAccountId {
  @override
  String? build() => null;

  void select(String id) => state = id;
}

@Riverpod(keepAlive: true)
AccountModel? selectedAccount(Ref ref) {
  final accounts = ref.watch(accountsProvider).value ?? [];
  if (accounts.isEmpty) return null;

  final selectedId = ref.watch(selectedAccountIdProvider);

  if (selectedId != null) {
    final match = accounts.where((a) => a.id == selectedId).firstOrNull;
    if (match != null) return match;
  }

  // Fallback to default or first account
  return accounts.where((a) => a.isDefault).firstOrNull ?? accounts.firstOrNull;
}

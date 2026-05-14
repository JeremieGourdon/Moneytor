import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/account_model.dart';
import 'account_provider.dart';

part 'selected_account_provider.g.dart';

@riverpod
class SelectedAccount extends _$SelectedAccount {
  @override
  AccountModel? build() {
    final allAccounts = ref.watch(accountsProvider).value;
    if (allAccounts == null || allAccounts.isEmpty) return null;

    // If we already have a state, try to keep it if it's still valid
    if (state != null) {
      final stillExists = allAccounts.any((a) => a.id == state!.id);
      if (stillExists) return state;
    }

    // Default to the first default account, or just the first account
    return allAccounts.firstWhere(
      (a) => a.isDefault,
      orElse: () => allAccounts.first,
    );
  }

  void select(AccountModel account) {
    state = account;
  }
}

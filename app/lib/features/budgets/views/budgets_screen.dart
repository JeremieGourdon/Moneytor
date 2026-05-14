import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../providers/budget_provider.dart';
import '../repositories/budget_repository.dart';
import '../../accounts/providers/account_provider.dart';
import '../../household/providers/household_provider.dart';
import '../../../core/models/budget_model.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(allBudgetsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final currency = ref.watch(householdProvider).value?.currency ?? 'EUR';
    final formatter = NumberFormat.simpleCurrency(name: currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BUDGETS', style: TextStyle(letterSpacing: 2)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allBudgetsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR ENVELOPES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              budgetsAsync.when(
                data: (budgets) => budgets.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            'No budgets yet. Create one to start.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: budgets.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final budget = budgets[index];
                          return _buildBudgetCard(
                            context,
                            ref,
                            budget,
                            formatter,
                          );
                        },
                      ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
                error: (err, _) => Text('Error: $err'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddBudgetDialog(
                  context,
                  ref,
                  accountsAsync.value ?? [],
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('NEW BUDGET'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
    NumberFormat formatter,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(_getIconData(budget.icon), color: Colors.black),
        title: Text(
          budget.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Monthly: ${formatter.format(budget.defaultAmount / 100.0)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(
          LucideIcons.chevron_right,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => context.go('/budgets/detail', extra: budget),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'shopping-cart':
        return LucideIcons.shopping_cart;
      case 'home':
        return LucideIcons.house;
      case 'utensils':
        return LucideIcons.utensils;
      case 'car':
        return LucideIcons.car;
      default:
        return LucideIcons.folder;
    }
  }

  void _showAddBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> accounts,
  ) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
    String selectedIcon = 'folder';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'NEW BUDGET',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Groceries',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Default Amount',
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedAccountId,
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id as String,
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedAccountId = val),
                decoration: const InputDecoration(labelText: 'Linked Account'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    selectedAccountId != null) {
                  final household = ref.read(householdProvider).value;
                  if (household == null) return;

                  final amount =
                      (double.tryParse(amountController.text) ?? 0) * 100;

                  final budget = BudgetModel(
                    id: const Uuid().v4(),
                    householdId: household.id,
                    accountId: selectedAccountId!,
                    name: nameController.text,
                    defaultAmount: amount.toInt(),
                    icon: selectedIcon,
                    createdAt: DateTime.now().toUtc(),
                    updatedAt: DateTime.now().toUtc(),
                  );

                  await ref.read(budgetRepositoryProvider).createBudget(budget);
                  ref.invalidate(allBudgetsProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }
}

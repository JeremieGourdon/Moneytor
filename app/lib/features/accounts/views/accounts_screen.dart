import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../../periods/providers/period_provider.dart';
import '../../../core/models/account_model.dart';
import '../../../core/models/financial_period_model.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final currentPeriodAsync = ref.watch(currentPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNTS', style: TextStyle(letterSpacing: 2)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(currentPeriodProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCycleControl(context, ref, currentPeriodAsync),
              const SizedBox(height: 32),
              const Text(
                'YOUR ACCOUNTS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              const SizedBox(height: 16),
              accountsAsync.when(
                data: (accounts) => accounts.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Text('No accounts yet. Add your first one below.',
                            style: TextStyle(color: Colors.grey)),
                      ))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return _buildAccountCard(context, ref, account);
                        },
                      ),
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.black)),
                error: (err, _) => Text('Error: $err'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddAccountDialog(context, ref),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('ADD ACCOUNT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleControl(BuildContext context, WidgetRef ref,
      AsyncValue<FinancialPeriodModel?> periodAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('FINANCIAL CYCLE',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (periodAsync.value != null)
                  IconButton(
                    onPressed: () =>
                        _showEditPeriodDialog(context, ref, periodAsync.value!),
                    icon: const Icon(LucideIcons.pencil,
                        size: 16, color: Colors.grey),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            periodAsync.when(
              data: (period) => period == null
                  ? const Text(
                      'No active cycle. Start your first month to begin.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period.name.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Started on: ${DateFormat('dd/MM/yyyy').format(period.startDate)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
              loading: () => const SizedBox(),
              error: (err, stack) => const Text('Error loading cycle'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: periodAsync.value == null
                        ? null
                        : () => ref.read(periodProvider.notifier).delayPeriod(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('DELAY +1D'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleStartPeriod(context, ref, periodAsync.value == null),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: Text(periodAsync.value == null
                        ? 'START FIRST'
                        : 'START NEXT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
      BuildContext context, WidgetRef ref, AccountModel account) {
    return Card(
      child: ListTile(
        title: Text(account.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                account.type.toUpperCase(),
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            if (!account.isPublic) ...[
              const SizedBox(width: 8),
              const Icon(LucideIcons.lock, size: 12, color: Colors.grey),
            ],
          ],
        ),
        trailing: const Text(
          '0.00 €', // TODO: Fetch real balance
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  void _handleStartPeriod(BuildContext context, WidgetRef ref, bool isFirst) async {
    if (isFirst) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 60)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        helpText: 'Select Start Date for first cycle',
      );
      if (date != null) {
        await ref.read(periodProvider.notifier).startNextPeriod(customStartDate: date);
      }
    } else {
      await ref.read(periodProvider.notifier).startNextPeriod();
    }
  }

  void _showEditPeriodDialog(
      BuildContext context, WidgetRef ref, FinancialPeriodModel period) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: period.startDate,
      firstDate: period.startDate.subtract(const Duration(days: 31)),
      lastDate: DateTime.now().add(const Duration(days: 31)),
      helpText: 'Adjust Start Date',
    );

    if (newDate != null) {
      await ref.read(periodProvider.notifier).adjustCurrentStart(newDate);
    }
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String type = 'checking';
    bool isPublic = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('ADD ACCOUNT',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Account Name', hintText: 'e.g., Main Checking'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'checking', child: Text('Checking')),
                  DropdownMenuItem(
                      value: 'savings_locked', child: Text('Savings (Locked)')),
                ],
                onChanged: (val) => setState(() => type = val!),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public (Shared)',
                    style: TextStyle(fontSize: 14)),
                value: isPublic,
                onChanged: (val) => setState(() => isPublic = val),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await ref
                      .read(accountProvider.notifier)
                      .createAccount(
                        nameController.text,
                        type: type,
                        isPublic: isPublic,
                      );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }
}

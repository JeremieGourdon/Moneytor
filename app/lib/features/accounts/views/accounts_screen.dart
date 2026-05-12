import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../providers/account_provider.dart';
import '../../periods/providers/period_provider.dart';
import '../../household/providers/household_provider.dart';
import '../../../core/models/account_model.dart';
import '../../../core/models/financial_period_model.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final currentPeriodAsync = ref.watch(currentPeriodProvider);
    final householdAsync = ref.watch(householdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNTS', style: TextStyle(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refresh_cw, size: 20),
            onPressed: () {
              ref.invalidate(accountsProvider);
              ref.invalidate(currentPeriodProvider);
              ref.invalidate(householdProvider);
            },
          ),
        ],
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
              // Debug Info (Hidden in prod)
              if (householdAsync.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Household: ${householdAsync.value!.name} (${householdAsync.value!.id.substring(0, 8)}...)',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),

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
                error: (err, _) => Text('Error loading accounts: $err'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: householdAsync.value == null
                    ? null
                    : () => _showAddAccountDialog(context, ref),
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
    final period = periodAsync.value;

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
                if (period != null)
                  IconButton(
                    onPressed: () => _showEditPeriodDialog(context, ref, period),
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
              error: (err, _) => Text('Error: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 10)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: period == null
                        ? null
                        : () => _handleDelayPeriod(context, ref),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('DELAY +1D'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _handleStartPeriod(context, ref, period == null),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: Text(period == null ? 'START FIRST' : 'START NEXT'),
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

  Future<void> _handleDelayPeriod(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(periodProvider.notifier).delayPeriod();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cycle delayed by 1 day')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleStartPeriod(
      BuildContext context, WidgetRef ref, bool isFirst) async {
    try {
      DateTime? startDate;
      if (isFirst) {
        startDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 60)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          helpText: 'Select Start Date for first cycle',
        );
        if (startDate == null) return;
      }

      await ref
          .read(periodProvider.notifier)
          .startNextPeriod(customStartDate: startDate);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isFirst ? 'First cycle started!' : 'New cycle started!')),
        );
      }
    } catch (e) {
      developer.log('Error starting period', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
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
      try {
        await ref.read(periodProvider.notifier).adjustCurrentStart(newDate);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cycle start date adjusted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
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
                value: type,
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
                  try {
                    await ref.read(accountProvider.notifier).createAccount(
                          nameController.text,
                          type: type,
                          isPublic: isPublic,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account created successfully')),
                      );
                    }
                  } catch (e) {
                    developer.log('Error creating account', error: e);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
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

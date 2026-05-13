import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
    final allPeriodsAsync = ref.watch(allPeriodsProvider);
    final household = ref.watch(householdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNTS', style: TextStyle(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refresh_cw, size: 20),
            onPressed: () {
              ref.invalidate(accountsProvider);
              ref.invalidate(currentPeriodProvider);
              ref.invalidate(allPeriodsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(accountsProvider);
          ref.invalidate(currentPeriodProvider);
          ref.invalidate(allPeriodsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Global Cycle Setting
              if (household != null)
                _buildGlobalCycleSetting(context, ref, household.defaultMonthStartDay),
              const SizedBox(height: 24),

              // 2. Active Period Card
              _buildCycleControl(context, ref, currentPeriodAsync),
              const SizedBox(height: 32),

              // 3. Accounts List
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
                        child: Text('No accounts yet.',
                            style: TextStyle(color: Colors.grey)),
                      ))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
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

              const SizedBox(height: 48),

              // 4. Period History / Editor
              const Text(
                'PERIOD HISTORY',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              const SizedBox(height: 16),
              allPeriodsAsync.when(
                data: (periods) => _buildPeriodHistory(context, ref, periods),
                loading: () => const SizedBox(),
                error: (_, __) => const Text('Error loading history'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalCycleSetting(
      BuildContext context, WidgetRef ref, int currentDay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Default Start Day',
              style: TextStyle(fontWeight: FontWeight.w500)),
          DropdownButton<int>(
            value: currentDay,
            underline: const SizedBox(),
            items: List.generate(31, (i) => i + 1)
                .map((day) => DropdownMenuItem(value: day, child: Text('$day')))
                .toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(periodProvider.notifier).updateDefaultStartDay(val);
              }
            },
          ),
        ],
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
            const Text('ACTIVE CYCLE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey)),
            const SizedBox(height: 12),
            periodAsync.when(
              data: (period) => period == null
                  ? const Text('No active cycle found.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period.name.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Since: ${DateFormat('dd MMM yyyy').format(period.startDate)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
              loading: () =>
                  const CircularProgressIndicator(color: Colors.black),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleStartNextPeriod(context, ref),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: const Text('START NEXT MONTH'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodHistory(
      BuildContext context, WidgetRef ref, List<FinancialPeriodModel> periods) {
    if (periods.isEmpty) {
      return const Text('No history yet.',
          style: TextStyle(color: Colors.grey, fontSize: 12));
    }

    return Column(
      children: periods
          .map((p) => _buildPeriodHistoryItem(context, ref, p))
          .toList(),
    );
  }

  Widget _buildPeriodHistoryItem(
      BuildContext context, WidgetRef ref, FinancialPeriodModel period) {
    final isCurrent = period.endDate == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(period.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${DateFormat('dd/MM').format(period.startDate)} - ${period.endDate != null ? DateFormat('dd/MM').format(period.endDate!) : 'Now'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (!isCurrent)
            IconButton(
              onPressed: () => _showEditPeriodEnd(context, ref, period),
              icon:
                  const Icon(LucideIcons.pencil, size: 16, color: Colors.black),
            ),
        ],
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

  void _handleStartNextPeriod(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Next Month?'),
        content: const Text(
            'This will close the current cycle and start a new one based on today\'s date.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: const Text('START NOW'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(periodProvider.notifier).startNextPeriod();
    }
  }

  void _showEditPeriodEnd(
      BuildContext context, WidgetRef ref, FinancialPeriodModel period) async {
    final newEnd = await showDatePicker(
      context: context,
      initialDate: period.endDate ?? DateTime.now(),
      firstDate: period.startDate,
      lastDate: DateTime.now().add(const Duration(days: 31)),
      helpText: 'Adjust End of ${period.name}',
    );

    if (newEnd != null) {
      await ref
          .read(periodProvider.notifier)
          .adjustPeriodEnd(period.id, newEnd);
    }
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String type = 'checking';
    bool isPublic = false; // Default to Private

    showDialog(
      context: context,
      barrierDismissible: false, // More robust for focus
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('ADD ACCOUNT',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            // Better for keyboard
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Account Name',
                      hintText: 'e.g., Main Checking'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'checking', child: Text('Checking')),
                    DropdownMenuItem(
                        value: 'savings_locked',
                        child: Text('Savings (Locked)')),
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
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.pop(context);
                },
                child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  FocusScope.of(context).unfocus();
                  await ref.read(accountProvider.notifier).createAccount(
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/account_provider.dart';
import '../../periods/providers/period_provider.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cycle Control Section
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
              data: (accounts) => ListView.separated(
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
              onPressed: () {
                // TODO: Create Account Dialog
              },
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
    );
  }

  Widget _buildCycleControl(
      BuildContext context, WidgetRef ref, AsyncValue<dynamic> periodAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('FINANCIAL CYCLE',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                periodAsync.when(
                  data: (period) => Text(period?.name ?? 'No active cycle',
                      style: const TextStyle(fontSize: 12)),
                  loading: () => const SizedBox(),
                  error: (err, stack) => const Text('Error'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(periodProvider.notifier).delayPeriod(),
                    child: const Text('DELAY +1D'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(periodProvider.notifier).startNextPeriod(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    child: const Text('START NOW'),
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
      BuildContext context, WidgetRef ref, dynamic account) {
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
                account.type.toString().toUpperCase(),
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
}

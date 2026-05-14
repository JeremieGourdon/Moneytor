import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import '../../../core/models/budget_model.dart';
import '../../periods/providers/period_provider.dart';
import '../../transactions/repositories/transaction_repository.dart';
import '../../../core/models/transaction_model.dart';
import '../../household/providers/household_provider.dart';
import '../providers/category_provider.dart';

class BudgetDetailScreen extends ConsumerStatefulWidget {
  final BudgetModel budget;

  const BudgetDetailScreen({super.key, required this.budget});

  @override
  ConsumerState<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends ConsumerState<BudgetDetailScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(currentPeriodProvider).value;
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(householdProvider).value?.currency ?? 'EUR';
    final formatter = NumberFormat.simpleCurrency(name: currency);

    if (period == null) {
      return const Scaffold(body: Center(child: Text('No active period')));
    }

    final transactionsStream = ref
        .watch(transactionRepositoryProvider)
        .watchTransactions(
          widget.budget.accountId,
          period.startDate,
          period.endDate,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.budget.name.toUpperCase(),
          style: const TextStyle(letterSpacing: 2),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.pencil, size: 20),
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: transactionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          var txs =
              snapshot.data
                  ?.where((t) => t.budgetId == widget.budget.id)
                  .toList() ??
              [];

          if (_selectedCategoryId != null) {
            txs = txs
                .where((t) => t.categoryId == _selectedCategoryId)
                .toList();
          }

          return Column(
            children: [
              _buildSummaryHeader(txs, formatter),
              const SizedBox(height: 16),
              _buildCategoryFilters(categoriesAsync),
              Expanded(
                child: txs.isEmpty
                    ? const Center(
                        child: Text('No transactions in this period.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: txs.length,
                        separatorBuilder: (context, index) => const Divider(),

                        itemBuilder: (context, index) {
                          final tx = txs[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              tx.description ?? 'No description',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(tx.transactionDate),
                            ),
                            trailing: Text(
                              formatter.format(tx.amount / 100.0),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: tx.amount < 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(AsyncValue<List<dynamic>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _selectedCategoryId == null,
              onSelected: (val) => setState(() => _selectedCategoryId = null),
            ),
            const SizedBox(width: 8),
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat.name),
                  selected: _selectedCategoryId == cat.id,
                  onSelected: (val) =>
                      setState(() => _selectedCategoryId = val ? cat.id : null),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
    );
  }

  Widget _buildSummaryHeader(
    List<TransactionModel> txs,
    NumberFormat formatter,
  ) {
    final spent = txs.fold(
      0,
      (sum, tx) => sum + (tx.amount < 0 ? tx.amount.abs() : 0),
    );
    final remaining = widget.budget.defaultAmount - spent;
    final progress = spent / widget.budget.defaultAmount;

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('SPENT', formatter.format(spent / 100.0)),
              _buildStat(
                'REMAINING',
                formatter.format(remaining / 100.0),
                color: remaining < 0 ? Colors.red : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey[200],
            color: progress > 1 ? Colors.red : Colors.black,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

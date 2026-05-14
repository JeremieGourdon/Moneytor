import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/account_provider.dart';
import '../../periods/providers/period_provider.dart';
import '../../periods/repositories/financial_period_repository.dart';
import '../../household/providers/household_provider.dart';
import '../../../core/models/account_model.dart';
import '../../../core/models/financial_period_model.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final allPeriodsAsync = ref.watch(allPeriodsProvider);
    final household = ref.watch(householdProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACCOUNTS', style: TextStyle(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar ? LucideIcons.list : LucideIcons.calendar,
              size: 20,
            ),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
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
              // 1. Accounts Header & List (Now on top)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'YOUR ACCOUNTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      if (household != null)
                        IconButton(
                          icon: const Icon(
                            LucideIcons.settings_2,
                            size: 18,
                            color: Colors.grey,
                          ),
                          onPressed: () => _showStartDayPicker(
                            context,
                            ref,
                            household.defaultMonthStartDay,
                          ),
                          tooltip: 'Default Start Day',
                        ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.circle_plus,
                          size: 20,
                          color: Colors.black,
                        ),
                        onPressed: () => _showAddAccountDialog(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              accountsAsync.when(
                data: (accounts) => accounts.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            'No accounts yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final account = accounts[index];
                          return _buildAccountCard(context, ref, account);
                        },
                      ),
                loading: () => Column(
                  children: List.generate(
                    2,
                    (index) => const ShimmerAccountCard(),
                  ),
                ),
                error: (err, _) => Text('Error: $err'),
              ),

              if (_showCalendar) ...[
                const SizedBox(height: 32),
                const Text(
                  'FINANCIAL CALENDAR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                allPeriodsAsync.when(
                  data: (periods) => _buildCalendar(
                    periods,
                    household?.createdAt ?? DateTime.now(),
                  ),
                  loading: () => const ShimmerBlock(
                    width: double.infinity,
                    height: 350,
                    borderRadius: 12,
                  ),
                  error: (err, _) => Text('Error: $err'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showStartDayPicker(
    BuildContext context,
    WidgetRef ref,
    int currentDay,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DEFAULT START DAY'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose which day of the month your financial cycle normally begins.',
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: currentDay,
              isExpanded: true,
              items: List.generate(31, (i) => i + 1)
                  .map(
                    (day) =>
                        DropdownMenuItem(value: day, child: Text('Day $day')),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(periodProvider.notifier).updateDefaultStartDay(val);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
    List<FinancialPeriodModel> periods,
    DateTime householdCreatedAt,
  ) {
    final Map<DateTime, List<FinancialPeriodModel>> events = {};
    for (var p in periods) {
      final start = DateTime.utc(
        p.startDate.year,
        p.startDate.month,
        p.startDate.day,
      );
      events[start] = [...(events[start] ?? []), p];
      if (p.endDate != null) {
        final end = DateTime.utc(
          p.endDate!.year,
          p.endDate!.month,
          p.endDate!.day,
        );
        events[end] = [...(events[end] ?? []), p];
      }
    }

    final firstDay = DateTime.utc(
      householdCreatedAt.year,
      householdCreatedAt.month,
      householdCreatedAt.day,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: TableCalendar(
        firstDay: firstDay,
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay.isBefore(firstDay) ? firstDay : _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });

          final dateKey = DateTime.utc(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          );

          final now = DateTime.now();
          final todayUtc = DateTime.utc(now.year, now.month, now.day);

          if (events.containsKey(dateKey)) {
            // Clicked on a Period Boundary (Start or End)
            _showMovePointSheet(context, selectedDay, periods);
          } else if (isSameDay(selectedDay, todayUtc)) {
            // Clicked on TODAY ONLY (unless it's already a boundary)
            // allow starting a new cycle early.
            _showStartEarlySheet(context, selectedDay);
          }
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          final dateKey = DateTime.utc(day.year, day.month, day.day);
          return events[dateKey] ?? [];
        },
        calendarStyle: const CalendarStyle(
          markerDecoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFFF4F4F5),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: Colors.black),
          selectedDecoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showMovePointSheet(
    BuildContext context,
    DateTime selectedDate,
    List<FinancialPeriodModel> allPeriods,
  ) {
    // Find periods related to this boundary
    // A boundary at date D is either a startDate or an endDate
    final dateOnly = DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    FinancialPeriodModel? periodEnding;
    FinancialPeriodModel? periodStarting;

    for (var p in allPeriods) {
      if (isSameDay(p.endDate, dateOnly)) periodEnding = p;
      if (isSameDay(p.startDate, dateOnly)) periodStarting = p;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'MOVE DATE POINT',
              style: GoogleFonts.jetBrainsMono(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text('Selected: ${DateFormat('dd MMM yyyy').format(selectedDate)}'),
            if (periodEnding != null && periodStarting != null)
              Text(
                'Boundary between ${periodEnding.name} and ${periodStarting.name}.',
              )
            else if (periodStarting != null)
              Text('Start of ${periodStarting.name}.')
            else if (periodEnding != null)
              Text('End of ${periodEnding.name}.'),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Allowed frame:
                // Min: start of periodEnding (if exists) or household creation
                // Max: end of periodStarting (if exists) or far future
                DateTime firstDate =
                    periodEnding?.startDate ??
                    DateTime.now().subtract(const Duration(days: 365));
                DateTime lastDate =
                    periodStarting?.endDate ??
                    DateTime.now().add(const Duration(days: 365));

                // Add 1 day buffer to avoid zero-length periods
                firstDate = firstDate.add(const Duration(days: 1));
                lastDate = lastDate.subtract(const Duration(days: 1));

                if (firstDate.isAfter(lastDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot move: No space between periods.'),
                    ),
                  );
                  return;
                }

                final newDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                );

                if (newDate != null) {
                  // If we move a point, we update the endDate of the previous and startDate of the next
                  if (periodEnding != null) {
                    await ref
                        .read(periodProvider.notifier)
                        .adjustPeriodEnd(periodEnding.id, newDate);
                  } else if (periodStarting != null) {
                    // This is the very first period start
                    await ref
                        .read(financialPeriodRepositoryProvider)
                        .updatePeriodDates(
                          periodStarting.id,
                          newDate,
                          periodStarting.endDate,
                        );
                    ref.invalidate(allPeriodsProvider);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('PICK NEW DATE'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartEarlySheet(BuildContext context, DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'NEW CYCLE',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              'Démarrer le nouveau mois au ${DateFormat('dd MMM').format(selectedDate)} ?',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(periodProvider.notifier)
                    .startNextPeriod(customStartDate: selectedDate);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('START NEW MONTH NOW'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
  ) {
    // A household ID of 0...0 means it's a default/system account
    // that hasn't been properly assigned yet, but here we just check isPublic
    return Card(
      child: ListTile(
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Only show lock if the account is PRIVATE (not public)
            if (!account.isPublic) ...[
              const SizedBox(width: 8),
              const Icon(LucideIcons.lock, size: 12, color: Colors.grey),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<int>(
              future: ref.watch(accountBalanceProvider(account.id).future),
              builder: (context, snapshot) {
                final balance = snapshot.data ?? 0;
                final currency =
                    ref.watch(householdProvider).value?.currency ?? 'EUR';
                final formatter = NumberFormat.simpleCurrency(name: currency);
                return Text(
                  formatter.format(balance / 100.0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.ellipsis_vertical, size: 18),
              onSelected: (val) {
                if (val == 'edit') {
                  _showEditAccountDialog(context, ref, account);
                } else if (val == 'delete') {
                  _showDeleteConfirmation(context, ref, account);
                } else if (val == 'default') {
                  ref.read(accountProvider.notifier).setAsDefault(account);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(LucideIcons.pencil, size: 16),
                      SizedBox(width: 8),
                      Text('Edit Name'),
                    ],
                  ),
                ),
                if (!account.isDefault)
                  const PopupMenuItem(
                    value: 'default',
                    child: Row(
                      children: [
                        Icon(LucideIcons.circle_check, size: 16),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                if (!account.isDefault)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash_2, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
  ) {
    final controller = TextEditingController(text: account.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('EDIT ACCOUNT'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Account Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await ref
                    .read(accountProvider.notifier)
                    .updateAccountName(account.id, controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DELETE ACCOUNT?'),
        content: Text(
          'Are you sure you want to delete "${account.name}"? This will also delete all its transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(accountProvider.notifier)
                  .deleteAccount(account);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String type = 'checking';
    bool isPublic = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'ADD ACCOUNT',
            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., Main Checking',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(
                      value: 'checking',
                      child: Text('Checking'),
                    ),
                    DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    'Public (Shared)',
                    style: TextStyle(fontSize: 14),
                  ),
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
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final initialBalance =
                      ((double.tryParse(
                                    balanceController.text.replaceAll(',', '.'),
                                  ) ??
                                  0) *
                              100)
                          .toInt();

                  FocusScope.of(context).unfocus();
                  await ref
                      .read(accountProvider.notifier)
                      .createAccount(
                        nameController.text,
                        type: type,
                        isPublic: isPublic,
                        initialBalance: initialBalance,
                      );
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import '../../../core/models/recurring_template_model.dart';
import '../../accounts/providers/account_provider.dart';
import '../../household/providers/household_provider.dart';
import '../providers/recurring_template_provider.dart';

class RecurringTemplatesScreen extends ConsumerWidget {
  const RecurringTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(allRecurringTemplatesProvider);
    final currency = ref.watch(householdProvider).value?.currency ?? 'EUR';
    final formatter = NumberFormat.simpleCurrency(name: currency);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABONNEMENTS', style: TextStyle(letterSpacing: 2)),
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.repeat, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun abonnement configuré.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showAddTemplateDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('AJOUTER UN ABONNEMENT'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: templates.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final template = templates[index];
              return _TemplateCard(template: template, formatter: formatter);
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateDialog(context, ref),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showAddTemplateDialog(BuildContext context, WidgetRef ref) {
    // Basic dialog implementation - can be expanded
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String frequency = 'monthly';
    String type = 'expense';
    String? selectedAccountId;

    final accounts = ref.read(accountsProvider).value ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('NOUVEL ABONNEMENT'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Dépense')),
                    DropdownMenuItem(value: 'income', child: Text('Revenu')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: frequency,
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Mensuel')),
                    DropdownMenuItem(
                      value: 'weekly',
                      child: Text('Hebdomadaire'),
                    ),
                  ],
                  onChanged: (val) => setState(() => frequency = val!),
                  decoration: const InputDecoration(labelText: 'Fréquence'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedAccountId,
                  items: accounts
                      .map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedAccountId = val);
                  },
                  decoration: const InputDecoration(labelText: 'Compte'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.isNotEmpty &&
                    selectedAccountId != null) {
                  final amount =
                      (double.tryParse(amountController.text) ?? 0) * 100;
                  ref
                      .read(recurringTemplateProvider.notifier)
                      .createTemplate(
                        accountId: selectedAccountId!,
                        description: descController.text,
                        amount: amount.toInt(),
                        type: type,
                        frequency: frequency,
                        startDate:
                            DateTime.now(), // For simplicity, start today
                      );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('CRÉER'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final RecurringTemplateModel template;
  final NumberFormat formatter;

  const _TemplateCard({required this.template, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(
          template.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${template.cronSchedule == 'monthly' ? 'Mensuel' : 'Hebdo'} • Prochain: ${template.nextExecutionDate != null ? DateFormat('dd/MM').format(template.nextExecutionDate!) : 'N/A'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatter.format(template.amount / 100),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: template.type == 'expense' ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Switch.adaptive(
              value: template.isActive,
              onChanged: (_) => ref
                  .read(recurringTemplateProvider.notifier)
                  .toggleStatus(template),
              activeTrackColor: Colors.black,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        onLongPress: () {
          _showDeleteDialog(context, ref);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SUPPRIMER ?'),
        content: const Text('Voulez-vous vraiment supprimer cet abonnement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NON'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(recurringTemplateProvider.notifier)
                  .deleteTemplate(template.id);
              Navigator.pop(context);
            },
            child: const Text('OUI', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import '../../../core/models/project_model.dart';
import '../../household/providers/household_provider.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/providers/selected_account_provider.dart';
import '../../../shared/widgets/account_selector_dropdown.dart';
import '../providers/project_provider.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAccount = ref.watch(selectedAccountProvider);
    final allProjectsAsync = ref.watch(allProjectsProvider);

    final accountsAsync = ref.watch(accountsProvider);
    final currency = ref.watch(householdProvider).value?.currency ?? 'EUR';
    final formatter = NumberFormat.simpleCurrency(name: currency);

    if (accountsAsync.isLoading && selectedAccount == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROJECTS',
          style: TextStyle(letterSpacing: 2),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const AccountSelectorDropdown(),
          const SizedBox(height: 16),
          Expanded(
            child: allProjectsAsync.when(
              data: (allProjects) {
                developer.log('PROJECTS SCREEN: Received ${allProjects.length} total projects from provider', name: 'project.ui');
                
                final projects = selectedAccount != null
                    ? allProjects.where((p) {
                        final match = p.accountId == selectedAccount.id;
                        if (!match) {
                          developer.log('PROJECTS SCREEN: Filtering out project ${p.name} (AccID: ${p.accountId}) vs Selected: ${selectedAccount.id}', name: 'project.ui');
                        }
                        return match;
                      }).toList()
                    : <ProjectModel>[];

                developer.log('PROJECTS SCREEN: Displaying ${projects.length} projects for account ${selectedAccount?.name}', name: 'project.ui');

                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.target, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No projects for this account.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _showCreateProjectDialog(context, ref, initialAccountId: selectedAccount?.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CREATE PROJECT'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return _ProjectCard(project: project, formatter: formatter);
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: Colors.black)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: selectedAccount != null ? FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context, ref, initialAccountId: selectedAccount.id),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ) : null,
    );
  }

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref, {String? initialAccountId}) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NEW PROJECT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'e.g., Japan Trip',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Goal (optional)',
                hintText: 'e.g., 3000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final amount = int.tryParse(amountController.text) ?? 0;
                ref
                    .read(projectProvider.notifier)
                    .createProject(
                      nameController.text,
                      amount * 100, // Convert to cents
                      accountId: initialAccountId,
                    );
                Navigator.pop(context);
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
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  final ProjectModel project;
  final NumberFormat formatter;

  const _ProjectCard({required this.project, required this.formatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spentAsync = ref.watch(projectSpentProvider(project.id));
    final debtAsync = ref.watch(projectDebtProvider(project.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black12),
      ),
      elevation: 0,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to Project Detail
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              spentAsync.when(
                data: (spent) {
                  final progress = project.targetAmount > 0
                      ? (spent.abs() / project.targetAmount).clamp(0.0, 1.0)
                      : 0.0;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dépensé: ${formatter.format(spent.abs() / 100)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (project.targetAmount > 0)
                            Text(
                              'Objectif: ${formatter.format(project.targetAmount / 100)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (project.targetAmount > 0) ...[
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black12,
                          color: Colors.black,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Erreur: $err'),
              ),
              debtAsync.when(
                data: (debt) {
                  if (debt >= 0) {
                    return const SizedBox.shrink(); // Debt is negative in transactions (expense)
                  }

                  final positiveDebt = debt.abs();

                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          size: 16,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Déséquilibre : Le compte joint vous doit ${formatter.format(positiveDebt / 100)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showAbsorbDebtDialog(context, ref),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Éponger',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbsorbDebtDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éponger la dette ?'),
        content: const Text(
          'Cela marquera toutes vos dépenses personnelles pour ce projet comme des "dons" (ignorés dans les calculs de remboursement). Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(projectProvider.notifier).absorbDebt(project.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

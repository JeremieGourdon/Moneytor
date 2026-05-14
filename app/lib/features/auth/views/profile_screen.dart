import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE', style: TextStyle(letterSpacing: 2)),
        actions: [
          IconButton(
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: profile.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No profile found. Please set up your household.'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Name: ${user.firstName}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${user.role}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Household ID: ${user.householdId}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (user.sharedHouseholdId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Shared Household: ${user.sharedHouseholdId}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 32),
                if (user.sharedHouseholdId == null)
                  ElevatedButton.icon(
                    onPressed: () => context.push('/setup-household'),
                    icon: const Icon(LucideIcons.users),
                    label: const Text('REJOINDRE UN FOYER PARTAGÉ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  leading: const Icon(LucideIcons.repeat),
                  title: const Text('Abonnements & Récurrence'),
                  subtitle: const Text('Gérer vos paiements automatiques'),
                  trailing: const Icon(LucideIcons.chevron_right, size: 16),
                  onTap: () => context.push('/recurring'),
                ),
                const Divider(),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

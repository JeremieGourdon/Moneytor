import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/widgets/quick_add_sheet.dart';
import '../../features/auth/providers/profile_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    // If profile is loading or user is new (redirection to onboarding is pending),
    // show a clean splash/loading state to prevent dashboard flash.
    if (profileAsync.isLoading || profileAsync.value?.firstName == 'New User') {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(location),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layout_dashboard, size: 20),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.landmark, size: 20),
            label: 'Accounts',
          ),
          // Placeholder for the FAB gap
          BottomNavigationBarItem(
            icon: Opacity(opacity: 0, child: Icon(LucideIcons.plus)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet, size: 20),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.briefcase, size: 20),
            label: 'Projects',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickAdd(context);
        },
        child: const Icon(LucideIcons.plus, size: 28),
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/accounts')) return 1;
    if (location.startsWith('/budgets')) return 3;
    if (location.startsWith('/projects')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/accounts');
        break;
      case 3:
        context.go('/budgets');
        break;
      case 4:
        context.go('/projects');
        break;
    }
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddSheet(),
    );
  }
}

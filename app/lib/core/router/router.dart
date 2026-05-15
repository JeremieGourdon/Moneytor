import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/profile_provider.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/projects/views/projects_screen.dart';
import '../../features/recurring/views/recurring_templates_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/household/views/household_setup_screen.dart';
import '../../features/accounts/views/accounts_screen.dart';
import '../../features/dashboard/views/dashboard_screen.dart';
import '../../features/budgets/views/budgets_screen.dart';
import '../../features/budgets/views/budget_detail_screen.dart';
import '../../features/onboarding/views/onboarding_screen.dart';
import '../models/budget_model.dart';
import '../../shared/widgets/main_layout.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      // 1. Wait for initial session recovery
      if (authState.isLoading) return null;

      final loggedIn = authState.value != null;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) return loggingIn ? null : '/login';

      // 2. Wait for profile to load (from local SQLite/PowerSync)
      if (profileAsync.isLoading) return null;

      // Redirect to onboarding if profile is "New User"
      final profile = profileAsync.value;
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (profile?.firstName == 'New User' && !isOnboarding) {
        return '/onboarding';
      }

      if (loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.black)),
        ),
      ),
      GoRoute(
        path: '/setup-household',
        builder: (context, state) => const HouseholdSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetsScreen(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) =>
                    BudgetDetailScreen(budget: state.extra as BudgetModel),
              ),
            ],
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/recurring',
            builder: (context, state) => const RecurringTemplatesScreen(),
          ),
        ],
      ),
    ],
  );
}

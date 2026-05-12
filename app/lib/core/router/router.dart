import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/profile_provider.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/profile_screen.dart';
import '../../features/household/views/household_setup_screen.dart';
import '../../features/accounts/views/accounts_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loggedIn = authState.value != null;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) return loggingIn ? null : '/login';
      
      // Check for household
      final profile = ref.read(profileProvider).value;
      if (profile != null && profile.householdId == '00000000-0000-0000-0000-000000000000') {
        if (state.matchedLocation != '/setup-household') return '/setup-household';
      }

      if (loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/setup-household',
        builder: (context, state) => const HouseholdSetupScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Dashboard Placeholder'))),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

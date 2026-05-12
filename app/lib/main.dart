import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytor/features/auth/providers/auth_provider.dart';
import 'package:moneytor/features/auth/providers/profile_provider.dart';
import 'package:moneytor/features/auth/views/login_screen.dart';
import 'package:moneytor/features/auth/views/profile_screen.dart';
import 'package:moneytor/features/household/views/household_setup_screen.dart';
import 'package:moneytor/shared/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual credentials
  await Supabase.initialize(
    url: 'https://rfcvkrmqzvqxjbmgjxnf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmY3Zrcm1xenZxeGpibWdqeG5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MzA3MzcsImV4cCI6MjA5NDEwNjczN30.UR2xWoT_eVHFTQQn6vTNyxrQ3gMAXAFVOtDEjSbqYRw',
  );

  runApp(const ProviderScope(child: MoneytorApp()));
}

class MoneytorApp extends ConsumerWidget {
  const MoneytorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Moneytor',
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();

          // Check if user has a household
          return ref.watch(profileProvider).when(
                data: (profile) {
                  // If profile is null or has no household_id (placeholder UUID check)
                  if (profile == null ||
                      profile.householdId == '00000000-0000-0000-0000-000000000000') {
                    return const HouseholdSetupScreen();
                  }
                  return const ProfileScreen();
                },
                loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator(color: Colors.black))),
                error: (err, stack) =>
                    Scaffold(body: Center(child: Text('Profile Error: $err'))),
              );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.black)),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Auth Error: $err')),
        ),
      ),
    );
  }
}

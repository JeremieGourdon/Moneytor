import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytor/features/auth/providers/auth_provider.dart';
import 'package:moneytor/features/auth/views/login_screen.dart';
import 'package:moneytor/features/auth/views/profile_screen.dart';
import 'package:moneytor/shared/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual credentials
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
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
          return const ProfileScreen();
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytor/core/router/router.dart';
import 'package:moneytor/shared/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual credentials
  await Supabase.initialize(
    url: 'https://rfcvkrmqzvqxjbmgjxnf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmY3Zrcm1xenZxeGpibWdqeG5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MzA3MzcsImV4cCI6MjA5NDEwNjczN30.UR2xWoT_eVHFTQQn6vTNyxrQ3gMAXAFVOtDEjSbqYRw',
  );

  runApp(const ProviderScope(child: MoneytorApp()));
}

class MoneytorApp extends ConsumerWidget {
  const MoneytorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Moneytor',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}

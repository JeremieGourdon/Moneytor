import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytor/shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MoneytorApp()));
}

class MoneytorApp extends ConsumerWidget {
  const MoneytorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Moneytor',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Moneytor Initialized', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}

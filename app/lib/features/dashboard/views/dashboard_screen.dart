import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/profile_provider.dart';
import '../../periods/providers/period_provider.dart';
import '../../household/providers/household_provider.dart';
import '../../transactions/providers/transaction_provider.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final currentPeriod = ref.watch(currentPeriodProvider).value;
    final totalRavAsync = ref.watch(totalDisposableIncomeProvider);
    final currency = ref.watch(householdProvider).value?.currency ?? 'EUR';
    final formatter = NumberFormat.simpleCurrency(name: currency);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPeriod?.name.toUpperCase() ?? 'NO ACTIVE PERIOD',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF71717A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bonjour, ${profile?.firstName ?? 'User'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(LucideIcons.bell, size: 24),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Hero RAV Section (The Split Card)
              totalRavAsync.when(
                data: (rav) => _buildHeroRAV(context, rav, formatter),
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.black)),
                error: (err, _) => Text('Error: $err'),
              ),

              const SizedBox(height: 32),

              const Text(
                'COMING THIS WEEK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                height: 120,
                child: Center(
                    child: Text('Carousel coming soon...',
                        style: TextStyle(color: Colors.grey))),
              ),

              const SizedBox(height: 32),
              const Text(
                'BUDGETS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 16),
              const AspectRatio(
                aspectRatio: 1,
                child: Center(
                    child: Text('Budget Grid coming soon...',
                        style: TextStyle(color: Colors.grey))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroRAV(
      BuildContext context, int ravCents, NumberFormat formatter) {
    final ravDouble = ravCents / 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT DISPOSABLE INCOME',
            style: TextStyle(
              color: Color(0xFF71717A),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(ravDouble),
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF27272A)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Forecasted Month-End',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                '--.-- €', // TODO: Add forecasted logic
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page == 0 && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre prénom')),
      );
      return;
    }

    if (_pageController.page! < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref
          .read(onboardingProvider.notifier)
          .setStep((_pageController.page! + 1).toInt());
    } else {
      _finish();
    }
  }

  void _prevPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref
          .read(onboardingProvider.notifier)
          .setStep((_pageController.page! - 1).toInt());
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    ref.listen(onboardingProvider, (previous, next) {
      if (next.value != null && previous?.value == null) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(next.value!.step);
        }
        _nameController.text = next.value!.firstName;
      }

      if (next.value?.error != null &&
          next.value?.error != previous?.value?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${next.value!.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: onboardingState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text('Erreur critique: $err')),
        data: (state) {
          if (state.isComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/dashboard');
            });
            return const SizedBox.shrink();
          }

          if (state.isProcessing) {
            return _buildProcessingState(state);
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(state),
                      _buildStep3(state),
                      _buildStep4(state),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildFooter(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingState(OnboardingState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black),
          const SizedBox(height: 32),
          Text(
            state.processingStatus ?? 'Création des comptes...',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(onboardingProvider.notifier).completeOnboarding(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(LucideIcons.shield_check, size: 80, color: Colors.black),
          const SizedBox(height: 32),
          const Text(
            'Bienvenue sur Moneytor',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Moneytor est une application locale-first conçue pour une gestion financière transparente et privée.',
            style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Notre mission : vous donner une vision claire de votre "Reste à Vivre" réel, sans fioritures et sans compromis sur votre vie privée.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Comment vous appelez-vous ?',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFFF9F9F9),
            ),
            onChanged: (val) =>
                ref.read(onboardingProvider.notifier).setFirstName(val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(OnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(LucideIcons.globe, size: 80, color: Colors.black),
          const SizedBox(height: 32),
          const Text(
            'Devise du foyer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sélectionnez la devise principale utilisée pour vos comptes et budgets.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          DropdownButtonFormField<String>(
            initialValue: state.currency,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Devise',
              filled: true,
              fillColor: Color(0xFFF9F9F9),
            ),
            items: const [
              DropdownMenuItem(value: 'EUR', child: Text('Euro')),
              DropdownMenuItem(value: 'USD', child: Text('Dollar')),
              DropdownMenuItem(value: 'GBP', child: Text('Livre Sterling')),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(onboardingProvider.notifier).setCurrency(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(OnboardingState state) {
    final now = DateTime.now();
    final months = [
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Icon(LucideIcons.calendar, size: 80, color: Colors.black),
          const SizedBox(height: 32),
          const Text(
            'Fin de cycle',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'À quel jour du mois se termine votre cycle financier ? Nous en déduirons votre mois budgétaire actuel.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<int>(
            initialValue: state.cycleEndDay,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dernier jour du cycle (ex: 28)',
              filled: true,
              fillColor: Color(0xFFF9F9F9),
            ),
            items: List.generate(31, (index) => index + 1)
                .map(
                  (day) => DropdownMenuItem(value: day, child: Text('Le $day')),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(onboardingProvider.notifier).setCycleEndDay(val);
              }
            },
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<DateTime>(
            initialValue: months.firstWhere(
              (m) =>
                  m.year == state.initialMonth.year &&
                  m.month == state.initialMonth.month,
              orElse: () => months[1],
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Mois financier calculé',
              filled: true,
              fillColor: Color(0xFFF9F9F9),
              helperText: 'Le cycle suivant commencera le jour d\'après.',
            ),
            items: months
                .map(
                  (month) => DropdownMenuItem(
                    value: month,
                    child: Text(DateFormat('MMMM yyyy').format(month)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(onboardingProvider.notifier).setInitialMonth(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(OnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(LucideIcons.landmark, size: 80, color: Colors.black),
          const SizedBox(height: 32),
          const Text(
            'Configuration Initiale',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nous allons créer un compte courant et un budget "Imprévus" pour vos dépenses non planifiées.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE4E4E7)),
            ),
            child: SwitchListTile(
              title: const Text(
                'Créer un compte d\'épargne',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Un compte dédié à vos économies et projets.',
              ),
              value: state.createSavingsAccount,
              activeTrackColor: Colors.black,
              onChanged: (val) =>
                  ref.read(onboardingProvider.notifier).setCreateSavings(val),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(OnboardingState state) {
    final currentStep = state.step;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep > 0)
          TextButton(
            onPressed: _prevPage,
            child: const Text(
              'Précédent',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          )
        else
          const SizedBox(width: 80),
        Row(
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentStep
                    ? Colors.black
                    : Colors.grey.shade300,
              ),
            );
          }),
        ),
        ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            currentStep == 3 ? 'Terminer' : 'Suivant',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

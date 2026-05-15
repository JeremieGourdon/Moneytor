import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/profile_provider.dart';
import '../../auth/repositories/profile_repository.dart';
import '../../periods/providers/period_provider.dart';
import 'dart:async';

part 'onboarding_provider.g.dart';

class OnboardingState {
  final int step;
  final String firstName;
  final String currency;
  final int cycleEndDay;
  final DateTime initialMonth;
  final bool createSavingsAccount;
  final bool isProcessing;
  final String? processingStatus; // Track the human-readable status
  final String? error;
  final bool isComplete;

  OnboardingState({
    this.step = 0,
    this.firstName = '',
    this.currency = 'EUR',
    this.cycleEndDay = 28,
    DateTime? initialMonth,
    this.createSavingsAccount = true,
    this.isProcessing = false,
    this.processingStatus,
    this.error,
    this.isComplete = false,
  }) : initialMonth =
           initialMonth ?? DateTime(DateTime.now().year, DateTime.now().month);

  OnboardingState copyWith({
    int? step,
    String? firstName,
    String? currency,
    int? cycleEndDay,
    DateTime? initialMonth,
    bool? createSavingsAccount,
    bool? isProcessing,
    String? processingStatus,
    String? error,
    bool? isComplete,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      firstName: firstName ?? this.firstName,
      currency: currency ?? this.currency,
      cycleEndDay: cycleEndDay ?? this.cycleEndDay,
      initialMonth: initialMonth ?? this.initialMonth,
      createSavingsAccount: createSavingsAccount ?? this.createSavingsAccount,
      isProcessing: isProcessing ?? this.isProcessing,
      processingStatus: processingStatus ?? this.processingStatus,
      error: error,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  static const String _prefStep = 'onboarding_step';
  static const String _prefFirstName = 'onboarding_first_name';
  static const String _prefCurrency = 'onboarding_currency';
  static const String _prefCycleEnd = 'onboarding_cycle_end';
  static const String _prefInitialMonth = 'onboarding_initial_month';
  static const String _prefCreateSavings = 'onboarding_create_savings';
  static const String _prefIsProcessing = 'onboarding_is_processing';

  @override
  Future<OnboardingState> build() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMonthTs = prefs.getInt(_prefInitialMonth);
    final cycleEnd = prefs.getInt(_prefCycleEnd) ?? 28;

    final initialMonth = savedMonthTs != null
        ? DateTime.fromMillisecondsSinceEpoch(savedMonthTs)
        : _guessInitialMonth(cycleEnd);

    final state = OnboardingState(
      step: prefs.getInt(_prefStep) ?? 0,
      firstName: prefs.getString(_prefFirstName) ?? '',
      currency: prefs.getString(_prefCurrency) ?? 'EUR',
      cycleEndDay: cycleEnd,
      initialMonth: initialMonth,
      createSavingsAccount: prefs.getBool(_prefCreateSavings) ?? true,
      isProcessing: prefs.getBool(_prefIsProcessing) ?? false,
    );

    if (state.isProcessing) {
      Future.microtask(() => _processCompletion(state));
    }

    return state;
  }

  DateTime _guessInitialMonth(int cycleEndDay) {
    final now = DateTime.now();
    if (now.day > cycleEndDay) {
      return DateTime(now.year, now.month + 1);
    }
    return DateTime(now.year, now.month);
  }

  void setStep(int step) {
    state = AsyncValue.data(state.value!.copyWith(step: step, error: null));
    _saveState();
  }

  void setFirstName(String name) {
    state = AsyncValue.data(
      state.value!.copyWith(firstName: name, error: null),
    );
    _saveState();
  }

  void setCurrency(String currency) {
    state = AsyncValue.data(
      state.value!.copyWith(currency: currency, error: null),
    );
    _saveState();
  }

  void setCycleEndDay(int day) {
    final newGuess = _guessInitialMonth(day);
    state = AsyncValue.data(
      state.value!.copyWith(
        cycleEndDay: day,
        initialMonth: newGuess,
        error: null,
      ),
    );
    _saveState();
  }

  void setInitialMonth(DateTime month) {
    state = AsyncValue.data(
      state.value!.copyWith(initialMonth: month, error: null),
    );
    _saveState();
  }

  void setCreateSavings(bool create) {
    state = AsyncValue.data(
      state.value!.copyWith(createSavingsAccount: create, error: null),
    );
    _saveState();
  }

  Future<void> _saveState() async {
    if (state.value == null) return;
    final s = state.value!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefStep, s.step);
    await prefs.setString(_prefFirstName, s.firstName);
    await prefs.setString(_prefCurrency, s.currency);
    await prefs.setInt(_prefCycleEnd, s.cycleEndDay);
    await prefs.setInt(
      _prefInitialMonth,
      s.initialMonth.millisecondsSinceEpoch,
    );
    await prefs.setBool(_prefCreateSavings, s.createSavingsAccount);
    await prefs.setBool(_prefIsProcessing, s.isProcessing);
  }

  Future<void> completeOnboarding() async {
    final s = state.value!.copyWith(
      isProcessing: true,
      error: null,
      processingStatus: 'Initialisation...',
    );
    state = AsyncValue.data(s);
    await _saveState();
    await _processCompletion(s);
  }

  Future<void> _processCompletion(OnboardingState s) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final profile = await ref
          .read(profileRepositoryProvider)
          .getProfile(userId);

      if (profile == null) throw Exception('Profil introuvable sur le serveur');

      // 1. Update Household
      _updateStatus('Configuration du foyer...');
      int startDay = s.cycleEndDay + 1;
      if (startDay > 31) startDay = 1;

      await supabase
          .from('households')
          .update({'currency': s.currency, 'default_month_start_day': startDay})
          .eq('id', profile.householdId);

      // 2. Setup Period
      _updateStatus('Création de votre calendrier financier...');
      await supabase
          .from('financial_periods')
          .delete()
          .eq('household_id', profile.householdId);

      DateTime startDate;
      int prevMonth = s.initialMonth.month == 1 ? 12 : s.initialMonth.month - 1;
      int prevYear = s.initialMonth.month == 1
          ? s.initialMonth.year - 1
          : s.initialMonth.year;
      startDate = DateTime.utc(prevYear, prevMonth, startDay);

      DateTime endDate = DateTime.utc(
        s.initialMonth.year,
        s.initialMonth.month,
        s.cycleEndDay,
        23,
        59,
        59,
      );

      await supabase.from('financial_periods').insert({
        'household_id': profile.householdId,
        'name': DateFormat('MMMM yyyy').format(s.initialMonth),
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      // 3. Optional Savings Account
      if (s.createSavingsAccount) {
        _updateStatus('Création des comptes et projets...');
        final accountResponse = await supabase
            .from('accounts')
            .insert({
              'household_id': profile.householdId,
              'owner_id': userId,
              'name': 'Compte Épargne',
              'type': 'savings',
              'is_public': false,
              'is_default': false,
            })
            .select()
            .single();

        final savingsAccountId = accountResponse['id'] as String;

        await supabase.from('projects').insert({
          'household_id': profile.householdId,
          'account_id': savingsAccountId,
          'name': 'Épargne Mensuelle',
          'target_amount': 0,
          'is_pinned_to_dashboard': true,
        });
      }

      // 4. Sync Guard
      _updateStatus('Synchronisation locale des données...');
      try {
        await ref
            .read(currentPeriodProvider.future)
            .timeout(const Duration(seconds: 10));
      } catch (_) {}

      // 5. Update Profile Name
      _updateStatus('Finalisation de votre profil...');
      await supabase
          .from('users')
          .update({'first_name': s.firstName})
          .eq('id', userId);

      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      state = AsyncValue.data(
        s.copyWith(
          isProcessing: false,
          isComplete: true,
          processingStatus: 'Tout est prêt !',
        ),
      );

      ref.invalidate(profileProvider);
      ref.invalidate(currentPeriodProvider);
    } catch (e) {
      state = AsyncValue.data(
        s.copyWith(isProcessing: false, error: e.toString()),
      );
      await _saveState();
    }
  }

  void _updateStatus(String status) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(processingStatus: status));
    }
  }
}

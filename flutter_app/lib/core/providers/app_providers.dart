import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../data/onboarding_data.dart';
import '../models/mizan_models.dart';
import '../services/adhan_prayer_service.dart';
import '../services/ai_gateway_service.dart';
import '../services/companion_audio_service.dart';
import '../services/native_bridge_service.dart';
import '../services/storage_service.dart';

// --- Bottom Navigation & Sub-View State ---
final appTabProvider = StateProvider<AppTab>((ref) => AppTab.salah);
final salahSubViewProvider =
    StateProvider<SalahSubView>((ref) => SalahSubView.prayer);
final coachSubViewProvider =
    StateProvider<CoachSubView>((ref) => CoachSubView.chat);
final profileSubViewProvider =
    StateProvider<ProfileSubView>((ref) => ProfileSubView.account);
final governanceSectionProvider =
    StateProvider<GovernanceSection>((ref) => GovernanceSection.ethics);
final plannerSubViewProvider =
    StateProvider<PlannerSubView>((ref) => PlannerSubView.goals);
final explorerSelectedFileProvider =
    StateProvider<String?>((ref) => null);

final showDisclosureModalProvider = StateProvider<bool>((ref) => false);
final showShieldModalProvider = StateProvider<bool>((ref) => false);
final shieldAppNameProvider =
    StateProvider<String>((ref) => 'Instagram Reels');

final showOnboardingModalProvider = StateProvider<bool>((ref) => false);
final onboardingInitialViewProvider =
    StateProvider<String>((ref) => 'tour'); // 'tour' | 'qa'
final onboardingBannerDismissedProvider = StateProvider<bool>((ref) {
  return StorageService.instance.isOnboardingCompleted();
});
final onboardingStepIndexProvider = StateProvider<int>((ref) => 0);
final onboardingStepsCompletedProvider =
    StateProvider<Set<String>>((ref) => {'step-salah'});

// --- Prayer & Astronomical Coordinates State ---
class PrayerSettingsState {
  final CityLocation city;
  final CalculationMethod method;
  final AsrMethod madhab;
  final DateTime currentTime;

  const PrayerSettingsState({
    required this.city,
    required this.method,
    required this.madhab,
    required this.currentTime,
  });

  PrayerSettingsState copyWith({
    CityLocation? city,
    CalculationMethod? method,
    AsrMethod? madhab,
    DateTime? currentTime,
  }) {
    return PrayerSettingsState(
      city: city ?? this.city,
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

class PrayerNotifier extends StateNotifier<PrayerSettingsState> {
  Timer? _timer;
  PrayerNotifier()
      : super(PrayerSettingsState(
          city: AdhanPrayerService.presetCities[0],
          method: CalculationMethod.mwl,
          madhab: AsrMethod.shafi,
          currentTime: DateTime.now(),
        )) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(currentTime: DateTime.now());
    });
  }

  void setCity(CityLocation city) => state = state.copyWith(city: city);
  void setMethod(CalculationMethod m) => state = state.copyWith(method: m);
  void setMadhab(AsrMethod m) => state = state.copyWith(madhab: m);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final prayerSettingsProvider =
    StateNotifierProvider<PrayerNotifier, PrayerSettingsState>(
  (ref) => PrayerNotifier(),
);

final prayerCalculationProvider = Provider<PrayerCalculationOutput>((ref) {
  final settings = ref.watch(prayerSettingsProvider);
  return AdhanPrayerService.calculatePrayerTimes(
    city: settings.city,
    nowOverride: settings.currentTime,
    method: settings.method,
    madhab: settings.madhab,
  );
});

// --- Habits, Streaks, Grace Days & Badges ---
class StreaksState {
  final List<MicroSunnah> sunnahs;
  final List<MilestoneBadge> badges;
  final int graceDaysRemaining;
  final int totalDhikrCount;
  final MilestoneBadge? newlyUnlockedBadge;

  const StreaksState({
    required this.sunnahs,
    required this.badges,
    this.graceDaysRemaining = 3,
    this.totalDhikrCount = 186,
    this.newlyUnlockedBadge,
  });

  int get completedTodayCount => sunnahs.where((s) => s.completed).length;

  int get highestActiveStreak => sunnahs.isEmpty
      ? 0
      : sunnahs.map((s) => s.streakDays).reduce((a, b) => a > b ? a : b);

  int get unlockedBadgeCount => badges.where((b) => b.unlocked).length;

  StreaksState copyWith({
    List<MicroSunnah>? sunnahs,
    List<MilestoneBadge>? badges,
    int? graceDaysRemaining,
    int? totalDhikrCount,
    MilestoneBadge? newlyUnlockedBadge,
    bool clearNewlyUnlocked = false,
  }) {
    return StreaksState(
      sunnahs: sunnahs ?? this.sunnahs,
      badges: badges ?? this.badges,
      graceDaysRemaining: graceDaysRemaining ?? this.graceDaysRemaining,
      totalDhikrCount: totalDhikrCount ?? this.totalDhikrCount,
      newlyUnlockedBadge: clearNewlyUnlocked
          ? null
          : (newlyUnlockedBadge ?? this.newlyUnlockedBadge),
    );
  }
}

class StreaksNotifier extends StateNotifier<StreaksState> {
  final Ref _ref;
  StreaksNotifier(this._ref)
      : super(StreaksState(
          sunnahs: initialMicroSunnahs,
          badges: initialMilestoneBadges,
        ));

  void toggleHabit(String id) {
    final today = DateTime.now().toIso8601String().split('T').first;
    bool becameCompleted = false;
    final updated = state.sunnahs.map((h) {
      if (h.id != id) return h;
      becameCompleted = !h.completed;
      final newStreak = becameCompleted
          ? h.streakDays + 1
          : (h.streakDays > 0 ? h.streakDays - 1 : 0);
      return h.copyWith(
        completed: becameCompleted,
        streakDays: newStreak,
        longestStreak:
            newStreak > h.longestStreak ? newStreak : h.longestStreak,
        lastCompletedDate: becameCompleted ? today : h.lastCompletedDate,
      );
    }).toList();

    final newMax = updated
        .map((s) => s.streakDays)
        .reduce((a, b) => a > b ? a : b);

    MilestoneBadge? unlockedNow;
    final updatedBadges = state.badges.map((b) {
      if (!b.unlocked && newMax >= b.requiredDays) {
        final unlockedBadge =
            b.copyWith(unlocked: true, unlockedAt: 'Just now');
        unlockedNow = unlockedBadge;
        return unlockedBadge;
      }
      return b;
    }).toList();

    state = state.copyWith(
      sunnahs: updated,
      badges: updatedBadges,
      totalDhikrCount:
          becameCompleted ? state.totalDhikrCount + 33 : state.totalDhikrCount,
      newlyUnlockedBadge: unlockedNow,
    );

    if (becameCompleted) {
      _ref.read(companionProvider.notifier).celebrateHabit();
    }
  }

  void repairWithIstighfar(String id) {
    if (state.graceDaysRemaining <= 0) return;
    final today = DateTime.now().toIso8601String().split('T').first;
    final updated = state.sunnahs.map((h) {
      if (h.id != id) return h;
      final newStreak = h.streakDays + 1;
      return h.copyWith(
        completed: true,
        streakDays: newStreak,
        longestStreak:
            newStreak > h.longestStreak ? newStreak : h.longestStreak,
        lastCompletedDate: today,
      );
    }).toList();

    state = state.copyWith(
      sunnahs: updated,
      graceDaysRemaining: state.graceDaysRemaining - 1,
    );
    _ref.read(companionProvider.notifier).celebrateHabit();
  }

  void clearCelebration() {
    state = state.copyWith(clearNewlyUnlocked: true);
  }
}

final streaksProvider = StateNotifierProvider<StreaksNotifier, StreaksState>(
  (ref) => StreaksNotifier(ref),
);

// --- Personal Goal Tracking (Learning & Task Goals + Local Persistence) ---
class PersonalGoalsNotifier extends StateNotifier<List<PersonalGoal>> {
  final Ref _ref;
  PersonalGoalsNotifier(this._ref) : super(_loadInitial());

  static List<PersonalGoal> _loadInitial() {
    final saved = StorageService.instance.loadPersonalGoals();
    if (saved != null) return saved;
    final starter = buildStarterPersonalGoals();
    StorageService.instance.savePersonalGoals(starter);
    return starter;
  }

  Future<void> _persist(List<PersonalGoal> next) async {
    state = next;
    await StorageService.instance.savePersonalGoals(next);
  }

  Future<void> addGoal(PersonalGoal goal) async {
    await _persist([goal, ...state]);
  }

  Future<void> updateGoal(PersonalGoal updated) async {
    final next = state
        .map((g) => g.id == updated.id
            ? updated.copyWith(updatedAt: DateTime.now().toIso8601String())
            : g)
        .toList();
    await _persist(next);
  }

  Future<void> deleteGoal(String id) async {
    await _persist(state.where((g) => g.id != id).toList());
  }

  Future<void> logProgress(String id, {int delta = 1}) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final nowIso = DateTime.now().toIso8601String();
    bool hitCompletion = false;

    final next = state.map((g) {
      if (g.id != id) return g;
      final newUnits = (g.completedUnits + delta).clamp(0, g.targetUnits);
      final logs = List<String>.from(g.completedLogs);
      if (delta > 0 && !logs.contains(today)) {
        logs.add(today);
      }
      if (!g.isCompleted && newUnits >= g.targetUnits) {
        hitCompletion = true;
      }
      return g.copyWith(
        completedUnits: newUnits,
        completedLogs: logs,
        updatedAt: nowIso,
      );
    }).toList();

    await _persist(next);
    if (hitCompletion) {
      _ref.read(companionProvider.notifier).celebrateHabit();
    }
  }

  Future<void> togglePause(String id) async {
    final nowIso = DateTime.now().toIso8601String();
    final next = state
        .map((g) => g.id == id
            ? g.copyWith(isPaused: !g.isPaused, updatedAt: nowIso)
            : g)
        .toList();
    await _persist(next);
  }

  Future<void> toggleReminder(String id) async {
    final nowIso = DateTime.now().toIso8601String();
    final next = state
        .map((g) => g.id == id
            ? g.copyWith(reminderEnabled: !g.reminderEnabled, updatedAt: nowIso)
            : g)
        .toList();
    await _persist(next);
  }

  Future<void> resetAllToStarter() async {
    await _persist(buildStarterPersonalGoals());
  }
}

final personalGoalsProvider =
    StateNotifierProvider<PersonalGoalsNotifier, List<PersonalGoal>>(
  (ref) => PersonalGoalsNotifier(ref),
);

// --- Real-Time Goal Reminder Notifications Engine ---
class GoalReminderState {
  final GoalReminderAlert? activeAlert;
  final List<GoalReminderAlert> recentHistory;
  final bool osPermissionGranted;
  final Map<String, DateTime> snoozedUntil;

  const GoalReminderState({
    this.activeAlert,
    this.recentHistory = const [],
    this.osPermissionGranted = false,
    this.snoozedUntil = const {},
  });

  GoalReminderState copyWith({
    GoalReminderAlert? activeAlert,
    bool clearActive = false,
    List<GoalReminderAlert>? recentHistory,
    bool? osPermissionGranted,
    Map<String, DateTime>? snoozedUntil,
  }) {
    return GoalReminderState(
      activeAlert: clearActive ? null : (activeAlert ?? this.activeAlert),
      recentHistory: recentHistory ?? this.recentHistory,
      osPermissionGranted: osPermissionGranted ?? this.osPermissionGranted,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    );
  }
}

class GoalReminderNotifier extends StateNotifier<GoalReminderState> {
  final Ref _ref;
  Timer? _ticker;
  final Set<String> _dispatchedKeys = {};

  GoalReminderNotifier(this._ref) : super(const GoalReminderState()) {
    _init();
  }

  Future<void> _init() async {
    await refreshPermissionStatus();
    evaluateDueGoals();
    _ticker = Timer.periodic(
      const Duration(seconds: 15),
      (_) => evaluateDueGoals(),
    );
  }

  Future<void> refreshPermissionStatus() async {
    final ok = await NativeBridgeService.instance.hasNotificationPermission();
    if (mounted) {
      state = state.copyWith(osPermissionGranted: ok);
    }
  }

  Future<void> requestOsPermission() async {
    await NativeBridgeService.instance.requestNotificationPermission();
    await Future.delayed(const Duration(milliseconds: 600));
    await refreshPermissionStatus();
  }

  void evaluateDueGoals() {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T').first;
    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final goals = _ref.read(personalGoalsProvider);

    // 1. Check snoozed goals whose snooze time elapsed
    final nextSnoozes = Map<String, DateTime>.from(state.snoozedUntil);
    for (final entry in state.snoozedUntil.entries) {
      if (!now.isBefore(entry.value)) {
        nextSnoozes.remove(entry.key);
        final matched = goals.where((g) => g.id == entry.key).firstOrNull;
        if (matched != null &&
            matched.reminderEnabled &&
            !matched.isPaused &&
            !matched.isCompleted) {
          state = state.copyWith(snoozedUntil: nextSnoozes);
          _dispatchAlert(matched, isTest: false);
          return;
        }
      }
    }
    if (nextSnoozes.length != state.snoozedUntil.length) {
      state = state.copyWith(snoozedUntil: nextSnoozes);
    }

    // 2. Check scheduled HH:mm matches for today's active goals
    for (final g in goals) {
      if (!g.reminderEnabled ||
          g.isPaused ||
          g.isCompleted ||
          !g.isScheduledToday) {
        continue;
      }
      if (g.scheduledTime == hhmm) {
        final key = '${g.id}_${today}_$hhmm';
        if (_dispatchedKeys.contains(key)) continue;
        _dispatchedKeys.add(key);
        _dispatchAlert(g, isTest: false);
        break;
      }
    }
  }

  Future<void> triggerTestReminder([PersonalGoal? goalOverride]) async {
    final goals = _ref.read(personalGoalsProvider);
    final candidate = goalOverride ??
        goals.where((g) => !g.isCompleted && !g.isPaused).firstOrNull ??
        goals.firstOrNull;
    if (candidate == null) return;
    await _dispatchAlert(candidate, isTest: true);
  }

  Future<void> _dispatchAlert(
    PersonalGoal goal, {
    required bool isTest,
  }) async {
    final alert = GoalReminderAlert(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      goalId: goal.id,
      goalTitle: goal.title,
      scheduledTime: goal.scheduledTime,
      scheduledSlot: goal.scheduledSlot,
      progressText:
          '${goal.completedUnits}/${goal.targetUnits} ${goal.unitLabel} (${goal.progressPercent}%)',
      triggeredAt: DateTime.now(),
      isTest: isTest,
    );

    final updatedHistory = [alert, ...state.recentHistory].take(10).toList();
    state = state.copyWith(
      activeAlert: alert,
      recentHistory: updatedHistory,
    );

    final comp = _ref.read(companionProvider);
    if (comp.soundEnabled) {
      CompanionAudioService.instance.setVolume(comp.soundVolume);
      await CompanionAudioService.instance.playSound(SoundEffectType.salahBell);
    }

    await NativeBridgeService.instance.showGoalReminderNotification(
      id: goal.id.hashCode.abs() % 100000,
      title: isTest
          ? 'Goal Reminder: ${goal.title}'
          : 'Scheduled Goal (${goal.scheduledTime}): ${goal.title}',
      body:
          '${goal.scheduledSlot} · Progress: ${alert.progressText}. Tap to log +1!',
    );
  }

  void dismissAlert() {
    state = state.copyWith(clearActive: true);
  }

  void snoozeActiveAlert({Duration duration = const Duration(minutes: 10)}) {
    final active = state.activeAlert;
    if (active == null) return;
    final nextSnoozes = Map<String, DateTime>.from(state.snoozedUntil)
      ..[active.goalId] = DateTime.now().add(duration);
    state = state.copyWith(
      clearActive: true,
      snoozedUntil: nextSnoozes,
    );
  }

  Future<void> logFromActiveAlert() async {
    final active = state.activeAlert;
    if (active == null) return;
    await _ref
        .read(personalGoalsProvider.notifier)
        .logProgress(active.goalId, delta: 1);
    state = state.copyWith(clearActive: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final goalReminderProvider =
    StateNotifierProvider<GoalReminderNotifier, GoalReminderState>(
  (ref) => GoalReminderNotifier(ref),
);

// --- Digital Shield & Accountability State ---
class ShieldState {
  final bool shortsShieldEnabled;
  final bool accessibilityGranted;
  final int blockedReelsCount;
  final int dailyMinutesUsed;
  final int dailyLimitMinutes;
  final List<PeerAccountabilityNode> peers;

  const ShieldState({
    this.shortsShieldEnabled = true,
    this.accessibilityGranted = false,
    this.blockedReelsCount = 3,
    this.dailyMinutesUsed = 24,
    this.dailyLimitMinutes = 45,
    this.peers = initialPeerNodes,
  });

  ShieldState copyWith({
    bool? shortsShieldEnabled,
    bool? accessibilityGranted,
    int? blockedReelsCount,
    int? dailyMinutesUsed,
    int? dailyLimitMinutes,
    List<PeerAccountabilityNode>? peers,
  }) {
    return ShieldState(
      shortsShieldEnabled: shortsShieldEnabled ?? this.shortsShieldEnabled,
      accessibilityGranted: accessibilityGranted ?? this.accessibilityGranted,
      blockedReelsCount: blockedReelsCount ?? this.blockedReelsCount,
      dailyMinutesUsed: dailyMinutesUsed ?? this.dailyMinutesUsed,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      peers: peers ?? this.peers,
    );
  }
}

class ShieldNotifier extends StateNotifier<ShieldState> {
  ShieldNotifier() : super(const ShieldState());

  void toggleShortsShield() =>
      state = state.copyWith(shortsShieldEnabled: !state.shortsShieldEnabled);

  void grantAccessibility() =>
      state = state.copyWith(accessibilityGranted: true);

  void incrementBlockedReels() =>
      state = state.copyWith(blockedReelsCount: state.blockedReelsCount + 1);

  void setDailyLimit(int mins) => state = state.copyWith(dailyLimitMinutes: mins);

  void sendEncouragement(String peerId) {
    state = state.copyWith(
      peers: state.peers
          .map((p) => p.id == peerId ? p.copyWith(encouragementSent: true) : p)
          .toList(),
    );
  }
}

final shieldProvider = StateNotifierProvider<ShieldNotifier, ShieldState>(
  (ref) => ShieldNotifier(),
);

// --- Bounded Floating Companion State ---
class CompanionNotifier extends StateNotifier<CompanionState> {
  CompanionNotifier() : super(const CompanionState());

  void setEnabled(bool v) => state = state.copyWith(isEnabled: v);
  void setSkin(CompanionSkin s) {
    state = state.copyWith(skin: s, mood: CompanionMood.happy);
    _playIfEnabled(SoundEffectType.waterDrop, 'Harmonic Water-Drop Touch');
  }

  void setPosition(double x, double y) {
    state = state.copyWith(
      posX: x.clamp(0.06, 0.94),
      posY: y.clamp(0.10, 0.88),
    );
  }

  void snapToNearestEdge() {
    final targetX = state.posX < 0.5 ? 0.08 : 0.92;
    state = state.copyWith(
      posX: targetX,
      mood: CompanionMood.resting,
    );
    _playIfEnabled(SoundEffectType.restingHum, 'Edge Snap Resting Hum');
  }

  void setSize(double px) => state = state.copyWith(sizePx: px.clamp(44, 72));

  void setSoundEnabled(bool v) {
    state = state.copyWith(soundEnabled: v);
    CompanionAudioService.instance.setMuted(!v);
  }

  void setVolume(double v) {
    state = state.copyWith(soundVolume: v);
    CompanionAudioService.instance.setVolume(v);
  }

  void setAutoWander(bool v) => state = state.copyWith(autoWanderEnabled: v);
  void setSalahAlert(bool v) =>
      state = state.copyWith(salahLeadAlertEnabled: v);
  void setScreenLimitAlert(bool v) =>
      state = state.copyWith(screenLimitAlertEnabled: v);

  void tapReact() {
    state = state.copyWith(
      mood: CompanionMood.happy,
      isHiding: false,
    );
    _playIfEnabled(SoundEffectType.waterDrop, 'Water-Drop Joy Chirp');
  }

  void triggerSalah10mAlert() {
    state = state.copyWith(
      mood: CompanionMood.salahLead,
      isHiding: false,
      posX: 0.5,
      posY: 0.22,
    );
    _playIfEnabled(SoundEffectType.salahBell, '432Hz Adhan Harmonic Bell');
  }

  void triggerScreenLimitAlert() {
    state = state.copyWith(
      mood: CompanionMood.screenLimit,
      isHiding: false,
    );
    _playIfEnabled(
        SoundEffectType.attentionChime, 'Descending Screen-Budget Chime');
  }

  void celebrateHabit() {
    state = state.copyWith(
      mood: CompanionMood.happy,
      isHiding: false,
    );
    _playIfEnabled(SoundEffectType.celebrationHarp, 'Ascending Pentatonic Harp');
  }

  void togglePeekABoo() {
    final hiding = !state.isHiding;
    state = state.copyWith(
      isHiding: hiding,
      mood: hiding ? CompanionMood.hiding : CompanionMood.happy,
      posX: hiding ? 0.02 : 0.84,
    );
    _playIfEnabled(
      hiding ? SoundEffectType.marimbaTick : SoundEffectType.peekGlissando,
      hiding ? 'Marimba Peek Tuck' : 'Ascending Peek Glissando',
    );
  }

  void previewSound(SoundEffectType type, String label) {
    _playIfEnabled(type, label);
  }

  void _playIfEnabled(SoundEffectType type, String label) {
    state = state.copyWith(lastSoundLabel: label);
    if (state.soundEnabled) {
      CompanionAudioService.instance.setVolume(state.soundVolume);
      CompanionAudioService.instance.playSound(type);
    }
  }
}

final companionProvider =
    StateNotifierProvider<CompanionNotifier, CompanionState>(
  (ref) => CompanionNotifier(),
);

// --- Multi-AI Gateway State ---
class AIGatewayNotifier extends StateNotifier<AIGatewayConfig> {
  AIGatewayNotifier() : super(const AIGatewayConfig()) {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final loaded = await StorageService.instance.loadGatewaySettings();
    state = loaded;
  }

  Future<void> selectProvider(AIProviderId id) async {
    state = state.copyWith(activeProvider: id);
    await StorageService.instance.saveGatewaySettings(state);
  }

  Future<void> setModel(AIProviderId id, String model) async {
    final updated = Map<AIProviderId, String>.from(state.models)..[id] = model;
    state = state.copyWith(models: updated);
    await StorageService.instance.saveGatewaySettings(state);
  }

  Future<void> setApiKey(AIProviderId id, String key) async {
    await StorageService.instance.saveApiKey(id, key);
    final updated = Map<AIProviderId, String>.from(state.apiKeys);
    if (key.trim().isEmpty) {
      updated.remove(id);
    } else {
      updated[id] = key.trim();
    }
    state = state.copyWith(apiKeys: updated);
  }

  Future<void> setTemperature(double t) async {
    state = state.copyWith(temperature: t);
    await StorageService.instance.saveGatewaySettings(state);
  }

  Future<void> setMaxTokens(int m) async {
    state = state.copyWith(maxTokens: m);
    await StorageService.instance.saveGatewaySettings(state);
  }

  Future<void> setFallbackToOffline(bool v) async {
    state = state.copyWith(fallbackToOffline: v);
    await StorageService.instance.saveGatewaySettings(state);
  }

  Future<void> incrementRequests() async {
    state = state.copyWith(totalGatewayRequests: state.totalGatewayRequests + 1);
    await StorageService.instance.saveGatewaySettings(state);
  }
}

final aiGatewayProvider =
    StateNotifierProvider<AIGatewayNotifier, AIGatewayConfig>(
  (ref) => AIGatewayNotifier(),
);

// --- User Profile & Offline Cryptographic Auth State ---
class UserNotifier extends StateNotifier<UserProfile?> {
  UserNotifier() : super(_initialDefaultUser());

  static UserProfile? _initialDefaultUser() {
    final saved = StorageService.instance.loadUserProfile();
    if (saved != null) return saved;
    final now = DateTime.now().toIso8601String();
    return UserProfile(
      id: 'usr_tariq_al_mizan',
      email: 'tariq@mizan.app',
      displayName: 'Tariq Al-Mizan',
      isAnonymous: false,
      avatarId: 'crescent',
      spiritualGoal:
          'Preserving all 5 daily Salah on time & maintaining digital serenity',
      madhab: 'Shafi / Majority',
      preferredLanguage: 'en',
      createdAt: now,
      lastSyncedAt: now,
      biometricLockEnabled: true,
      authMethod: 'local_offline',
    );
  }

  Future<void> login(String email, String password) async {
    final ok = await StorageService.instance.verifyCredential(email, password);
    if (!ok) {
      throw Exception('Invalid credentials or password under 6 characters.');
    }
    final now = DateTime.now().toIso8601String();
    final name = email.split('@').first;
    final prettyName =
        name.isEmpty ? 'Believer' : '${name[0].toUpperCase()}${name.substring(1)}';
    final user = UserProfile(
      id: 'usr_${email.hashCode.abs()}',
      email: email.trim().toLowerCase(),
      displayName: prettyName,
      isAnonymous: false,
      avatarId: 'crescent',
      spiritualGoal: 'Cultivating steadfastness in daily Salah & Micro-Sunnahs',
      madhab: 'Shafi / Majority',
      preferredLanguage: 'en',
      createdAt: now,
      lastSyncedAt: now,
      biometricLockEnabled: false,
      authMethod: 'local_offline',
    );
    await StorageService.instance.saveUserProfile(user);
    state = user;
  }

  Future<void> register(String displayName, String email, String password) async {
    await StorageService.instance.saveRegisteredCredential(email, password);
    final now = DateTime.now().toIso8601String();
    final user = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      displayName: displayName.trim(),
      isAnonymous: false,
      avatarId: 'crescent',
      spiritualGoal: 'Establishing unwavering morning & evening Adhkar',
      madhab: 'Shafi / Majority',
      preferredLanguage: 'en',
      createdAt: now,
      lastSyncedAt: now,
      biometricLockEnabled: false,
      authMethod: 'local_offline',
    );
    await StorageService.instance.saveUserProfile(user);
    state = user;
  }

  Future<void> signInGuest() async {
    final now = DateTime.now().toIso8601String();
    final guest = UserProfile(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest.offline@mizan.local',
      displayName: 'Traveller (Offline Guest)',
      isAnonymous: true,
      avatarId: 'compass',
      spiritualGoal: 'Exploring calm digital boundaries',
      madhab: 'Shafi / Majority',
      preferredLanguage: 'en',
      createdAt: now,
      lastSyncedAt: now,
      biometricLockEnabled: false,
      authMethod: 'anonymous_guest',
    );
    await StorageService.instance.saveUserProfile(guest);
    state = guest;
  }

  Future<void> upgradeGuest(
      String displayName, String email, String password) async {
    if (state == null) return;
    await StorageService.instance.saveRegisteredCredential(email, password);
    final updated = state!.copyWith(
      displayName: displayName.trim(),
      email: email.trim().toLowerCase(),
      isAnonymous: false,
      authMethod: 'local_offline',
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
    await StorageService.instance.saveUserProfile(updated);
    state = updated;
  }

  Future<void> updateProfile({
    String? displayName,
    String? avatarId,
    String? spiritualGoal,
    String? madhab,
    String? preferredLanguage,
    bool? biometricLockEnabled,
  }) async {
    if (state == null) return;
    final updated = state!.copyWith(
      displayName: displayName,
      avatarId: avatarId,
      spiritualGoal: spiritualGoal,
      madhab: madhab,
      preferredLanguage: preferredLanguage,
      biometricLockEnabled: biometricLockEnabled,
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
    await StorageService.instance.saveUserProfile(updated);
    state = updated;
  }

  Future<void> logout() async {
    await StorageService.instance.clearSession();
    state = null;
  }
}

final userProfileProvider =
    StateNotifierProvider<UserNotifier, UserProfile?>((ref) => UserNotifier());

// --- Al-Murshid AI Chat History ---
class AgentChatNotifier extends StateNotifier<List<AgentMessage>> {
  final Ref _ref;
  AgentChatNotifier(this._ref)
      : super([
          AgentMessage(
            id: 'init-1',
            sender: 'agent',
            text:
                'As-salamu alaykum. I am Al-Murshid (المرشد), your 24/7 holistic life mentor. I monitor your spiritual habits, deep work energy, and digital wellbeing to help you walk the path of Istiqamah with Barakah—never shame. How is your heart and focus feeling today?',
            timestamp: DateTime.now(),
            scripturalAnchor: const ScripturalAnchor(
              type: 'hadith',
              textArabic: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
              translation:
                  'The best of people are those who are most beneficial to others.',
              reference: 'Al-Mu’jam al-Awsat 5787',
            ),
            lifeDomain: 'spiritual',
            suggestedActions: const [
              'Plan balanced deep work',
              'Prevent afternoon burnout',
              'Prepare for next Salah',
            ],
            source: 'local-offline-matrix',
          ),
        ]);

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: trimmed,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    final streaks = _ref.read(streaksProvider);
    final goals = _ref.read(personalGoalsProvider);
    final prayer = _ref.read(prayerCalculationProvider);
    final user = _ref.read(userProfileProvider);
    final gateway = _ref.read(aiGatewayProvider);

    final sunnahSummary = streaks.sunnahs
        .map((s) => '${s.title} (${s.streakDays}d)')
        .join(', ');
    final goalsSummary = goals
        .where((g) => !g.isPaused && !g.isCompleted)
        .take(3)
        .map((g) => '${g.title} (${g.completedUnits}/${g.targetUnits} ${g.unitLabel} @ ${g.scheduledTime})')
        .join(', ');
    final habitsSummary = goalsSummary.isEmpty
        ? sunnahSummary
        : '$sunnahSummary | Goals: $goalsSummary';
    final nextPrayerSummary =
        '${prayer.nextPrayer.name} at ${prayer.nextPrayer.time12} (in ${prayer.countdownString})';

    final reply = await AIGatewayService.instance.sendAgentMessage(
      gateway: gateway,
      userMessage: trimmed,
      habitsSummary: habitsSummary,
      nextPrayerSummary: nextPrayerSummary,
      spiritualGoal: user?.spiritualGoal ?? 'Cultivating steadfastness',
    );
    await _ref.read(aiGatewayProvider.notifier).incrementRequests();
    state = [...state, reply];
  }
}

final agentChatProvider =
    StateNotifierProvider<AgentChatNotifier, List<AgentMessage>>(
  (ref) => AgentChatNotifier(ref),
);

// --- Helper functions for Onboarding & Unified Bottom Navigation ---
void openGuidedTour(WidgetRef ref, {String view = 'tour'}) {
  ref.read(onboardingInitialViewProvider.notifier).state = view;
  ref.read(showOnboardingModalProvider.notifier).state = true;
}

void navigateToFeature(WidgetRef ref, AppTab tab, {String? subView}) {
  ref.read(appTabProvider.notifier).state = tab;
  if (tab == AppTab.salah) {
    ref.read(salahSubViewProvider.notifier).state =
        subView == 'streaks' ? SalahSubView.streaks : SalahSubView.prayer;
  } else if (tab == AppTab.planner) {
    ref.read(plannerSubViewProvider.notifier).state =
        subView == 'timeline' ? PlannerSubView.timeline : PlannerSubView.goals;
  } else if (tab == AppTab.coach) {
    if (subView == 'gateway') {
      ref.read(coachSubViewProvider.notifier).state = CoachSubView.gateway;
    } else if (subView == 'companion') {
      ref.read(coachSubViewProvider.notifier).state = CoachSubView.companion;
    } else {
      ref.read(coachSubViewProvider.notifier).state = CoachSubView.chat;
    }
  } else if (tab == AppTab.profile) {
    if (subView == 'peers') {
      ref.read(profileSubViewProvider.notifier).state = ProfileSubView.peers;
    } else if (subView == 'governance' ||
        subView == 'architecture' ||
        subView == 'ethics') {
      ref.read(profileSubViewProvider.notifier).state =
          ProfileSubView.governance;
      if (subView == 'architecture') {
        ref.read(governanceSectionProvider.notifier).state =
            GovernanceSection.architecture;
      } else {
        ref.read(governanceSectionProvider.notifier).state =
            GovernanceSection.ethics;
      }
    } else {
      ref.read(profileSubViewProvider.notifier).state = ProfileSubView.account;
    }
  }
}

void jumpToSourceFile(WidgetRef ref, String path) {
  ref.read(explorerSelectedFileProvider.notifier).state = path;
  ref.read(governanceSectionProvider.notifier).state =
      GovernanceSection.explorer;
  ref.read(profileSubViewProvider.notifier).state = ProfileSubView.governance;
  ref.read(appTabProvider.notifier).state = AppTab.profile;
}

void dismissOnboardingBanner(WidgetRef ref) {
  ref.read(onboardingBannerDismissedProvider.notifier).state = true;
  StorageService.instance.setOnboardingCompleted(true);
}

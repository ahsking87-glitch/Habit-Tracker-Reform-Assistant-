enum AppTab {
  salah,
  shield,
  quran,
  planner,
  coach,
  profile,
}

enum SalahSubView {
  prayer,
  streaks,
}

enum CoachSubView {
  chat,
  gateway,
  companion,
}

enum ProfileSubView {
  account,
  peers,
  governance,
}

enum GovernanceSection {
  ethics,
  architecture,
  explorer,
}

enum PlannerSubView {
  goals,
  timeline,
}

enum GoalCategory {
  learning,
  spiritual,
  task,
  wellness,
}

enum GoalCadence {
  daily,
  weekdays,
  customDays,
  oneTime,
}

enum CalculationMethod {
  mwl,
  isna,
  egypt,
  makkah,
  karachi,
  tehran,
  jafari,
}

enum AsrMethod {
  shafi,
  hanafi,
}

enum CompanionSkin {
  lantern,
  crescent,
  astrolabe,
  lotus,
}

enum CompanionMood {
  resting,
  happy,
  alert,
  salahLead,
  screenLimit,
  hiding,
}

enum SoundEffectType {
  salahBell,
  attentionChime,
  celebrationHarp,
  peekGlissando,
  waterDrop,
  restingHum,
  marimbaTick,
}

enum AIProviderId {
  gemini,
  openai,
  anthropic,
  deepseek,
  offline,
}

class CityLocation {
  final String name;
  final String country;
  final double lat;
  final double lng;
  final double timezoneOffset;

  const CityLocation({
    required this.name,
    required this.country,
    required this.lat,
    required this.lng,
    required this.timezoneOffset,
  });
}

class PrayerTimeEntry {
  final String name;
  final String arabicName;
  final String time24;
  final String time12;
  final DateTime dateObj;
  final bool isNext;

  const PrayerTimeEntry({
    required this.name,
    required this.arabicName,
    required this.time24,
    required this.time12,
    required this.dateObj,
    required this.isNext,
  });
}

class PrayerCalculationOutput {
  final List<PrayerTimeEntry> prayers;
  final PrayerTimeEntry nextPrayer;
  final String countdownString;
  final double qiblaBearing;

  const PrayerCalculationOutput({
    required this.prayers,
    required this.nextPrayer,
    required this.countdownString,
    required this.qiblaBearing,
  });
}

class MicroSunnah {
  final String id;
  final String title;
  final String? titleBengali;
  final String arabicTitle;
  final String category; // morning | hygiene | social | prayer | night
  final int durationMinutes;
  final String hadithReference;
  final String? hadithReferenceBengali;
  final bool completed;
  final String benefit;
  final String? benefitBengali;
  final String? contextualGuidanceEnglish;
  final String? contextualGuidanceBengali;
  final int streakDays;
  final int longestStreak;
  final String? lastCompletedDate;

  const MicroSunnah({
    required this.id,
    required this.title,
    this.titleBengali,
    required this.arabicTitle,
    required this.category,
    required this.durationMinutes,
    required this.hadithReference,
    this.hadithReferenceBengali,
    required this.completed,
    required this.benefit,
    this.benefitBengali,
    this.contextualGuidanceEnglish,
    this.contextualGuidanceBengali,
    required this.streakDays,
    required this.longestStreak,
    this.lastCompletedDate,
  });

  MicroSunnah copyWith({
    bool? completed,
    int? streakDays,
    int? longestStreak,
    String? lastCompletedDate,
  }) {
    return MicroSunnah(
      id: id,
      title: title,
      titleBengali: titleBengali,
      arabicTitle: arabicTitle,
      category: category,
      durationMinutes: durationMinutes,
      hadithReference: hadithReference,
      hadithReferenceBengali: hadithReferenceBengali,
      completed: completed ?? this.completed,
      benefit: benefit,
      benefitBengali: benefitBengali,
      contextualGuidanceEnglish: contextualGuidanceEnglish,
      contextualGuidanceBengali: contextualGuidanceBengali,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }
}

class MilestoneBadge {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String icon; // Moon | Sparkles | Sun | Shield | Flame | Crown
  final String tier; // bronze | silver | gold | emerald
  final int requiredDays;
  final bool unlocked;
  final String? unlockedAt;
  final String virtueQuote;
  final String hadithReference;

  const MilestoneBadge({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.icon,
    required this.tier,
    required this.requiredDays,
    required this.unlocked,
    this.unlockedAt,
    required this.virtueQuote,
    required this.hadithReference,
  });

  MilestoneBadge copyWith({
    bool? unlocked,
    String? unlockedAt,
  }) {
    return MilestoneBadge(
      id: id,
      name: name,
      arabicName: arabicName,
      description: description,
      icon: icon,
      tier: tier,
      requiredDays: requiredDays,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      virtueQuote: virtueQuote,
      hadithReference: hadithReference,
    );
  }
}

class CircadianBlock {
  final String id;
  final String title;
  final String category; // sleep | spiritual | deep_work | light_work | family | halal_leisure
  final double startHour;
  final double endHour;
  final int colorHex;
  final String sunnahAnchor;
  final String description;

  const CircadianBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.startHour,
    required this.endHour,
    required this.colorHex,
    required this.sunnahAnchor,
    required this.description,
  });
}

class PeerAccountabilityNode {
  final String id;
  final String alias;
  final String avatarSeed;
  final int streakDays;
  final String lastSyncTimestamp;
  final String cryptographicSignature;
  final String status; // synced | active | resting
  final bool encouragementSent;

  const PeerAccountabilityNode({
    required this.id,
    required this.alias,
    required this.avatarSeed,
    required this.streakDays,
    required this.lastSyncTimestamp,
    required this.cryptographicSignature,
    required this.status,
    required this.encouragementSent,
  });

  PeerAccountabilityNode copyWith({
    bool? encouragementSent,
  }) {
    return PeerAccountabilityNode(
      id: id,
      alias: alias,
      avatarSeed: avatarSeed,
      streakDays: streakDays,
      lastSyncTimestamp: lastSyncTimestamp,
      cryptographicSignature: cryptographicSignature,
      status: status,
      encouragementSent: encouragementSent ?? this.encouragementSent,
    );
  }
}

class ScripturalAnchor {
  final String type; // quran | hadith
  final String textArabic;
  final String translation;
  final String reference;

  const ScripturalAnchor({
    required this.type,
    required this.textArabic,
    required this.translation,
    required this.reference,
  });

  factory ScripturalAnchor.fromJson(Map<String, dynamic> json) {
    return ScripturalAnchor(
      type: (json['type'] as String?) == 'hadith' ? 'hadith' : 'quran',
      textArabic: json['textArabic'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }
}

class AgentMessage {
  final String id;
  final String sender; // user | agent
  final String text;
  final DateTime timestamp;
  final ScripturalAnchor? scripturalAnchor;
  final String? lifeDomain;
  final List<String> suggestedActions;
  final String? source;

  const AgentMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.scripturalAnchor,
    this.lifeDomain,
    this.suggestedActions = const [],
    this.source,
  });
}

class OfflineAlternative {
  final String title;
  final String duration;
  final String action;
  final String category;

  const OfflineAlternative({
    required this.title,
    required this.duration,
    required this.action,
    required this.category,
  });

  factory OfflineAlternative.fromJson(Map<String, dynamic> json) {
    return OfflineAlternative(
      title: json['title'] as String? ?? 'Mindful Pause',
      duration: json['duration'] as String? ?? '2 mins',
      action: json['action'] as String? ?? '',
      category: json['category'] as String? ?? 'spiritual',
    );
  }
}

class ReflectionResponse {
  final String source;
  final String empathy;
  final String inquiry;
  final List<OfflineAlternative> offlineAlternatives;
  final String affirmation;

  const ReflectionResponse({
    required this.source,
    required this.empathy,
    required this.inquiry,
    required this.offlineAlternatives,
    required this.affirmation,
  });

  factory ReflectionResponse.fromJson(Map<String, dynamic> json) {
    final altsRaw = json['offlineAlternatives'] as List<dynamic>? ?? [];
    return ReflectionResponse(
      source: json['source'] as String? ?? 'offline-fallback',
      empathy: json['empathy'] as String? ?? '',
      inquiry: json['inquiry'] as String? ?? '',
      offlineAlternatives: altsRaw
          .whereType<Map<String, dynamic>>()
          .map(OfflineAlternative.fromJson)
          .toList(),
      affirmation: json['affirmation'] as String? ?? '',
    );
  }
}

class SurahMeta {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameBengali;
  final int totalVerses;
  final String revelationType;

  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameBengali,
    required this.totalVerses,
    required this.revelationType,
  });
}

class QuranVerse {
  final String id;
  final int surahNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final String surahNameBengali;
  final int verseNumber;
  final String textArabic;
  final String transliteration;
  final String transliterationBengali;
  final String translationEnglish;
  final String translationBengali;
  final int juzNumber;

  const QuranVerse({
    required this.id,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.surahNameBengali,
    required this.verseNumber,
    required this.textArabic,
    required this.transliteration,
    required this.transliterationBengali,
    required this.translationEnglish,
    required this.translationBengali,
    required this.juzNumber,
  });
}

class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final bool isAnonymous;
  final String avatarId;
  final String spiritualGoal;
  final String madhab;
  final String preferredLanguage; // en | bn | ar
  final String createdAt;
  final String lastSyncedAt;
  final bool biometricLockEnabled;
  final String authMethod; // local_offline | biometric | anonymous_guest

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isAnonymous,
    required this.avatarId,
    required this.spiritualGoal,
    required this.madhab,
    required this.preferredLanguage,
    required this.createdAt,
    required this.lastSyncedAt,
    required this.biometricLockEnabled,
    required this.authMethod,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isAnonymous,
    String? avatarId,
    String? spiritualGoal,
    String? madhab,
    String? preferredLanguage,
    String? createdAt,
    String? lastSyncedAt,
    bool? biometricLockEnabled,
    String? authMethod,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      avatarId: avatarId ?? this.avatarId,
      spiritualGoal: spiritualGoal ?? this.spiritualGoal,
      madhab: madhab ?? this.madhab,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      biometricLockEnabled: biometricLockEnabled ?? this.biometricLockEnabled,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}

class CompanionState {
  final bool isEnabled;
  final CompanionSkin skin;
  final CompanionMood mood;
  final double posX; // 0..1 normalized within bounded frame
  final double posY; // 0..1 normalized within bounded frame
  final double sizePx;
  final bool soundEnabled;
  final double soundVolume;
  final bool autoWanderEnabled;
  final bool salahLeadAlertEnabled;
  final bool screenLimitAlertEnabled;
  final bool isHiding;
  final String lastSoundLabel;

  const CompanionState({
    this.isEnabled = true,
    this.skin = CompanionSkin.lantern,
    this.mood = CompanionMood.resting,
    this.posX = 0.84,
    this.posY = 0.72,
    this.sizePx = 56,
    this.soundEnabled = true,
    this.soundVolume = 0.7,
    this.autoWanderEnabled = true,
    this.salahLeadAlertEnabled = true,
    this.screenLimitAlertEnabled = true,
    this.isHiding = false,
    this.lastSoundLabel = 'Harmonic Resting Hum',
  });

  CompanionState copyWith({
    bool? isEnabled,
    CompanionSkin? skin,
    CompanionMood? mood,
    double? posX,
    double? posY,
    double? sizePx,
    bool? soundEnabled,
    double? soundVolume,
    bool? autoWanderEnabled,
    bool? salahLeadAlertEnabled,
    bool? screenLimitAlertEnabled,
    bool? isHiding,
    String? lastSoundLabel,
  }) {
    return CompanionState(
      isEnabled: isEnabled ?? this.isEnabled,
      skin: skin ?? this.skin,
      mood: mood ?? this.mood,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      sizePx: sizePx ?? this.sizePx,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      autoWanderEnabled: autoWanderEnabled ?? this.autoWanderEnabled,
      salahLeadAlertEnabled: salahLeadAlertEnabled ?? this.salahLeadAlertEnabled,
      screenLimitAlertEnabled:
          screenLimitAlertEnabled ?? this.screenLimitAlertEnabled,
      isHiding: isHiding ?? this.isHiding,
      lastSoundLabel: lastSoundLabel ?? this.lastSoundLabel,
    );
  }
}

class AIProviderMeta {
  final AIProviderId id;
  final String name;
  final String providerCompany;
  final String defaultModel;
  final List<String> availableModels;
  final String endpointUrl;
  final String description;
  final String icon;
  final bool requiresKey;
  final String keyPlaceholder;
  final bool supportsStreaming;
  final bool supportsJsonMode;

  const AIProviderMeta({
    required this.id,
    required this.name,
    required this.providerCompany,
    required this.defaultModel,
    required this.availableModels,
    required this.endpointUrl,
    required this.description,
    required this.icon,
    required this.requiresKey,
    required this.keyPlaceholder,
    required this.supportsStreaming,
    required this.supportsJsonMode,
  });
}

class AIGatewayConfig {
  final AIProviderId activeProvider;
  final Map<AIProviderId, String> models;
  final Map<AIProviderId, String> apiKeys;
  final double temperature;
  final int maxTokens;
  final bool fallbackToOffline;
  final int totalGatewayRequests;

  const AIGatewayConfig({
    this.activeProvider = AIProviderId.gemini,
    this.models = const {
      AIProviderId.gemini: 'gemini-3.8-flash',
      AIProviderId.openai: 'gpt-4o',
      AIProviderId.anthropic: 'claude-3-5-sonnet-20241022',
      AIProviderId.deepseek: 'deepseek-chat',
      AIProviderId.offline: 'embedded-canonical-db',
    },
    this.apiKeys = const {},
    this.temperature = 0.4,
    this.maxTokens = 1024,
    this.fallbackToOffline = true,
    this.totalGatewayRequests = 0,
  });

  String get activeModel => models[activeProvider] ?? 'gemini-3.8-flash';

  String? get activeKey => apiKeys[activeProvider];

  AIGatewayConfig copyWith({
    AIProviderId? activeProvider,
    Map<AIProviderId, String>? models,
    Map<AIProviderId, String>? apiKeys,
    double? temperature,
    int? maxTokens,
    bool? fallbackToOffline,
    int? totalGatewayRequests,
  }) {
    return AIGatewayConfig(
      activeProvider: activeProvider ?? this.activeProvider,
      models: models ?? this.models,
      apiKeys: apiKeys ?? this.apiKeys,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      fallbackToOffline: fallbackToOffline ?? this.fallbackToOffline,
      totalGatewayRequests: totalGatewayRequests ?? this.totalGatewayRequests,
    );
  }
}

class GatewayChatResponse {
  final String provider;
  final String model;
  final int latencyMs;
  final String source;
  final String reply;
  final ScripturalAnchor? scripturalAnchor;
  final Map<String, int>? tokensUsed;
  final List<String> suggestedActions;

  const GatewayChatResponse({
    required this.provider,
    required this.model,
    required this.latencyMs,
    required this.source,
    required this.reply,
    this.scripturalAnchor,
    this.tokensUsed,
    this.suggestedActions = const [],
  });
}

class OnboardingStep {
  final String id;
  final int stepNumber;
  final String title;
  final String subtitle;
  final AppTab targetView;
  final String? targetSubView;
  final String targetFeature;
  final String explanation;
  final String actionLabel;
  final bool completed;

  const OnboardingStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.targetView,
    this.targetSubView,
    required this.targetFeature,
    required this.explanation,
    required this.actionLabel,
    this.completed = false,
  });
}

class AppHelpTopic {
  final String id;
  final String question;
  final String shortAnswer;
  final String detailedGuide;
  final String category;
  final String actionLabel;
  final AppTab targetTab;
  final String? targetSubView;

  const AppHelpTopic({
    required this.id,
    required this.question,
    required this.shortAnswer,
    required this.detailedGuide,
    required this.category,
    required this.actionLabel,
    required this.targetTab,
    this.targetSubView,
  });
}

class OnboardingAskResponse {
  final String source;
  final String answer;
  final AppTab targetFeature;
  final String? targetSubView;
  final String actionTip;
  final List<String> suggestedFollowUps;

  const OnboardingAskResponse({
    required this.source,
    required this.answer,
    required this.targetFeature,
    this.targetSubView,
    required this.actionTip,
    required this.suggestedFollowUps,
  });
}

class CodeFileItem {
  final String path;
  final String name;
  final String language;
  final String category; // flutter_core | android_native | ios_native | architecture_docs
  final String description;
  final List<String> tags;
  final String content;

  const CodeFileItem({
    required this.path,
    required this.name,
    required this.language,
    required this.category,
    required this.description,
    required this.tags,
    required this.content,
  });
}

class PersonalGoal {
  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final int targetUnits;
  final int completedUnits;
  final String unitLabel;
  final GoalCadence cadence;
  final String scheduledSlot;
  final String scheduledTime; // HH:mm
  final List<int> scheduledDays; // 1=Mon .. 7=Sun
  final String? targetDate; // YYYY-MM-DD
  final bool reminderEnabled;
  final bool isPaused;
  final List<String> completedLogs; // YYYY-MM-DD dates when logged
  final String createdAt;
  final String updatedAt;

  const PersonalGoal({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.targetUnits,
    this.completedUnits = 0,
    this.unitLabel = 'sessions',
    required this.cadence,
    required this.scheduledSlot,
    this.scheduledTime = '08:30',
    this.scheduledDays = const [1, 2, 3, 4, 5, 6, 7],
    this.targetDate,
    this.reminderEnabled = true,
    this.isPaused = false,
    this.completedLogs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressRatio =>
      targetUnits <= 0 ? 0.0 : (completedUnits / targetUnits).clamp(0.0, 1.0);

  int get progressPercent => (progressRatio * 100).round();

  bool get isCompleted => targetUnits > 0 && completedUnits >= targetUnits;

  bool get isScheduledToday {
    if (isPaused) return false;
    final weekday = DateTime.now().weekday;
    switch (cadence) {
      case GoalCadence.daily:
        return true;
      case GoalCadence.weekdays:
        return weekday >= 1 && weekday <= 5;
      case GoalCadence.customDays:
        return scheduledDays.contains(weekday);
      case GoalCadence.oneTime:
        return !isCompleted;
    }
  }

  bool get loggedToday {
    final today = DateTime.now().toIso8601String().split('T').first;
    return completedLogs.contains(today);
  }

  int get weeklyCheckIns {
    final cutoff = DateTime.now().subtract(const Duration(days: 6));
    final cutoffDate = DateTime(cutoff.year, cutoff.month, cutoff.day);
    int count = 0;
    for (final d in completedLogs) {
      final parsed = DateTime.tryParse(d);
      if (parsed != null && !parsed.isBefore(cutoffDate)) {
        count++;
      }
    }
    return count;
  }

  PersonalGoal copyWith({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    int? targetUnits,
    int? completedUnits,
    String? unitLabel,
    GoalCadence? cadence,
    String? scheduledSlot,
    String? scheduledTime,
    List<int>? scheduledDays,
    String? targetDate,
    bool clearTargetDate = false,
    bool? reminderEnabled,
    bool? isPaused,
    List<String>? completedLogs,
    String? createdAt,
    String? updatedAt,
  }) {
    return PersonalGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetUnits: targetUnits ?? this.targetUnits,
      completedUnits: completedUnits ?? this.completedUnits,
      unitLabel: unitLabel ?? this.unitLabel,
      cadence: cadence ?? this.cadence,
      scheduledSlot: scheduledSlot ?? this.scheduledSlot,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      isPaused: isPaused ?? this.isPaused,
      completedLogs: completedLogs ?? this.completedLogs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'targetUnits': targetUnits,
      'completedUnits': completedUnits,
      'unitLabel': unitLabel,
      'cadence': cadence.name,
      'scheduledSlot': scheduledSlot,
      'scheduledTime': scheduledTime,
      'scheduledDays': scheduledDays,
      'targetDate': targetDate,
      'reminderEnabled': reminderEnabled,
      'isPaused': isPaused,
      'completedLogs': completedLogs,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PersonalGoal.fromJson(Map<String, dynamic> json) {
    final catStr = json['category'] as String? ?? 'learning';
    final cadStr = json['cadence'] as String? ?? 'daily';
    final target = (json['targetUnits'] as num?)?.toInt() ?? 1;
    final completed = (json['completedUnits'] as num?)?.toInt() ?? 0;

    return PersonalGoal(
      id: json['id'] as String? ?? 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Goal',
      description: json['description'] as String? ?? '',
      category: GoalCategory.values.firstWhere(
        (e) => e.name == catStr,
        orElse: () => GoalCategory.learning,
      ),
      targetUnits: target < 1 ? 1 : target,
      completedUnits: completed.clamp(0, target < 1 ? 1 : target),
      unitLabel: json['unitLabel'] as String? ?? 'sessions',
      cadence: GoalCadence.values.firstWhere(
        (e) => e.name == cadStr,
        orElse: () => GoalCadence.daily,
      ),
      scheduledSlot: json['scheduledSlot'] as String? ?? 'Morning Sprint',
      scheduledTime: json['scheduledTime'] as String? ?? '08:30',
      scheduledDays: (json['scheduledDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      targetDate: json['targetDate'] as String?,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      isPaused: json['isPaused'] as bool? ?? false,
      completedLogs: (json['completedLogs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}

class GoalReminderAlert {
  final String id;
  final String goalId;
  final String goalTitle;
  final String scheduledTime;
  final String scheduledSlot;
  final String progressText;
  final DateTime triggeredAt;
  final bool isTest;

  const GoalReminderAlert({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.scheduledTime,
    required this.scheduledSlot,
    required this.progressText,
    required this.triggeredAt,
    this.isTest = false,
  });
}

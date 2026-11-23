export type CalculationMethod =
  | 'MWL' // Muslim World League (18°, 17°)
  | 'ISNA' // Islamic Society of North America (15°, 15°)
  | 'EGYPT' // Egyptian General Authority (19.5°, 17.5°)
  | 'MAKKAH' // Umm al-Qura University, Makkah (18.5°, 90 min)
  | 'KARACHI' // University of Islamic Sciences, Karachi (18°, 18°)
  | 'TEHRAN' // Institute of Geophysics, Tehran (17.7°, 14°)
  | 'JAFARI'; // Leva Institute, Qum (16°, 14°)

export type Madhab = 'SHAFI' | 'HANAFI';

export interface Coordinates {
  latitude: number;
  longitude: number;
  city: string;
  country: string;
}

export interface PrayerTimesResult {
  fajr: Date;
  sunrise: Date;
  dhuhr: Date;
  asr: Date;
  maghrib: Date;
  isha: Date;
  nextPrayer: {
    name: string;
    arabicName: string;
    time: Date;
    remainingMs: number;
  };
  currentPrayer: {
    name: string;
    arabicName: string;
  };
  qiblaDegrees: number;
}

export type AvatarPreset = 'crescent' | 'dome' | 'minaret' | 'kaaba' | 'star' | 'palm';

export interface UserProfile {
  id: string;
  email?: string;
  displayName: string;
  avatarPreset: AvatarPreset;
  isAnonymous: boolean;
  createdAt: string;
  spiritualGoal: string;
  preferredMadhab: Madhab;
  calculationMethod: CalculationMethod;
  biometricEnabled: boolean;
  storedPasswordHash?: string; // PBKDF2-HMAC-SHA256
  storedSalt?: string;
}

export interface AuthState {
  user: UserProfile | null;
  isAuthenticated: boolean;
  status: 'idle' | 'loading' | 'authenticated' | 'unauthenticated';
}

export type QuranLanguageMode = 'en' | 'bn' | 'both';

export interface QuranVerse {
  id: string;
  surahNumber: number;
  surahNameArabic: string;
  surahNameEnglish: string;
  surahNameBengali: string;
  verseNumber: number;
  textArabic: string;
  transliteration: string;
  transliterationBengali?: string;
  translationEnglish: string;
  translationBengali: string;
  juzNumber: number;
}

export interface SurahMeta {
  number: number;
  nameArabic: string;
  nameEnglish: string;
  nameBengali: string;
  totalVerses: number;
  revelationType: 'Meccan' | 'Medinan';
}

export interface MicroSunnah {
  id: string;
  title: string;
  titleBengali?: string;
  arabicTitle: string;
  category: 'morning' | 'prayer' | 'social' | 'night' | 'hygiene';
  durationMinutes: number;
  hadithReference: string;
  hadithReferenceBengali?: string;
  completed: boolean;
  benefit: string;
  benefitBengali?: string;
  contextualGuidanceEnglish?: string;
  contextualGuidanceBengali?: string;
  streakDays: number;
  longestStreak: number;
  lastCompletedDate?: string;
  graceUsed?: boolean;
}

export type BadgeTier = 'bronze' | 'silver' | 'gold' | 'emerald';

export interface MilestoneBadge {
  id: string;
  name: string;
  arabicName: string;
  description: string;
  icon: string;
  tier: BadgeTier;
  requiredDays: number;
  habitCategory?: string;
  unlocked: boolean;
  unlockedAt?: string;
  virtueQuote: string;
  hadithReference: string;
}

export interface HabitStreakStats {
  totalActiveStreaks: number;
  longestOverallStreak: number;
  totalCompletionsAllTime: number;
  unlockedBadgesCount: number;
  totalBadgesCount: number;
  graceDaysAvailable: number;
}

export interface QuranProgress {
  surahNumber: number;
  surahNameArabic: string;
  surahNameEnglish: string;
  currentAyah: number;
  totalAyahs: number;
  juzNumber: number;
  dailyGoalAyahs: number;
  completedAyahsToday: number;
  lastUpdated: string;
}

export interface CircadianBlock {
  id: string;
  title: string;
  category: 'sleep' | 'spiritual' | 'deep_work' | 'light_work' | 'halal_leisure' | 'family';
  startHour: number; // 0 - 24
  endHour: number;
  color: string;
  sunnahAnchor: string;
  description: string;
  isCurrent?: boolean;
}

export interface ShieldTriggerEvent {
  targetApp: 'YouTube Shorts' | 'Instagram Reels' | 'TikTok' | 'General Screen Limit' | 'Salah Approaching';
  leadTimeMinutes?: number;
  timeSpentMinutes: number;
  thresholdMinutes: number;
  active: boolean;
}

export interface OfflineAlternative {
  title: string;
  duration: string;
  action: string;
  category: 'spiritual' | 'somatic' | 'nature' | 'kinesthetic';
}

export interface ScripturalAnchor {
  type: 'quran' | 'hadith';
  textArabic: string;
  translation: string;
  reference: string;
}

export type LifeAlignmentDomain =
  | 'spiritual'
  | 'professional'
  | 'creative'
  | 'burnout_prevention'
  | 'digital_wellbeing';

export interface AgentMessage {
  id: string;
  sender: 'user' | 'agent';
  text: string;
  timestamp: string;
  scripturalAnchor?: ScripturalAnchor;
  lifeDomain?: LifeAlignmentDomain;
  suggestedActions?: string[];
  source?: 'gemini-3.8-flash' | 'offline-deterministic' | 'offline-fallback';
}

export interface CoachingReflection {
  source: 'gemini-3.8-flash' | 'offline-deterministic' | 'offline-fallback';
  empathy: string;
  inquiry: string;
  offlineAlternatives: OfflineAlternative[];
  affirmation: string;
}

export interface PeerAccountabilityNode {
  id: string;
  alias: string;
  avatarSeed: string;
  streakDays: number;
  lastSyncTimestamp: string;
  cryptographicSignature: string; // Ed25519 signature proof of habit
  status: 'active' | 'synced' | 'support_needed';
  encouragementSent: boolean;
}

export interface CodeFile {
  path: string;
  name: string;
  language: 'dart' | 'kotlin' | 'swift' | 'yaml' | 'xml' | 'markdown';
  category: 'flutter_core' | 'android_native' | 'ios_native' | 'config' | 'architecture_docs';
  description: string;
  content: string;
  tags: string[];
}

export type CompanionSkin =
  | 'luminous_orb'
  | 'hilal_sprite'
  | 'origami_dove'
  | 'geometric_star';

export type CompanionMood =
  | 'joyful'
  | 'mindful'
  | 'vigilant'
  | 'serene'
  | 'sleeping'
  | 'hiding';

export interface FloatingCompanionConfig {
  enabled: boolean;
  skin: CompanionSkin;
  name: string;
  soundEnabled: boolean;
  soundVolume: number;
  wanderSpeed: 'calm' | 'lively' | 'stationary';
  salahLeadMinutes: number;
  screenTimeThresholdMinutes: number;
  allowHidingBehindApps: boolean;
  edgeRestingSnap: boolean;
}

export interface FloatingCompanionState {
  x: number; // percentage or px
  y: number;
  mood: CompanionMood;
  isDragging: boolean;
  isRestingOnEdge: boolean;
  isHiding: boolean;
  lastChimeTimestamp?: string;
  activeTrigger?: 'salah_approaching' | 'screen_limit' | 'habit_milestone' | 'idle_wander';
  proactiveMessage?: string;
}

export type AIProviderId = 'gemini' | 'openai' | 'anthropic' | 'deepseek' | 'offline';

export interface AIProviderConfig {
  id: AIProviderId;
  name: string;
  providerCompany: string;
  defaultModel: string;
  endpointUrl: string;
  isConfigured: boolean;
  description: string;
  icon: string;
  maxTokens: number;
  temperature: number;
  supportsStreaming: boolean;
  supportsJsonMode: boolean;
}

export interface MultiAIGatewayState {
  activeProvider: AIProviderId;
  fallbackToOffline: boolean;
  providers: Record<AIProviderId, AIProviderConfig>;
}

export interface OnboardingStep {
  id: string;
  stepNumber: number;
  title: string;
  subtitle: string;
  targetView: string;
  targetFeature: string;
  explanation: string;
  actionLabel: string;
  completed: boolean;
  highlightCoordinates?: { x: number; y: number };
}

export interface AppHelpTopic {
  id: string;
  question: string;
  shortAnswer: string;
  detailedGuide: string;
  category: 'habits' | 'shield' | 'salah' | 'ai_gateway' | 'offline_security';
  suggestedAction?: {
    label: string;
    targetTab: string;
  };
}



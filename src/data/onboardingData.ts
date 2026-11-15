import { OnboardingStep, AppHelpTopic, AIProviderConfig, AIProviderId } from '../types';

export const DEFAULT_ONBOARDING_STEPS: OnboardingStep[] = [
  {
    id: 'step-salah',
    stepNumber: 1,
    title: 'Offline Astronomical Salah Engine',
    subtitle: 'GPS-calculated solar coordinates without internet dependency',
    targetView: 'simulator',
    targetFeature: 'prayer_engine',
    explanation:
      'Mīzān calculates accurate prayer times completely offline using astronomical equations and your device coordinates. You can customize calculation methods (MWL, ISNA, Umm al-Qura) and Asr Madhab (Shafi/Hanafi).',
    actionLabel: 'Explore Salah & Qibla',
    completed: true,
  },
  {
    id: 'step-shield',
    stepNumber: 2,
    title: 'OS Short-Form Video Shield',
    subtitle: 'Interrupting endless Reels & Shorts feeds ethically',
    targetView: 'simulator',
    targetFeature: 'accessibility_shield',
    explanation:
      'Using an Android AccessibilityService or iOS Screen Time API, Mīzān detects when you open Reels/Shorts and presents a calm 7-second physiological breathing pause with 2-minute offline alternatives. Never coercive—you retain full autonomy to proceed.',
    actionLabel: 'Test Video Shield',
    completed: false,
  },
  {
    id: 'step-sunnahs',
    stepNumber: 3,
    title: 'Logging Micro-Sunnahs & Streaks',
    subtitle: 'High-impact prophetic habits with Istighfar Grace Days',
    targetView: 'streaks',
    targetFeature: 'micro_sunnahs',
    explanation:
      'Tap any Sunnah (e.g. Siwak, Ayat al-Kursi, Prophetic Smile) to log it instantly. Build streaks to unlock authentic Hadith milestone badges. If you miss a day, use an Istighfar Grace Day to preserve your streak with sincere renewal.',
    actionLabel: 'View Habit Streaks',
    completed: false,
  },
  {
    id: 'step-companion',
    stepNumber: 4,
    title: 'Interactive Floating Companion (Nūr)',
    subtitle: 'System-level virtual pet with non-verbal audio chimes',
    targetView: 'companion',
    targetFeature: 'floating_companion',
    explanation:
      'A floating overlay companion wanders across your screen and rests on borders. It communicates strictly through expressive 432Hz chimes and water-droplet micro-sounds, alerting you 10 minutes before Salah without intrusive speech.',
    actionLabel: 'Meet Companion',
    completed: false,
  },
  {
    id: 'step-quran',
    stepNumber: 5,
    title: 'Trilingual Quran & Sunnah Library',
    subtitle: 'Arabic Uthmani, English & Bengali translations offline',
    targetView: 'quran',
    targetFeature: 'multilingual_quran',
    explanation:
      'Read and search the Holy Quran offline with sub-10ms full-text SQLite FTS5 search in Bengali (বায়ান ফাউন্ডেশন), English (Sahih International), and Arabic Uthmani text with phonetic transliteration.',
    actionLabel: 'Open Quran Reader',
    completed: false,
  },
  {
    id: 'step-gateway',
    stepNumber: 6,
    title: 'Multi-AI Gateway (BYOK)',
    subtitle: 'Route coaching through Gemini, OpenAI, Claude, or DeepSeek',
    targetView: 'gateway',
    targetFeature: 'multi_ai_gateway',
    explanation:
      'Connect your preferred AI provider using your own free or paid API key. Keys are encrypted solely in hardware Keystore/Keychain, never shared. Core habit tracking remains 100% functional offline.',
    actionLabel: 'Configure Gateway',
    completed: false,
  },
];

export const APP_HELP_TOPICS: AppHelpTopic[] = [
  {
    id: 'how-to-log-habit',
    question: 'How do I log a daily habit or Sunnah?',
    shortAnswer: 'Navigate to the Salah or Streaks tab and tap the circle next to any Micro-Sunnah.',
    detailedGuide:
      'In the interactive simulator or mobile app, go to the Daily Micro-Sunnahs card on the Salah tab, or open the Habit Streaks tab. Simply tap the circle icon next to any habit (like Siwak, Ayat al-Kursi, or Prophetic Smile). The completion is recorded instantly to local Hive binary storage with celebratory confetti.',
    category: 'habits',
    suggestedAction: {
      label: 'Go to Habits & Streaks',
      targetTab: 'streaks',
    },
  },
  {
    id: 'what-are-grace-days',
    question: 'What are Istighfar Grace Days and how do they work?',
    shortAnswer: 'They allow you to repair a missed habit streak by renewing intention with Istighfar.',
    detailedGuide:
      'Unlike conventional gamified apps that use toxic streak-shaming or paywalls to keep streaks alive, Mīzān grants you 3 Istighfar Grace Days per month. If illness, travel, or fatigue caused you to miss a habit, tap "Repair with Istighfar" to recite Astaghfirullah, renew your intention, and maintain your streak without penalty.',
    category: 'habits',
    suggestedAction: {
      label: 'Inspect Streaks & Rewards',
      targetTab: 'streaks',
    },
  },
  {
    id: 'how-shorts-shield-works',
    question: 'How does the Short-Form Video Blocker work on Android?',
    shortAnswer: 'It monitors window state changes via an AccessibilityService with prominent disclosure.',
    detailedGuide:
      'On Android, Mīzān uses an AccessibilityService that listens for window content changes matching known Reels or Shorts view resource IDs in YouTube and Instagram. When detected, a WindowManager overlay shield opens with a 7-second physiological breathing pacer and immediate 2-minute offline alternatives (like cool wudu or reciting dhikr). You always retain the autonomy to dismiss.',
    category: 'shield',
    suggestedAction: {
      label: 'Test Simulated Shield',
      targetTab: 'simulator',
    },
  },
  {
    id: 'is-app-completely-offline',
    question: 'Can I use Mīzān completely offline with zero internet?',
    shortAnswer: 'Yes! 100% of habit tracking, Salah calculations, and Quran reading operate offline.',
    detailedGuide:
      'Mīzān is architected offline-first. All prayer times are calculated mathematically from solar coordinates using the Adhan library. The complete Holy Quran in Arabic, English, and Bengali resides in a bundled SQLite database with FTS5 search. Habit data is saved in binary Hive boxes. AI coaching uses a deterministic offline Hadith matrix unless you optionally connect an API key.',
    category: 'offline_security',
    suggestedAction: {
      label: 'View System Architecture',
      targetTab: 'architecture',
    },
  },
  {
    id: 'multi-ai-providers',
    question: 'Which AI providers are supported in the Multi-AI Gateway?',
    shortAnswer: 'Google Gemini, OpenAI ChatGPT, Anthropic Claude, and DeepSeek.',
    detailedGuide:
      'Mīzān includes a flexible BYOK (Bring Your Own Key) gateway supporting Google Gemini (gemini-3.8-flash), OpenAI (gpt-4o / gpt-4o-mini), Anthropic Claude (claude-3-5-sonnet), and DeepSeek (deepseek-chat / deepseek-reasoner). You can toggle between them or let Mīzān fall back to the offline Hadith matrix when disconnected.',
    category: 'ai_gateway',
    suggestedAction: {
      label: 'Open Multi-AI Gateway',
      targetTab: 'gateway',
    },
  },
  {
    id: 'companion-sounds',
    question: 'Why doesn’t the AI Companion speak out loud?',
    shortAnswer: 'To protect your digital tranquility and avoid voice fatigue.',
    detailedGuide:
      'The companion ("Nūr") adheres to a strict non-verbal acoustic design. Instead of intrusive speech synthesis, it uses peaceful 432Hz harmonic singing-bowl chimes, water-drop chirps, and pentatonic harp flourishes. This creates an ambient, meditative reminder without breaking your concentration.',
    category: 'salah',
    suggestedAction: {
      label: 'Test Soundboard',
      targetTab: 'companion',
    },
  },
];

export const DEFAULT_PROVIDERS_CONFIG: Record<AIProviderId, AIProviderConfig> = {
  gemini: {
    id: 'gemini',
    name: 'Google Gemini',
    providerCompany: 'Google DeepMind',
    defaultModel: 'gemini-3.8-flash',
    endpointUrl: 'https://generativelanguage.googleapis.com/v1beta/models',
    isConfigured: true,
    description: 'Fast, highly capable multimodal model with strong multilingual fluency in Arabic and Bengali.',
    icon: '✨',
    maxTokens: 1024,
    temperature: 0.4,
    supportsStreaming: true,
    supportsJsonMode: true,
  },
  openai: {
    id: 'openai',
    name: 'OpenAI ChatGPT',
    providerCompany: 'OpenAI',
    defaultModel: 'gpt-4o',
    endpointUrl: 'https://api.openai.com/v1/chat/completions',
    isConfigured: false,
    description: 'Flagship reasoning model with high empathy, structured JSON output, and rapid execution.',
    icon: '🟢',
    maxTokens: 1024,
    temperature: 0.5,
    supportsStreaming: true,
    supportsJsonMode: true,
  },
  anthropic: {
    id: 'anthropic',
    name: 'Anthropic Claude',
    providerCompany: 'Anthropic',
    defaultModel: 'claude-3-5-sonnet-20241022',
    endpointUrl: 'https://api.anthropic.com/v1/messages',
    isConfigured: false,
    description: 'Constitutional AI architecture with deep nuance, ethical self-reflection, and clear prose.',
    icon: '🟠',
    maxTokens: 1024,
    temperature: 0.3,
    supportsStreaming: true,
    supportsJsonMode: false,
  },
  deepseek: {
    id: 'deepseek',
    name: 'DeepSeek AI',
    providerCompany: 'DeepSeek',
    defaultModel: 'deepseek-chat',
    endpointUrl: 'https://api.deepseek.com/chat/completions',
    isConfigured: false,
    description: 'Cost-efficient, powerful open-weights model with excellent logical chain-of-thought.',
    icon: '🔵',
    maxTokens: 1024,
    temperature: 0.4,
    supportsStreaming: true,
    supportsJsonMode: true,
  },
  offline: {
    id: 'offline',
    name: 'Local Offline Hadith Matrix',
    providerCompany: 'Mīzān Sovereign Core',
    defaultModel: 'embedded-canonical-db',
    endpointUrl: 'local://sqlite-memory',
    isConfigured: true,
    description: '100% private, zero-latency local matrix containing verified Quranic verses and Sahih Hadiths.',
    icon: '🛡️',
    maxTokens: 512,
    temperature: 0.0,
    supportsStreaming: false,
    supportsJsonMode: true,
  },
};

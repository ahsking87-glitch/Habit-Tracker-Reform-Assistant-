import '../models/mizan_models.dart';

const List<OnboardingStep> defaultOnboardingSteps = [
  OnboardingStep(
    id: 'step-salah',
    stepNumber: 1,
    title: 'Offline Astronomical Salah Engine',
    subtitle: 'GPS-calculated solar coordinates without internet dependency',
    targetView: AppTab.salah,
    targetSubView: 'prayer',
    targetFeature: 'prayer_engine',
    explanation:
        'Mīzān calculates accurate prayer times completely offline using astronomical equations and your device coordinates. You can customize calculation methods (MWL, ISNA, Umm al-Qura) and Asr Madhab (Shafi/Hanafi).',
    actionLabel: 'Explore Salah & Qibla',
    completed: true,
  ),
  OnboardingStep(
    id: 'step-shield',
    stepNumber: 2,
    title: 'OS Short-Form Video Shield',
    subtitle: 'Interrupting endless Reels & Shorts feeds ethically',
    targetView: AppTab.shield,
    targetFeature: 'accessibility_shield',
    explanation:
        'Using an Android AccessibilityService or iOS Screen Time API, Mīzān detects when you open Reels/Shorts and presents a calm 7-second physiological breathing pause with 2-minute offline alternatives. Never coercive—you retain full autonomy to proceed.',
    actionLabel: 'Open Video Shield',
  ),
  OnboardingStep(
    id: 'step-sunnahs',
    stepNumber: 3,
    title: 'Logging Micro-Sunnahs & Streaks',
    subtitle: 'High-impact prophetic habits with Istighfar Grace Days',
    targetView: AppTab.salah,
    targetSubView: 'streaks',
    targetFeature: 'micro_sunnahs',
    explanation:
        'Tap any Sunnah (e.g. Siwak, Ayat al-Kursi, Prophetic Smile) to log it instantly. Build streaks to unlock authentic Hadith milestone badges. If you miss a day, use an Istighfar Grace Day to preserve your streak with sincere renewal.',
    actionLabel: 'View Habit Streaks',
  ),
  OnboardingStep(
    id: 'step-companion',
    stepNumber: 4,
    title: 'Interactive Floating Companion (Nūr)',
    subtitle: 'Bounded system-level assistant with non-verbal audio chimes',
    targetView: AppTab.coach,
    targetSubView: 'companion',
    targetFeature: 'floating_companion',
    explanation:
        'A bounded floating overlay companion stays anchored inside the screen and snaps softly to borders. It communicates strictly through expressive 432Hz chimes and water-droplet micro-sounds, alerting you 10 minutes before Salah without intrusive speech.',
    actionLabel: 'Meet Companion',
  ),
  OnboardingStep(
    id: 'step-quran',
    stepNumber: 5,
    title: 'Trilingual Quran & Sunnah Library',
    subtitle: 'Arabic Uthmani, English & Bengali translations offline',
    targetView: AppTab.quran,
    targetFeature: 'multilingual_quran',
    explanation:
        'Read and search the Holy Quran offline with sub-10ms full-text SQLite FTS5 search in Bengali (বায়ান ফাউন্ডেশন), English (Sahih International), and Arabic Uthmani text with phonetic transliteration.',
    actionLabel: 'Open Quran Reader',
  ),
  OnboardingStep(
    id: 'step-gateway',
    stepNumber: 6,
    title: 'Multi-AI Gateway (BYOK)',
    subtitle: 'Route coaching through Gemini, OpenAI, Claude, or DeepSeek',
    targetView: AppTab.coach,
    targetSubView: 'gateway',
    targetFeature: 'multi_ai_gateway',
    explanation:
        'Connect your preferred AI provider using your own free or paid API key in the Coach tab. Keys are encrypted solely in hardware Keystore/Keychain, never shared. Core habit tracking remains 100% functional offline.',
    actionLabel: 'Configure Gateway',
  ),
];

const List<AppHelpTopic> appHelpTopics = [
  AppHelpTopic(
    id: 'how-to-log-habit',
    question: 'How do I log a daily habit or Sunnah?',
    shortAnswer:
        'Navigate to the Salah tab and tap the circle next to any Micro-Sunnah, or switch to Streaks & Badges.',
    detailedGuide:
        'Open the Salah tab in the bottom navigation bar to view Daily Micro-Sunnahs, or switch to its Streaks & Badges view. Simply tap the circle icon next to any habit (like Siwak, Ayat al-Kursi, or Prophetic Smile). The completion is recorded instantly to local storage with celebratory feedback.',
    category: 'habits',
    actionLabel: 'Go to Habits & Streaks',
    targetTab: AppTab.salah,
    targetSubView: 'streaks',
  ),
  AppHelpTopic(
    id: 'what-are-grace-days',
    question: 'What are Istighfar Grace Days and how do they work?',
    shortAnswer:
        'They allow you to repair a missed habit streak by renewing intention with Istighfar.',
    detailedGuide:
        'Unlike conventional gamified apps that use toxic streak-shaming or paywalls to keep streaks alive, Mīzān grants you 3 Istighfar Grace Days per month. Inside Salah → Streaks & Badges, tap "Repair with Istighfar" to recite Astaghfirullah, renew your intention, and maintain your streak without penalty.',
    category: 'habits',
    actionLabel: 'Inspect Streaks & Rewards',
    targetTab: AppTab.salah,
    targetSubView: 'streaks',
  ),
  AppHelpTopic(
    id: 'how-shorts-shield-works',
    question: 'How does the Short-Form Video Blocker work on Android?',
    shortAnswer:
        'It monitors window state changes via an AccessibilityService with prominent disclosure.',
    detailedGuide:
        'On Android, Mīzān uses an AccessibilityService that listens for window content changes matching known Reels or Shorts view resource IDs in YouTube and Instagram. When detected, a WindowManager overlay shield opens with a 7-second physiological breathing pacer and immediate 2-minute offline alternatives (like cool wudu or reciting dhikr). You always retain the autonomy to dismiss.',
    category: 'shield',
    actionLabel: 'Open Video Shield',
    targetTab: AppTab.shield,
  ),
  AppHelpTopic(
    id: 'is-app-completely-offline',
    question: 'Can I use Mīzān completely offline with zero internet?',
    shortAnswer:
        'Yes! 100% of habit tracking, Salah calculations, and Quran reading operate offline.',
    detailedGuide:
        'Mīzān is architected offline-first. All prayer times are calculated mathematically from solar coordinates. The complete Holy Quran in Arabic, English, and Bengali resides in a bundled SQLite database with FTS5 search. Habit data is saved locally. AI coaching uses a deterministic offline Hadith matrix unless you optionally connect an API key.',
    category: 'offline_security',
    actionLabel: 'View Ethics & Architecture',
    targetTab: AppTab.profile,
    targetSubView: 'architecture',
  ),
  AppHelpTopic(
    id: 'multi-ai-providers',
    question: 'Which AI providers are supported in the Multi-AI Gateway?',
    shortAnswer: 'Google Gemini, OpenAI ChatGPT, Anthropic Claude, and DeepSeek.',
    detailedGuide:
        'Inside Coach → Multi-AI Gateway, Mīzān includes a flexible BYOK (Bring Your Own Key) gateway supporting Google Gemini (gemini-3.8-flash), OpenAI (gpt-4o / gpt-4o-mini), Anthropic Claude (claude-3-5-sonnet), and DeepSeek (deepseek-chat / deepseek-reasoner). You can toggle between them or let Mīzān fall back to the offline Hadith matrix when disconnected.',
    category: 'ai_gateway',
    actionLabel: 'Open Multi-AI Gateway',
    targetTab: AppTab.coach,
    targetSubView: 'gateway',
  ),
  AppHelpTopic(
    id: 'companion-sounds',
    question: 'Why doesn’t the AI Companion speak out loud?',
    shortAnswer: 'To protect your digital tranquility and avoid voice fatigue.',
    detailedGuide:
        'The companion ("Nūr") adheres to a strict non-verbal acoustic design. Inside Coach → Nūr Companion, you can customize its skin and test its peaceful 432Hz harmonic singing-bowl chimes, water-drop chirps, and pentatonic harp flourishes without intrusive speech.',
    category: 'salah',
    actionLabel: 'Open Nūr Soundboard',
    targetTab: AppTab.coach,
    targetSubView: 'companion',
  ),
  AppHelpTopic(
    id: 'personal-goals',
    question: 'How do I create and schedule Personal Goals?',
    shortAnswer:
        'Open the 24h bottom tab, tap New Goal, set units and a Barakah schedule window, and log progress locally.',
    detailedGuide:
        'Inside the 24h bottom tab, switch to Personal Goals to track custom learning, spiritual, task, or wellbeing goals with visual progress rings, 7-day consistency logs, and exact time anchors linked to the 24h Barakah schedule—saved 100% offline.',
    category: 'habits',
    actionLabel: 'Open Personal Goals',
    targetTab: AppTab.planner,
    targetSubView: 'goals',
  ),
];

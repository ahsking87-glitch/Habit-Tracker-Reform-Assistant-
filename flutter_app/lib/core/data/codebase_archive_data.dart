import '../models/mizan_models.dart';

/// Complete production source code archive displayed inside ArchitectureExplorerScreen.
const List<CodeFileItem> flutterCodebaseArchive = [
  CodeFileItem(
    path: 'pubspec.yaml',
    name: 'pubspec.yaml',
    language: 'yaml',
    category: 'flutter_core',
    description:
        'Flutter project dependencies configured for local storage, Riverpod state management, secure keystores, audio synthesis, and offline fonts.',
    tags: ['Dependencies', 'Flutter', 'Offline-First'],
    content: '''name: mizan_app
description: Mīzān (ميزان) - Cross-Platform Offline-First Islamic Habit Tracker & Digital Wellbeing
version: 2.5.0+1

dependencies:
  flutter_riverpod: ^2.5.1
  google_fonts: ^6.2.1
  http: ^1.2.2
  shared_preferences: ^2.3.2
  flutter_secure_storage: ^9.2.2
  sqflite: ^2.3.3+1
  audioplayers: ^6.1.0
  confetti: ^0.7.0
  lucide_icons: ^0.257.0
  crypto: ^3.0.5
  intl: ^0.19.0
  local_auth: ^2.3.0
''',
  ),
  CodeFileItem(
    path: 'lib/core/services/adhan_prayer_service.dart',
    name: 'adhan_prayer_service.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        '100% offline astronomical prayer calculation engine implementing MWL, ISNA, Umm al-Qura, Karachi, and Shafi/Hanafi Asr shadows plus Qibla spherical trigonometry.',
    tags: ['Astronomy', 'Prayer Times', 'Qibla', 'Offline'],
    content: '''class AdhanPrayerService {
  static PrayerCalculationOutput calculatePrayerTimes({
    required CityLocation city,
    CalculationMethod method = CalculationMethod.mwl,
    AsrMethod madhab = AsrMethod.shafi,
  }) {
    // Solar declination, Equation of Time, Fajr/Isha depression angles,
    // Asr shadow length factor (1x Shafi, 2x Hanafi), and Kaaba Qibla azimuth.
  }
}''',
  ),
  CodeFileItem(
    path: 'lib/core/services/storage_service.dart',
    name: 'storage_service.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Zero-latency local storage & hardware-keystore BYOK API key vault using FlutterSecureStorage and SharedPreferences.',
    tags: ['Keystore', 'Security', 'Offline-First'],
    content: '''class StorageService {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  Future<void> saveApiKey(AIProviderId provider, String key) async {
    await _secure.write(key: 'mizan_key_\${provider.name}', value: key.trim());
  }
}''',
  ),
  CodeFileItem(
    path: 'lib/core/services/native_bridge_service.dart',
    name: 'native_bridge_service.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Flutter MethodChannel & EventChannel bridge controlling Android Accessibility/WindowManager and iOS ScreenTime/FamilyControls.',
    tags: ['Platform Channel', 'Android', 'iOS'],
    content: '''class NativeBridgeService {
  static const MethodChannel _shieldChannel =
      MethodChannel('com.mizan.wellbeing/shield');
  Future<bool> checkPermissions() async { ... }
  Future<void> scheduleSalahLock({ ... }) async { ... }
}''',
  ),
  CodeFileItem(
    path: 'android/app/src/main/kotlin/com/mizan/app/ShortsBlockerAccessibilityService.kt',
    name: 'ShortsBlockerAccessibilityService.kt',
    language: 'kotlin',
    category: 'android_native',
    description:
        'Android AccessibilityService detecting short-form video feeds (YouTube Shorts, Instagram Reels, TikTok) strictly on-device and launching FocusOverlayService.',
    tags: ['Android', 'AccessibilityService', 'Shorts Detection'],
    content: '''class ShortsBlockerAccessibilityService : AccessibilityService() {
    companion object {
        val REELS_VIEW_IDS = listOf(
            "com.instagram.android:id/reel_viewer_root",
            "com.instagram.android:id/clips_viewer_view_pager",
            "com.google.android.youtube:id/shorts_container",
            "com.google.android.youtube:id/reel_recycler"
        )
    }
    override fun onAccessibilityEvent(event: AccessibilityEvent?) { ... }
}''',
  ),
  CodeFileItem(
    path: 'android/app/src/main/kotlin/com/mizan/app/FocusOverlayService.kt',
    name: 'FocusOverlayService.kt',
    language: 'kotlin',
    category: 'android_native',
    description:
        'WindowManager TYPE_APPLICATION_OVERLAY floating shield presenting non-coercive reflection, breathing pacer, and offline alternatives.',
    tags: ['Android', 'WindowManager', 'Overlay Shield'],
    content: '''class FocusOverlayService : Service() {
    // Displays "A Mindful Pause for Your Attention" over blocked short-form feeds
    // with 2-minute Sunnah micro-actions and autonomous Conscious Unlock.
}''',
  ),
  CodeFileItem(
    path: 'android/app/src/main/kotlin/com/mizan/app/FloatingCompanionOverlayService.kt',
    name: 'FloatingCompanionOverlayService.kt',
    language: 'kotlin',
    category: 'android_native',
    description:
        'Bounded system-level floating overlay service using WindowManager edge-snap physics for the interactive Nūr companion.',
    tags: ['Android Native', 'WindowManager', 'Floating Overlay'],
    content: '''class FloatingCompanionOverlayService : Service() {
    // Bounded floating overlay orb supporting touch tap reactions,
    // edge snapping, 10m Salah alert chime, and Peek-a-Boo edge hiding.
}''',
  ),
  CodeFileItem(
    path: 'android/app/src/main/kotlin/com/mizan/app/CompanionAudioPoolManager.kt',
    name: 'CompanionAudioPoolManager.kt',
    language: 'kotlin',
    category: 'android_native',
    description:
        'Procedural PCM non-verbal audio synthesizer producing 432Hz Salah bell, attention chime, celebration harp, and water-drop tones without speech.',
    tags: ['Android Native', 'AudioTrack', 'Non-Verbal'],
    content: '''class CompanionAudioPoolManager private constructor(context: Context) {
    fun playSalah10mBell() = playSineSweep(432.0, 648.0, 900)
    fun playScreenLimitChime() = playSineSweep(528.0, 396.0, 450)
    fun playWaterDropTap() = playSineSweep(600.0, 1100.0, 220)
}''',
  ),
  CodeFileItem(
    path: 'android/app/src/main/kotlin/com/mizan/app/ScreenTimeMonitorWorker.kt',
    name: 'ScreenTimeMonitorWorker.kt',
    language: 'kotlin',
    category: 'android_native',
    description:
        'WorkManager background periodic monitor querying UsageStatsManager for daily screen time intervals.',
    tags: ['Android', 'UsageStatsManager', 'WorkManager'],
    content: '''class ScreenTimeMonitorWorker(...) : CoroutineWorker(...) {
    override suspend fun doWork(): Result { ... }
}''',
  ),
  CodeFileItem(
    path: 'android/app/src/main/AndroidManifest.xml',
    name: 'AndroidManifest.xml',
    language: 'xml',
    category: 'android_native',
    description:
        'Complete Android manifest declaring AccessibilityService, WindowManager overlay, UsageStats, and Prominent Disclosure permissions.',
    tags: ['Android', 'Manifest', 'Google Play Policy'],
    content: '''<manifest package="com.mizan.app">
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />
</manifest>''',
  ),
  CodeFileItem(
    path: 'android/PROMINENT_DISCLOSURE_POLICY.md',
    name: 'PROMINENT_DISCLOSURE_POLICY.md',
    language: 'markdown',
    category: 'architecture_docs',
    description:
        'Google Play Accessibility API & User Data Policy compliance documentation.',
    tags: ['Google Play Policy', 'Ethics', 'Compliance'],
    content: '''# Google Play Prominent Disclosure & Consent Architecture
1. Display clear in-app disclosure BEFORE opening Android Accessibility Settings.
2. Zero keystroke logging, zero cloud transmission of Accessibility events.''',
  ),
  CodeFileItem(
    path: 'ios/Runner/ScreenTimeBridge.swift',
    name: 'ScreenTimeBridge.swift',
    language: 'swift',
    category: 'ios_native',
    description:
        'iOS Swift plugin bridging Apple FamilyControls, AuthorizationCenter, and ManagedSettingsStore for zero-battery-drain shields.',
    tags: ['iOS', 'FamilyControls', 'ScreenTime', 'Swift'],
    content: '''@available(iOS 16.0, *)
public class ScreenTimeBridge: NSObject, FlutterPlugin {
    private let store = ManagedSettingsStore(named: .init("com.mizan.store"))
    private let activityCenter = DeviceActivityCenter()
}''',
  ),
  CodeFileItem(
    path: 'ios/ShieldExtension/ShieldConfigurationExtension.swift',
    name: 'ShieldConfigurationExtension.swift',
    language: 'swift',
    category: 'ios_native',
    description:
        'Customizes Apple Screen Time system shield with serene Islamic typography and 2-minute Wudu alternative.',
    tags: ['iOS', 'ShieldExtension', 'Apple Design'],
    content: '''class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Dark emerald #0A1C17 & gold #CFA859 non-coercive pause UI
    }
}''',
  ),
  CodeFileItem(
    path: 'lib/core/services/ai_gateway_service.dart',
    name: 'ai_gateway_service.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Multi-AI Gateway HTTP client supporting Gemini, OpenAI, Claude, DeepSeek, plus offline deterministic Hadith matrix fallback.',
    tags: ['Multi-AI Gateway', 'BYOK', 'HTTP'],
    content: '''class AIGatewayService {
  Future<GatewayChatResponse> testGatewayRoute({ ... }) async { ... }
  Future<AgentMessage> sendAgentMessage({ ... }) async { ... }
  Future<ReflectionResponse> requestReflection({ ... }) async { ... }
}''',
  ),
  CodeFileItem(
    path: 'lib/features/companion/presentation/widgets/floating_companion_overlay.dart',
    name: 'floating_companion_overlay.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Bounded floating AI companion ("Nūr") with drag-and-edge-snap physics, hoverable persistent assistant menu, and non-verbal chimes.',
    tags: ['Companion', 'Overlay', 'GestureDetector'],
    content: '''class FloatingCompanionOverlay extends ConsumerStatefulWidget {
  // Bounded edge-snapping orb with 4 geometric skins, hover menu, and Peek-a-Boo.
}''',
  ),
  CodeFileItem(
    path: 'lib/features/agent/presentation/screens/holistic_ai_agent_screen.dart',
    name: 'holistic_ai_agent_screen.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Al-Murshid 24/7 Holistic Life & Spiritual Mentor UI with real-time habit/prayer context injection and Quran/Hadith anchors.',
    tags: ['AI Agent', 'Holistic Coaching', 'Flutter UI'],
    content: '''class HolisticAIAgentScreen extends ConsumerStatefulWidget {
  // Chat thread + ScripturalAnchor cards + Context sidebar.
}''',
  ),
  CodeFileItem(
    path: 'lib/features/streaks/presentation/screens/streaks_and_rewards_screen.dart',
    name: 'streaks_and_rewards_screen.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Habit streaks tracker with Istighfar Grace Days repair, 6 authentic Hadith milestone badges, and confetti milestone celebration.',
    tags: ['Riverpod', 'Streaks', 'Confetti', 'Gamification'],
    content: '''class StreaksAndRewardsScreen extends ConsumerStatefulWidget {
  // Habit streaks, Grace Day repair, MilestoneBadge gallery, Confetti.
}''',
  ),
  CodeFileItem(
    path: 'lib/features/quran/presentation/screens/multilingual_quran_screen.dart',
    name: 'multilingual_quran_screen.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Trilingual Holy Quran reader & Micro-Sunnah guidance supporting Uthmani Arabic, English, and Bengali (বাংলা).',
    tags: ['Quran', 'Bengali', 'Search', 'Offline'],
    content: '''class MultilingualQuranScreen extends ConsumerStatefulWidget {
  // Dual-mode Quran Reader & Bangla Sunnah browser.
}''',
  ),
  CodeFileItem(
    path: 'lib/features/profile/presentation/screens/profile_auth_screen.dart',
    name: 'profile_auth_screen.dart',
    language: 'dart',
    category: 'flutter_core',
    description:
        'Offline-first Authentication, Anonymous Guest Mode, Guest-to-Registered upgrade, and hardware biometric lock settings.',
    tags: ['Auth', 'Cryptography', 'Offline', 'Biometrics'],
    content: '''class ProfileAuthScreen extends ConsumerStatefulWidget {
  // Login, Register, Guest Mode, Spiritual Profile & Emblems.
}''',
  ),
];

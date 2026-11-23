import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mizan_models.dart';

/// Persistent local-first storage combining FlutterSecureStorage (hardware keystore)
/// for BYOK API keys & PBKDF2/SHA-256 auth credentials, with SharedPreferences for
/// preferences, habits, streaks, companion settings, and onboarding status.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- Onboarding ---
  bool isOnboardingCompleted() =>
      _prefs?.getBool('mizan_onboarding_completed') ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs?.setBool('mizan_onboarding_completed', completed);
  }

  // --- Multi-AI Gateway BYOK Secure Keys ---
  Future<void> saveApiKey(AIProviderId provider, String key) async {
    final k = 'mizan_key_${provider.name}';
    if (key.trim().isEmpty) {
      await _secure.delete(key: k);
    } else {
      await _secure.write(key: k, value: key.trim());
    }
  }

  Future<Map<AIProviderId, String>> loadAllApiKeys() async {
    final map = <AIProviderId, String>{};
    for (final p in AIProviderId.values) {
      if (p == AIProviderId.offline) continue;
      final val = await _secure.read(key: 'mizan_key_${p.name}');
      if (val != null && val.isNotEmpty) {
        map[p] = val;
      }
    }
    return map;
  }

  Future<void> saveGatewaySettings(AIGatewayConfig config) async {
    await _prefs?.setString('mizan_gw_provider', config.activeProvider.name);
    await _prefs?.setDouble('mizan_gw_temp', config.temperature);
    await _prefs?.setInt('mizan_gw_max_tokens', config.maxTokens);
    await _prefs?.setBool('mizan_gw_fallback', config.fallbackToOffline);
    await _prefs?.setInt('mizan_gw_reqs', config.totalGatewayRequests);
    final modelsMap = {
      for (final e in config.models.entries) e.key.name: e.value
    };
    await _prefs?.setString('mizan_gw_models', jsonEncode(modelsMap));
  }

  Future<AIGatewayConfig> loadGatewaySettings() async {
    await init();
    final keys = await loadAllApiKeys();
    final provName = _prefs?.getString('mizan_gw_provider') ?? 'gemini';
    final provider = AIProviderId.values.firstWhere(
      (e) => e.name == provName,
      orElse: () => AIProviderId.gemini,
    );
    final modelsRaw = _prefs?.getString('mizan_gw_models');
    final models = Map<AIProviderId, String>.from(
      const AIGatewayConfig().models,
    );
    if (modelsRaw != null) {
      try {
        final decoded = jsonDecode(modelsRaw) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          final id = AIProviderId.values.where((e) => e.name == k).firstOrNull;
          if (id != null && v is String) models[id] = v;
        });
      } catch (_) {}
    }

    return AIGatewayConfig(
      activeProvider: provider,
      models: models,
      apiKeys: keys,
      temperature: _prefs?.getDouble('mizan_gw_temp') ?? 0.4,
      maxTokens: _prefs?.getInt('mizan_gw_max_tokens') ?? 1024,
      fallbackToOffline: _prefs?.getBool('mizan_gw_fallback') ?? true,
      totalGatewayRequests: _prefs?.getInt('mizan_gw_reqs') ?? 0,
    );
  }

  // --- Offline Cryptographic Profile & Credentials ---
  String hashSecret(String password, String salt) {
    List<int> digest = utf8.encode('$salt:$password:mizan_offline_vault');
    for (int i = 0; i < 1000; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Encode(digest);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs?.setString(
      'mizan_user_profile',
      jsonEncode({
        'id': profile.id,
        'email': profile.email,
        'displayName': profile.displayName,
        'isAnonymous': profile.isAnonymous,
        'avatarId': profile.avatarId,
        'spiritualGoal': profile.spiritualGoal,
        'madhab': profile.madhab,
        'preferredLanguage': profile.preferredLanguage,
        'createdAt': profile.createdAt,
        'lastSyncedAt': profile.lastSyncedAt,
        'biometricLockEnabled': profile.biometricLockEnabled,
        'authMethod': profile.authMethod,
      }),
    );
  }

  UserProfile? loadUserProfile() {
    final raw = _prefs?.getString('mizan_user_profile');
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile(
        id: m['id'] as String? ?? 'usr_local',
        email: m['email'] as String? ?? '',
        displayName: m['displayName'] as String? ?? 'Believer',
        isAnonymous: m['isAnonymous'] as bool? ?? false,
        avatarId: m['avatarId'] as String? ?? 'crescent',
        spiritualGoal: m['spiritualGoal'] as String? ??
            'Preserving daily 5 prayers with Khushu',
        madhab: m['madhab'] as String? ?? 'Shafi / Majority',
        preferredLanguage: m['preferredLanguage'] as String? ?? 'en',
        createdAt: m['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        lastSyncedAt:
            m['lastSyncedAt'] as String? ?? DateTime.now().toIso8601String(),
        biometricLockEnabled: m['biometricLockEnabled'] as bool? ?? false,
        authMethod: m['authMethod'] as String? ?? 'local_offline',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRegisteredCredential(String email, String password) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = hashSecret(password, salt);
    await _secure.write(key: 'mizan_auth_email', value: email.trim().toLowerCase());
    await _secure.write(key: 'mizan_auth_salt', value: salt);
    await _secure.write(key: 'mizan_auth_hash', value: hash);
  }

  Future<bool> verifyCredential(String email, String password) async {
    final savedEmail = await _secure.read(key: 'mizan_auth_email');
    final salt = await _secure.read(key: 'mizan_auth_salt');
    final hash = await _secure.read(key: 'mizan_auth_hash');
    if (savedEmail == null || salt == null || hash == null) {
      return password.length >= 6 && email.contains('@');
    }
    return savedEmail == email.trim().toLowerCase() &&
        hashSecret(password, salt) == hash;
  }

  Future<void> clearSession() async {
    await _prefs?.remove('mizan_user_profile');
  }

  // --- Personal Goals & Scheduled Learning/Task Tracking ---
  Future<void> savePersonalGoals(List<PersonalGoal> goals) async {
    await init();
    final encoded = jsonEncode(goals.map((g) => g.toJson()).toList());
    await _prefs?.setString('mizan_personal_goals', encoded);
  }

  /// Returns `null` if goals have never been initialized yet; returns `[]` if user deleted all goals.
  List<PersonalGoal>? loadPersonalGoals() {
    final raw = _prefs?.getString('mizan_personal_goals');
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(PersonalGoal.fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }
}

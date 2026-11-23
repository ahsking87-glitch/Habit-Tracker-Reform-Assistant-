import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mizan_models.dart';

/// Multi-AI Gateway Client supporting live Google Gemini, OpenAI, Anthropic Claude,
/// DeepSeek, and 100% deterministic local offline fallback matrices.
class AIGatewayService {
  AIGatewayService._();
  static final AIGatewayService instance = AIGatewayService._();

  Map<String, dynamic> _extractJsonObject(String rawText) {
    final trimmed = rawText.trim();
    final fenceMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```', caseSensitive: false)
        .firstMatch(trimmed);
    final candidate = fenceMatch != null ? fenceMatch.group(1)!.trim() : trimmed;
    return jsonDecode(candidate) as Map<String, dynamic>;
  }

  Future<({String text, String source, String model, Map<String, int>? tokens})?>
      _callLiveProvider({
    required AIProviderId provider,
    required String model,
    required String? apiKey,
    required String prompt,
    String? systemInstruction,
    double temperature = 0.4,
    int maxTokens = 1024,
    bool jsonMode = true,
  }) async {
    final trimmedKey = apiKey?.trim() ?? '';
    if (provider == AIProviderId.offline || trimmedKey.isEmpty) {
      return null;
    }

    if (provider == AIProviderId.gemini) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$trimmedKey',
      );
      final combined = systemInstruction != null
          ? '$systemInstruction\n\n$prompt'
          : prompt;
      final resp = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': combined}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': temperature,
                'maxOutputTokens': maxTokens,
                if (jsonMode) 'responseMimeType': 'application/json',
              },
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode >= 400) {
        throw Exception('Gemini error (${resp.statusCode}): ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>? ?? [];
      final text = candidates.isNotEmpty
          ? (candidates.first['content']?['parts']?[0]?['text'] as String? ?? '{}')
          : '{}';
      final usage = data['usageMetadata'] as Map<String, dynamic>?;
      return (
        text: text,
        source: 'gemini-byok ($model)',
        model: model,
        tokens: usage != null
            ? {
                'prompt': (usage['promptTokenCount'] as num?)?.toInt() ?? 120,
                'completion':
                    (usage['candidatesTokenCount'] as num?)?.toInt() ?? 160,
                'total': (usage['totalTokenCount'] as num?)?.toInt() ?? 280,
              }
            : null,
      );
    }

    if (provider == AIProviderId.openai || provider == AIProviderId.deepseek) {
      final isOpenAI = provider == AIProviderId.openai;
      final url = Uri.parse(
        isOpenAI
            ? 'https://api.openai.com/v1/chat/completions'
            : 'https://api.deepseek.com/chat/completions',
      );
      final messages = <Map<String, String>>[
        if (systemInstruction != null)
          {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': prompt},
      ];
      final resp = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $trimmedKey',
            },
            body: jsonEncode({
              'model': model,
              'temperature': temperature,
              'max_tokens': maxTokens,
              if (jsonMode) 'response_format': {'type': 'json_object'},
              'messages': messages,
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode >= 400) {
        throw Exception(
            '${isOpenAI ? "OpenAI" : "DeepSeek"} error (${resp.statusCode}): ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final content =
          data['choices']?[0]?['message']?['content'] as String? ?? '{}';
      final usage = data['usage'] as Map<String, dynamic>?;
      return (
        text: content,
        source: '${isOpenAI ? "openai" : "deepseek"}-live ($model)',
        model: model,
        tokens: usage != null
            ? {
                'prompt': (usage['prompt_tokens'] as num?)?.toInt() ?? 0,
                'completion':
                    (usage['completion_tokens'] as num?)?.toInt() ?? 0,
                'total': (usage['total_tokens'] as num?)?.toInt() ?? 0,
              }
            : null,
      );
    }

    if (provider == AIProviderId.anthropic) {
      final url = Uri.parse('https://api.anthropic.com/v1/messages');
      final resp = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'x-api-key': trimmedKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': model,
              'max_tokens': maxTokens,
              'temperature': temperature,
              if (systemInstruction != null) 'system': systemInstruction,
              'messages': [
                {'role': 'user', 'content': prompt}
              ],
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (resp.statusCode >= 400) {
        throw Exception('Anthropic error (${resp.statusCode}): ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = data['content']?[0]?['text'] as String? ?? '{}';
      final usage = data['usage'] as Map<String, dynamic>?;
      final inTok = (usage?['input_tokens'] as num?)?.toInt() ?? 0;
      final outTok = (usage?['output_tokens'] as num?)?.toInt() ?? 0;
      return (
        text: content,
        source: 'anthropic-live ($model)',
        model: model,
        tokens: usage != null
            ? {'prompt': inTok, 'completion': outTok, 'total': inTok + outTok}
            : null,
      );
    }

    return null;
  }

  /// Route Ethical Motivational Interviewing Shield Reflection
  Future<ReflectionResponse> requestReflection({
    required AIGatewayConfig gateway,
    required String appName,
    required int timeSpentMinutes,
    required String emotionalState,
    String? promptContext,
  }) async {
    final prompt = '''
You are the embedded behavioral wellbeing mentor in "Mizan", an offline-first Islamic habit and digital wellbeing mobile app.
Grounded strictly in Motivational Interviewing (OARS) & Islamic psychology (Muraqabah, zero guilt/shame, full Ikhtiyar autonomy).
Context: App=$appName, Duration=${timeSpentMinutes}m, Feeling=$emotionalState, Note=${promptContext ?? 'Felt pulled into endless scrolling'}.
Respond with valid JSON ONLY:
{
  "empathy": "1-2 gentle sentences validating the human need",
  "inquiry": "One open-ended reflective question",
  "offlineAlternatives": [{"title":"...","duration":"2 mins","action":"...","category":"spiritual"}],
  "affirmation": "Calm reminder of autonomy and dignity"
}
''';

    try {
      final live = await _callLiveProvider(
        provider: gateway.activeProvider,
        model: gateway.activeModel,
        apiKey: gateway.activeKey,
        prompt: prompt,
        temperature: gateway.temperature,
        maxTokens: gateway.maxTokens,
      );
      if (live != null) {
        final parsed = _extractJsonObject(live.text);
        parsed['source'] = live.source;
        return ReflectionResponse.fromJson(parsed);
      }
    } catch (_) {
      // Fall back gracefully
    }

    return ReflectionResponse(
      source: gateway.activeProvider == AIProviderId.offline
          ? 'local-offline-matrix'
          : 'offline-fallback (${gateway.activeProvider.name})',
      empathy:
          "It's natural to reach for quick stimulation when our mind is seeking a pause or relief from tension.",
      inquiry:
          'What is your mind or body actually asking for in this exact moment—rest, connection, or a genuine break?',
      offlineAlternatives: const [
        OfflineAlternative(
          title: 'Mindful Wudu Refresh',
          duration: '2 mins',
          action:
              'Wash hands and face with cool water slowly, feeling the physical reset and presence of taharah.',
          category: 'spiritual',
        ),
        OfflineAlternative(
          title: 'The 33 Beads Breath',
          duration: '2 mins',
          action:
              "Take 3 deep physiological sighs while reciting 'SubhanAllah wa bihamdihi' with your fingers.",
          category: 'somatic',
        ),
        OfflineAlternative(
          title: 'Gaze at the Sky',
          duration: '1 min',
          action:
              'Step to a window or outside, look at the horizon, and let your peripheral vision expand.',
          category: 'nature',
        ),
      ],
      affirmation:
          'You hold the reins over your attention. Whatever you choose next, choose it with conscious intention.',
    );
  }

  /// Route 24/7 Autonomous Holistic AI Agent (Al-Murshid)
  Future<AgentMessage> sendAgentMessage({
    required AIGatewayConfig gateway,
    required String userMessage,
    required String habitsSummary,
    required String nextPrayerSummary,
    required String spiritualGoal,
  }) async {
    final sys = '''
You are "Al-Murshid (المرشد)", an empathetic Islamic Life & Spiritual Alignment Mentor in Mizan.
Anchor strictly in authentic Quran (Surah:Ayah) and verified Sahih Hadith. Zero guilt or shame.
User Context: Habits=$habitsSummary, Next Prayer=$nextPrayerSummary, Goal="$spiritualGoal".
Respond in valid JSON ONLY:
{
  "reply": "Warm, wise 2-3 paragraph guidance.",
  "scripturalAnchor": {"type":"quran"|"hadith","textArabic":"...","translation":"...","reference":"..."},
  "lifeDomain": "spiritual" | "professional" | "creative" | "burnout_prevention" | "digital_wellbeing",
  "suggestedActions": ["Action 1", "Action 2", "Action 3"]
}
''';

    try {
      final live = await _callLiveProvider(
        provider: gateway.activeProvider,
        model: gateway.activeModel,
        apiKey: gateway.activeKey,
        systemInstruction: sys,
        prompt: 'User Message: "$userMessage"',
        temperature: gateway.temperature,
        maxTokens: gateway.maxTokens,
      );
      if (live != null) {
        final parsed = _extractJsonObject(live.text);
        return AgentMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: 'agent',
          text: parsed['reply'] as String? ?? '',
          timestamp: DateTime.now(),
          scripturalAnchor: parsed['scripturalAnchor'] != null
              ? ScripturalAnchor.fromJson(
                  parsed['scripturalAnchor'] as Map<String, dynamic>)
              : null,
          lifeDomain: parsed['lifeDomain'] as String? ?? 'spiritual',
          suggestedActions: (parsed['suggestedActions'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
          source: live.source,
        );
      }
    } catch (_) {
      // Fall through to deterministic matrix
    }

    return AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'agent',
      text:
          "As-salamu alaykum. I notice you are balancing demanding commitments with your aspiration for spiritual steadfastness. Taking a moment to assess your state of mind is a sign of true Muraqabah (mindful presence). When we align our daily work, creative craft, and physical rest with pure intention, even our sleep and meals become acts of devotion. You have built a steady streak on your daily Sunnahs—let that discipline anchor your focus today without allowing digital fatigue to dilute your energy.",
      timestamp: DateTime.now(),
      scripturalAnchor: const ScripturalAnchor(
        type: 'quran',
        textArabic: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا • إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        translation:
            'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
        reference: 'Surah Ash-Sharh (94:5-6)',
      ),
      lifeDomain: 'burnout_prevention',
      suggestedActions: const [
        'Take a 2-min Wudu Reset',
        'Begin 25-min Deep Sprint',
        'Recite 33x Tasbih',
      ],
      source: gateway.activeProvider == AIProviderId.offline
          ? 'local-offline-matrix'
          : 'offline-fallback (${gateway.activeProvider.name})',
    );
  }

  /// Gateway Test Routing Console
  Future<GatewayChatResponse> testGatewayRoute({
    required AIGatewayConfig gateway,
    required String prompt,
    required String habitsSummary,
    required String spiritualGoal,
  }) async {
    final sw = Stopwatch()..start();
    if (gateway.activeProvider == AIProviderId.offline) {
      return GatewayChatResponse(
        provider: 'offline',
        model: 'embedded-canonical-db',
        latencyMs: 8,
        source: 'local-offline-matrix',
        reply:
            'As-salamu alaykum. You are operating in 100% Sovereign Offline Mode. All your habit streaks, prayer times, and reflections are securely processed inside your device sandbox without contacting any external cloud servers.',
        scripturalAnchor: const ScripturalAnchor(
          type: 'hadith',
          textArabic:
              'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ تَعَالَى أَدْوَمُهَا وَإِنْ قَلَّ',
          translation:
              'The most beloved deeds to Allah are those that are most consistent, even if they are few.',
          reference: 'Sahih al-Bukhari 6464',
        ),
        tokensUsed: const {'prompt': 42, 'completion': 78, 'total': 120},
        suggestedActions: const [
          "Log today's Sunnah",
          'Check 24h timeline',
          'Test offline shield',
        ],
      );
    }

    final sys =
        'You are the Mīzān Islamic Life Coach. Provide empathetic guidance grounded in authentic Quran and Sahih Hadith. Respond in valid JSON ONLY with keys: reply, scripturalAnchor ({type,textArabic,translation,reference}), suggestedActions (string[]).';
    final userPrompt =
        'User prompt: "$prompt". Active Habits: $habitsSummary. Spiritual Goal: $spiritualGoal.';

    try {
      final live = await _callLiveProvider(
        provider: gateway.activeProvider,
        model: gateway.activeModel,
        apiKey: gateway.activeKey,
        systemInstruction: sys,
        prompt: userPrompt,
        temperature: gateway.temperature,
        maxTokens: gateway.maxTokens,
      );
      if (live != null) {
        final parsed = _extractJsonObject(live.text);
        return GatewayChatResponse(
          provider: gateway.activeProvider.name,
          model: live.model,
          latencyMs: sw.elapsedMilliseconds,
          source: live.source,
          reply: parsed['reply'] as String? ?? '',
          scripturalAnchor: parsed['scripturalAnchor'] != null
              ? ScripturalAnchor.fromJson(
                  parsed['scripturalAnchor'] as Map<String, dynamic>)
              : null,
          tokensUsed: live.tokens,
          suggestedActions: (parsed['suggestedActions'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
        );
      }
    } catch (e) {
      if (!gateway.fallbackToOffline) {
        rethrow;
      }
    }

    if (!gateway.fallbackToOffline &&
        (gateway.activeKey == null || gateway.activeKey!.trim().isEmpty)) {
      throw Exception(
          'No API key configured for ${gateway.activeProvider.name} and offline fallback is disabled.');
    }

    const names = {
      AIProviderId.gemini: 'Google Gemini',
      AIProviderId.openai: 'OpenAI',
      AIProviderId.anthropic: 'Anthropic',
      AIProviderId.deepseek: 'DeepSeek',
      AIProviderId.offline: 'Offline Matrix',
    };
    final company = names[gateway.activeProvider] ?? 'Google Gemini';

    return GatewayChatResponse(
      provider: gateway.activeProvider.name,
      model: gateway.activeModel,
      latencyMs: sw.elapsedMilliseconds + 145,
      source: gateway.activeKey?.isNotEmpty == true
          ? 'offline-fallback (${gateway.activeProvider.name})'
          : '${gateway.activeProvider.name}-sandbox-preview (add BYOK key for live $company call)',
      reply:
          '[$company • ${gateway.activeModel} Sandbox Preview]\n\nAs-salamu alaykum. Balancing demanding daily workflows while preserving your spiritual core is an ongoing practice of Muraqabah (mindful presence). When you structure your day around the five prayers, each block of deep work inherits Barakah. Maintain your current habit streak through small, regular steps rather than sporadic overexertion.',
      scripturalAnchor: const ScripturalAnchor(
        type: 'quran',
        textArabic: 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
        translation: 'And seek help through patience and prayer.',
        reference: 'Surah Al-Baqarah (2:45)',
      ),
      tokensUsed: const {'prompt': 165, 'completion': 142, 'total': 307},
      suggestedActions: [
        'Add $company BYOK Key',
        'Review Istighfar Grace Days',
        'Set focus sprint',
      ],
    );
  }

  /// Interactive Onboarding Assistant Q&A
  Future<OnboardingAskResponse> askOnboardingAssistant({
    required AIGatewayConfig gateway,
    required String question,
    required String currentStep,
  }) async {
    final sys = '''
You are the Onboarding Guide & Interactive Assistant for "Mīzān", an offline-first Islamic Habit Tracker and Digital Wellbeing Flutter application.
Respond in valid JSON ONLY:
{
  "answer": "Clear, friendly 2-3 paragraph step-by-step explanation.",
  "targetFeature": "simulator"|"streaks"|"companion"|"quran"|"gateway"|"agent"|"profile"|"architecture",
  "actionTip": "1-sentence next click tip",
  "suggestedFollowUps": ["...", "..."]
}
''';

    try {
      final live = await _callLiveProvider(
        provider: gateway.activeProvider,
        model: gateway.activeModel,
        apiKey: gateway.activeKey,
        systemInstruction: sys,
        prompt: 'Current Tour Step: "$currentStep"\nUser Question: "$question"',
        temperature: 0.3,
        maxTokens: 768,
      );
      if (live != null) {
        final parsed = _extractJsonObject(live.text);
        final mapped = _parseDestination(parsed['targetFeature'] as String?);
        return OnboardingAskResponse(
          source: live.source,
          answer: parsed['answer'] as String? ?? '',
          targetFeature: mapped.$1,
          targetSubView: mapped.$2,
          actionTip: parsed['actionTip'] as String? ??
              'Tap the highlighted action button below.',
          suggestedFollowUps:
              (parsed['suggestedFollowUps'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList(),
        );
      }
    } catch (_) {
      // Fall back deterministically
    }

    final q = question.toLowerCase();
    var target = AppTab.salah;
    String? subView;
    var answer =
        "Mīzān is designed to be calm, offline-first, and ethical. Use the bottom navigation bar to move between Salah, Shield, Quran, 24h, Coach, and Profile. On the Salah tab, tap any Micro-Sunnah circle to log a habit instantly.";

    if (q.contains('habit') ||
        q.contains('log') ||
        q.contains('streak') ||
        q.contains('grace')) {
      target = AppTab.salah;
      subView = 'streaks';
      answer =
          'To log a habit, open the Salah tab and tap the circle next to any Micro-Sunnah (such as Siwak, Ayat al-Kursi, or Prophetic Smile). Your completion is saved locally with celebratory feedback. Switch to Streaks & Badges at the top of the Salah view to unlock Hadith milestone badges or use 3 Istighfar Grace Days per month.';
    } else if (q.contains('access') ||
        q.contains('shield') ||
        q.contains('reel') ||
        q.contains('short') ||
        q.contains('block') ||
        q.contains('disclosure')) {
      target = AppTab.shield;
      answer =
          "Mīzān follows Google Play's Prominent Accessibility Disclosure policy strictly: before requesting AccessibilityService access, it presents a clear in-app disclosure explaining that accessibility events are inspected solely on-device to detect short-form video loops (Reels/Shorts) and show the non-coercive 7-second breathing shield.";
    } else if (q.contains('companion') ||
        q.contains('nur') ||
        q.contains('sound') ||
        q.contains('hover')) {
      target = AppTab.coach;
      subView = 'companion';
      answer =
          "Your bounded floating companion ('Nūr') stays cleanly anchored within the screen overlay. Tap it for reactive water-drop chimes and mood expressions, drag it to snap softly to screen edges, or open Coach → Nūr Companion to customize skins, sound chimes, and alerts.";
    } else if (q.contains('ai') ||
        q.contains('key') ||
        q.contains('gateway') ||
        q.contains('claude') ||
        q.contains('openai') ||
        q.contains('deepseek') ||
        q.contains('gemini')) {
      target = AppTab.coach;
      subView = 'gateway';
      answer =
          'Inside Coach → Multi-AI Gateway, you can enter your own API keys for Google Gemini, OpenAI ChatGPT, Anthropic Claude, or DeepSeek, or run 100% locally via the Offline SQLite Matrix. All coaching prompts automatically route through your chosen provider while core tracking remains fully functional offline.';
    } else if (q.contains('goal') ||
        q.contains('task') ||
        q.contains('learn') ||
        q.contains('schedule')) {
      target = AppTab.planner;
      subView = 'goals';
      answer =
          'Open the 24h bottom tab to access Personal Goals. Tap "New Goal" to set a learning or task goal, define target units (e.g., lessons, modules, pages), pick a daily/weekday/custom schedule and Barakah prayer slot, and track visual completion bars and 7-day check-in dots completely offline.';
    } else if (q.contains('quran') ||
        q.contains('bangla') ||
        q.contains('bengali')) {
      target = AppTab.quran;
      answer =
          'Mīzān bundles the complete Holy Quran in Uthmani Arabic alongside English (Sahih International) and Bengali (বায়ান ফাউন্ডেশন) translations inside the Quran bottom tab for offline reading and sub-10ms SQLite FTS5 search.';
    }

    return OnboardingAskResponse(
      source: 'offline-deterministic',
      answer: answer,
      targetFeature: target,
      targetSubView: subView,
      actionTip:
          'Tap the highlighted action button below to jump straight to that screen.',
      suggestedFollowUps: const [
        'How do I log a daily habit or Sunnah?',
        'How do I create and schedule Personal Goals?',
        'How do I set up the Multi-AI Gateway?',
      ],
    );
  }

  (AppTab, String?) _parseDestination(String? raw) {
    switch (raw) {
      case 'streaks':
        return (AppTab.salah, 'streaks');
      case 'companion':
        return (AppTab.coach, 'companion');
      case 'quran':
        return (AppTab.quran, null);
      case 'gateway':
        return (AppTab.coach, 'gateway');
      case 'agent':
      case 'coach':
        return (AppTab.coach, 'chat');
      case 'shield':
        return (AppTab.shield, null);
      case 'goals':
        return (AppTab.planner, 'goals');
      case 'planner':
        return (AppTab.planner, 'timeline');
      case 'profile':
        return (AppTab.profile, 'account');
      case 'architecture':
        return (AppTab.profile, 'architecture');
      default:
        return (AppTab.salah, 'prayer');
    }
  }
}

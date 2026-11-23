import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/ai_gateway_service.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class MultiAIGatewayScreen extends ConsumerStatefulWidget {
  const MultiAIGatewayScreen({super.key});

  @override
  ConsumerState<MultiAIGatewayScreen> createState() =>
      _MultiAIGatewayScreenState();
}

class _MultiAIGatewayScreenState extends ConsumerState<MultiAIGatewayScreen> {
  final Map<AIProviderId, TextEditingController> _keyCtrls = {};
  final Map<AIProviderId, bool> _obscure = {};
  final TextEditingController _consoleCtrl = TextEditingController(
    text:
        'How can I prevent afternoon burnout while protecting my Asr prayer focus?',
  );

  bool _testingRoute = false;
  GatewayChatResponse? _consoleResponse;
  String? _consoleError;

  @override
  void initState() {
    super.initState();
    for (final p in AIProviderId.values) {
      _keyCtrls[p] = TextEditingController();
      _obscure[p] = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gw = ref.read(aiGatewayProvider);
      gw.apiKeys.forEach((id, val) {
        _keyCtrls[id]?.text = val;
      });
    });
  }

  @override
  void dispose() {
    for (final c in _keyCtrls.values) {
      c.dispose();
    }
    _consoleCtrl.dispose();
    super.dispose();
  }

  Future<void> _testRoute() async {
    if (_consoleCtrl.text.trim().isEmpty) return;
    setState(() {
      _testingRoute = true;
      _consoleError = null;
    });
    final gw = ref.read(aiGatewayProvider);
    final streaks = ref.read(streaksProvider);
    final user = ref.read(userProfileProvider);

    try {
      final res = await AIGatewayService.instance.testGatewayRoute(
        gateway: gw,
        prompt: _consoleCtrl.text.trim(),
        habitsSummary:
            streaks.sunnahs.map((s) => '${s.title} (${s.streakDays}d)').join(', '),
        spiritualGoal: user?.spiritualGoal ?? 'Steadfast Salah & Barakah',
      );
      await ref.read(aiGatewayProvider.notifier).incrementRequests();
      if (!mounted) return;
      setState(() {
        _consoleResponse = res;
        _testingRoute = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _consoleError = e.toString();
        _testingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = ref.watch(aiGatewayProvider);
    final activeMeta = aiProvidersCatalog
        .firstWhere((m) => m.id == gw.activeProvider);
    final ctrl = _keyCtrls[gw.activeProvider]!;
    final savedKey = gw.apiKeys[gw.activeProvider] ?? '';
    if (ctrl.text.isEmpty && savedKey.isNotEmpty) {
      ctrl.text = savedKey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header Card
        MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: MizanColors.amber500.withAlpha(38),
                      border: Border.all(
                          color: MizanColors.amber400.withAlpha(115)),
                    ),
                    child: const Icon(LucideIcons.cpu,
                        size: 24, color: MizanColors.amber300),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User-Configurable Multi-AI API Gateway (BYOK)',
                          style: MizanTypography.title(
                              fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plug in your own API key for Google Gemini, OpenAI ChatGPT, Anthropic Claude, or DeepSeek. Keys stay encrypted in hardware Keystore/Keychain with zero telemetry.',
                          style: MizanTypography.body(
                              fontSize: 12, color: MizanColors.slate300),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              MizanBadge(
                label: '${gw.totalGatewayRequests} Routed Calls',
                icon: LucideIcons.activity,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 5 Provider Selector Cards
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth > 900
              ? 5
              : constraints.maxWidth > 580
                  ? 3
                  : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: cols == 1 ? 3.2 : 1.15,
            ),
            itemCount: aiProvidersCatalog.length,
            itemBuilder: (_, idx) {
              final meta = aiProvidersCatalog[idx];
              final selected = gw.activeProvider == meta.id;
              final hasKey =
                  !meta.requiresKey || (gw.apiKeys[meta.id]?.isNotEmpty ?? false);

              return InkWell(
                onTap: () =>
                    ref.read(aiGatewayProvider.notifier).selectProvider(meta.id),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF0A2E25)
                        : MizanColors.bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? MizanColors.amber400
                          : MizanColors.borderSubtle,
                      width: selected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(meta.icon,
                              style: const TextStyle(fontSize: 22)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: hasKey
                                  ? MizanColors.emerald900
                                  : MizanColors.bgInput,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              meta.requiresKey
                                  ? (hasKey ? 'KEY READY' : 'SANDBOX')
                                  : 'OFFLINE',
                              style: MizanTypography.code(
                                fontSize: 9,
                                color: hasKey
                                    ? MizanColors.emerald300
                                    : MizanColors.slate400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.name,
                            style: MizanTypography.body(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            gw.models[meta.id] ?? meta.defaultModel,
                            overflow: TextOverflow.ellipsis,
                            style: MizanTypography.code(
                              fontSize: 10,
                              color: MizanColors.amber300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        const SizedBox(height: 18),

        // Keystore Vault + Routing Params + Live Console
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 860;
          final leftVault = _buildKeyVaultCard(activeMeta, gw);
          final rightConsole = _buildRoutingConsoleCard(gw);
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: leftVault),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: rightConsole),
                  ],
                )
              : Column(
                  children: [
                    leftVault,
                    const SizedBox(height: 18),
                    rightConsole,
                  ],
                );
        }),
      ],
    );
  }

  Widget _buildKeyVaultCard(AIProviderMeta meta, AIGatewayConfig gw) {
    final ctrl = _keyCtrls[meta.id]!;
    final isObscure = _obscure[meta.id] ?? true;

    return MizanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.key,
                  size: 18, color: MizanColors.amber400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${meta.name} Credentials & Model',
                  style:
                      MizanTypography.title(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            meta.description,
            style: MizanTypography.body(
                fontSize: 12, color: MizanColors.slate300),
          ),
          const SizedBox(height: 14),
          if (meta.requiresKey) ...[
            Text(
              'Hardware-Encrypted BYOK API Key',
              style: MizanTypography.body(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: MizanColors.emerald300,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    obscureText: isObscure,
                    style:
                        MizanTypography.code(fontSize: 12, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: meta.keyPlaceholder,
                      hintStyle: MizanTypography.code(
                          fontSize: 12, color: MizanColors.slate500),
                      filled: true,
                      fillColor: MizanColors.bgInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: MizanColors.borderSubtle),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? LucideIcons.eye : LucideIcons.eyeOff,
                          size: 16,
                          color: MizanColors.slate400,
                        ),
                        onPressed: () =>
                            setState(() => _obscure[meta.id] = !isObscure),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MizanColors.amber500,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await ref
                        .read(aiGatewayProvider.notifier)
                        .setApiKey(meta.id, ctrl.text);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: MizanColors.emerald900,
                          content: Text('${meta.name} key saved to Keystore.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Key'),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Model Selector
          Text(
            'Active Model Variant',
            style: MizanTypography.body(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: MizanColors.emerald300,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: gw.models[meta.id] ?? meta.defaultModel,
            dropdownColor: MizanColors.bgCardElevated,
            style: MizanTypography.code(fontSize: 12, color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: MizanColors.bgInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MizanColors.borderSubtle),
              ),
            ),
            items: meta.availableModels
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (m) {
              if (m != null) {
                ref.read(aiGatewayProvider.notifier).setModel(meta.id, m);
              }
            },
          ),
          const SizedBox(height: 14),

          // Temperature Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temperature (${gw.temperature.toStringAsFixed(2)})',
                style: MizanTypography.body(
                    fontSize: 11.5, color: MizanColors.slate200),
              ),
              Text(
                '0.0 Focused · 1.0 Creative',
                style: MizanTypography.code(
                    fontSize: 10, color: MizanColors.slate400),
              ),
            ],
          ),
          Slider(
            value: gw.temperature,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: MizanColors.amber400,
            onChanged: (v) =>
                ref.read(aiGatewayProvider.notifier).setTemperature(v),
          ),

          // Max Tokens Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Output Tokens (${gw.maxTokens})',
                style: MizanTypography.body(
                    fontSize: 11.5, color: MizanColors.slate200),
              ),
              Text(
                '256 – 2048',
                style: MizanTypography.code(
                    fontSize: 10, color: MizanColors.slate400),
              ),
            ],
          ),
          Slider(
            value: gw.maxTokens.toDouble(),
            min: 256,
            max: 2048,
            divisions: 7,
            activeColor: MizanColors.emerald400,
            onChanged: (v) =>
                ref.read(aiGatewayProvider.notifier).setMaxTokens(v.round()),
          ),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Auto-Fallback to Offline Hadith Matrix',
              style: MizanTypography.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            subtitle: Text(
              'Guarantees core reflection works even in Airplane Mode.',
              style: MizanTypography.body(
                  fontSize: 10.5, color: MizanColors.slate400),
            ),
            value: gw.fallbackToOffline,
            activeColor: MizanColors.emerald400,
            onChanged: (v) =>
                ref.read(aiGatewayProvider.notifier).setFallbackToOffline(v),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingConsoleCard(AIGatewayConfig gw) {
    return MizanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.terminal,
                      size: 18, color: MizanColors.emerald400),
                  const SizedBox(width: 8),
                  Text(
                    'Live Gateway Routing Console',
                    style: MizanTypography.title(
                        fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              MizanBadge(
                label: '${gw.activeProvider.name} · ${gw.activeModel}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _consoleCtrl,
            maxLines: 3,
            style: MizanTypography.body(fontSize: 12.5, color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: MizanColors.bgInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: MizanColors.borderSubtle),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MizanIconButton(
                label: _testingRoute
                    ? 'Routing Prompt...'
                    : 'Execute Coaching Route',
                icon: LucideIcons.play,
                onPressed: _testingRoute ? null : _testRoute,
              ),
              TextButton.icon(
                onPressed: () => jumpToSourceFile(
                    ref, 'lib/core/services/ai_gateway_service.dart'),
                icon: const Icon(LucideIcons.code2,
                    size: 14, color: MizanColors.emerald300),
                label: Text(
                  'View Dart Repository',
                  style: MizanTypography.code(
                      fontSize: 11, color: MizanColors.emerald300),
                ),
              ),
            ],
          ),
          if (_consoleError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x33F43F5E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MizanColors.rose400),
              ),
              child: Text(
                _consoleError!,
                style: MizanTypography.code(
                    fontSize: 11, color: MizanColors.rose400),
              ),
            ),
          ],
          if (_consoleResponse != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MizanColors.bgInput,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MizanColors.borderEmerald),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Source: ${_consoleResponse!.source}',
                          style: MizanTypography.code(
                            fontSize: 10.5,
                            color: MizanColors.amber300,
                          ),
                        ),
                      ),
                      Text(
                        '${_consoleResponse!.latencyMs}ms',
                        style: MizanTypography.code(
                          fontSize: 10.5,
                          color: MizanColors.emerald400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _consoleResponse!.reply,
                    style: MizanTypography.body(
                      fontSize: 12.5,
                      color: Colors.white,
                      height: 1.45,
                    ),
                  ),
                  if (_consoleResponse!.scripturalAnchor != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MizanColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: MizanColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _consoleResponse!.scripturalAnchor!.textArabic,
                            textDirection: TextDirection.rtl,
                            style: MizanTypography.arabic(
                              fontSize: 16,
                              color: MizanColors.amber300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _consoleResponse!.scripturalAnchor!.translation,
                            style: MizanTypography.body(
                                fontSize: 11, color: MizanColors.slate200),
                          ),
                          Text(
                            _consoleResponse!.scripturalAnchor!.reference,
                            style: MizanTypography.code(
                                fontSize: 10, color: MizanColors.emerald400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

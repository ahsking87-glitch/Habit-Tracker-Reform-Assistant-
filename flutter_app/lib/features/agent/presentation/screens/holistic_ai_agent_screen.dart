import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class HolisticAIAgentScreen extends ConsumerStatefulWidget {
  const HolisticAIAgentScreen({super.key});

  @override
  ConsumerState<HolisticAIAgentScreen> createState() =>
      _HolisticAIAgentScreenState();
}

class _HolisticAIAgentScreenState extends ConsumerState<HolisticAIAgentScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;

  static const _quickTriggers = [
    'How can I prevent afternoon burnout while keeping my work quality high?',
    'I feel pulled to scroll Reels right before Asr. Help me pause.',
    'Connect my creative software projects with Islamic Niyyah.',
    'Give me an authentic Hadith on steady daily consistency.',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send([String? override]) async {
    final text = (override ?? _inputCtrl.text).trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    if (override == null) _inputCtrl.clear();

    await ref.read(agentChatProvider.notifier).sendMessage(text);
    if (!mounted) return;
    setState(() => _sending = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(agentChatProvider);
    final gw = ref.watch(aiGatewayProvider);
    final prayer = ref.watch(prayerCalculationProvider);
    final streaks = ref.watch(streaksProvider);
    final goals = ref.watch(personalGoalsProvider);
    final shield = ref.watch(shieldProvider);
    final user = ref.watch(userProfileProvider);

    final screenSize = MediaQuery.of(context).size;
    final chatHeight = (screenSize.height * 0.48).clamp(280.0, 520.0);
    final bubbleMaxWidth = (screenSize.width * 0.76).clamp(240.0, 560.0);

    final chatArea = MizanCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MizanColors.amber500.withAlpha(38),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: MizanColors.amber400.withAlpha(115)),
                ),
                child: const Icon(Icons.smart_toy_outlined,
                    size: 22, color: MizanColors.amber300),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Al-Murshid (المرشد) · 24/7 Holistic Life Mentor',
                      style: MizanTypography.title(
                          fontSize: 17, color: Colors.white),
                    ),
                    Text(
                      'Zero guilt/shame · Grounded in Quran & Sahih Hadith · Routed via ${gw.activeProvider.name} (${gw.activeModel})',
                      style: MizanTypography.code(
                          fontSize: 10.5, color: MizanColors.emerald300),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => ref.read(coachSubViewProvider.notifier).state =
                    CoachSubView.gateway,
                child: Text(
                  'Switch Model →',
                  style: MizanTypography.body(
                      fontSize: 11.5, color: MizanColors.amber300),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: chatHeight,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MizanColors.bgInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MizanColors.borderSubtle),
            ),
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: msgs.length + (_sending ? 1 : 0),
              itemBuilder: (_, idx) {
                if (idx == msgs.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Al-Murshid is reflecting with authentic sources...',
                      style: MizanTypography.body(
                          fontSize: 12, color: MizanColors.amber300),
                    ),
                  );
                }
                final m = msgs[idx];
                final isUser = m.sender == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                    decoration: BoxDecoration(
                      color: isUser
                          ? MizanColors.emerald800
                          : MizanColors.bgCardElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: isUser
                          ? null
                          : Border.all(color: MizanColors.borderEmerald),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: MizanTypography.body(
                            fontSize: 12.5,
                            color: Colors.white,
                            height: 1.45,
                          ),
                        ),
                        if (m.scripturalAnchor != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: MizanColors.bgDeep,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: MizanColors.amber400.withAlpha(102)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  m.scripturalAnchor!.textArabic,
                                  textDirection: TextDirection.rtl,
                                  style: MizanTypography.arabic(
                                    fontSize: 17,
                                    color: MizanColors.amber300,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.scripturalAnchor!.translation,
                                  style: MizanTypography.body(
                                    fontSize: 11.5,
                                    color: MizanColors.slate200,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  m.scripturalAnchor!.reference,
                                  style: MizanTypography.code(
                                    fontSize: 10,
                                    color: MizanColors.emerald400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (m.suggestedActions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: m.suggestedActions
                                .map((a) => ActionChip(
                                      backgroundColor: MizanColors.bgCard,
                                      side: const BorderSide(
                                          color: MizanColors.borderEmerald),
                                      label: Text(
                                        a,
                                        style: MizanTypography.body(
                                          fontSize: 10.5,
                                          color: MizanColors.amber300,
                                        ),
                                      ),
                                      onPressed: () => _send(a),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickTriggers
                .map((q) => ActionChip(
                      backgroundColor: MizanColors.bgCardAlt,
                      side: const BorderSide(color: MizanColors.borderSubtle),
                      label: Text(
                        q,
                        style: MizanTypography.body(
                            fontSize: 10.5, color: MizanColors.emerald300),
                      ),
                      onPressed: () => _send(q),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  onSubmitted: (_) => _send(),
                  style:
                      MizanTypography.body(fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        'Share work pressure, distraction trigger, or spiritual question...',
                    hintStyle: MizanTypography.body(
                        fontSize: 12, color: MizanColors.slate500),
                    filled: true,
                    fillColor: MizanColors.bgInput,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: MizanColors.borderSubtle),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MizanColors.amber500,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _sending ? null : () => _send(),
                icon: const Icon(LucideIcons.send, size: 16),
                label: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );

    final activeGoalsText = goals
        .where((g) => !g.isPaused && !g.isCompleted)
        .take(3)
        .map((g) => '${g.title} (${g.progressPercent}% · ${g.scheduledTime})')
        .join('\n');

    final contextSidebar = MizanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.radio,
                  size: 17, color: MizanColors.amber400),
              const SizedBox(width: 8),
              Text(
                'Live Holistic Context Injected',
                style: MizanTypography.title(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ctxRow(
            'Upcoming Prayer',
            '${prayer.nextPrayer.name} (${prayer.nextPrayer.time12}) · in ${prayer.countdownString}',
          ),
          _ctxRow(
            'Top Habit Streaks',
            streaks.sunnahs
                .take(3)
                .map((s) => '${s.title} (${s.streakDays}d)')
                .join('\n'),
          ),
          _ctxRow(
            'Personal Goals',
            activeGoalsText.isEmpty
                ? 'No active goals yet (add inside 24h tab)'
                : activeGoalsText,
          ),
          _ctxRow(
            'Digital Shield',
            '${shield.dailyMinutesUsed}m / ${shield.dailyLimitMinutes}m · ${shield.blockedReelsCount} Reels paused',
          ),
          _ctxRow(
            'Active Niyyah Goal',
            user?.spiritualGoal ?? 'Daily consistency with Ihsan',
          ),
          _ctxRow(
            'AI Gateway Route',
            '${gw.activeProvider.name.toUpperCase()} · ${gw.activeModel}',
          ),
        ],
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 920) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: chatArea),
            const SizedBox(width: 18),
            Expanded(flex: 4, child: contextSidebar),
          ],
        );
      }
      return Column(
        children: [
          chatArea,
          const SizedBox(height: 18),
          contextSidebar,
        ],
      );
    });
  }

  Widget _ctxRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: MizanColors.bgCardAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MizanColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style:
                MizanTypography.code(fontSize: 9.5, color: MizanColors.amber300),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: MizanTypography.body(fontSize: 11.5, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/onboarding_data.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/ai_gateway_service.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../shield/presentation/widgets/prominent_disclosure_dialog.dart';

class _QaMessage {
  final String id;
  final bool isUser;
  final String text;
  final AppTab? targetFeature;
  final String? targetSubView;
  final String? actionTip;
  final List<String> followUps;
  final String? source;

  const _QaMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.targetFeature,
    this.targetSubView,
    this.actionTip,
    this.followUps = const [],
    this.source,
  });
}

class OnboardingAssistantDialog extends ConsumerStatefulWidget {
  const OnboardingAssistantDialog({super.key});

  @override
  ConsumerState<OnboardingAssistantDialog> createState() =>
      _OnboardingAssistantDialogState();
}

class _OnboardingAssistantDialogState
    extends ConsumerState<OnboardingAssistantDialog> {
  late String _mode;
  bool _syncBg = true;
  bool _isAsking = false;
  final TextEditingController _queryCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();

  final List<_QaMessage> _chatLog = [
    const _QaMessage(
      id: 'welcome',
      isUser: false,
      text:
          'As-salamu alaykum! I am your interactive onboarding guide. Ask me anything about how Mīzān works—from navigating the workspace, logging daily Micro-Sunnahs, and using Istighfar Grace Days, to configuring the Multi-AI Gateway (Gemini, OpenAI, Claude, DeepSeek).',
      actionTip: 'Select a question below or type your own.',
      followUps: [
        'How do I log a daily habit or Sunnah?',
        'How do I navigate between features?',
        'How do I set up the Multi-AI Gateway?',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mode = ref.read(onboardingInitialViewProvider);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  Future<void> _askQuestion([String? overrideText]) async {
    final text = (overrideText ?? _queryCtrl.text).trim();
    if (text.isEmpty || _isAsking) return;

    final stepIdx = ref.read(onboardingStepIndexProvider);
    final currentStep = defaultOnboardingSteps[stepIdx];
    final gw = ref.read(aiGatewayProvider);

    setState(() {
      _chatLog.add(_QaMessage(
        id: 'u_${DateTime.now().millisecondsSinceEpoch}',
        isUser: true,
        text: text,
      ));
      if (overrideText == null) _queryCtrl.clear();
      _isAsking = true;
    });

    final resp = await AIGatewayService.instance.askOnboardingAssistant(
      gateway: gw,
      question: text,
      currentStep: currentStep.title,
    );

    if (!mounted) return;
    setState(() {
      _chatLog.add(_QaMessage(
        id: 'a_${DateTime.now().millisecondsSinceEpoch}',
        isUser: false,
        text: resp.answer,
        targetFeature: resp.targetFeature,
        targetSubView: resp.targetSubView,
        actionTip: resp.actionTip,
        followUps: resp.suggestedFollowUps,
        source: resp.source,
      ));
      _isAsking = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goToStep(int nextIdx) {
    final steps = defaultOnboardingSteps;
    final prevIdx = ref.read(onboardingStepIndexProvider);
    final completed = Set<String>.from(
        ref.read(onboardingStepsCompletedProvider))
      ..add(steps[prevIdx].id);
    ref.read(onboardingStepsCompletedProvider.notifier).state = completed;
    ref.read(onboardingStepIndexProvider.notifier).state = nextIdx;
    if (_syncBg) {
      navigateToFeature(
        ref,
        steps[nextIdx].targetView,
        subView: steps[nextIdx].targetSubView,
      );
    }
  }

  void _jumpToTab(AppTab tab, {String? subView}) {
    navigateToFeature(ref, tab, subView: subView);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final stepIdx = ref.watch(onboardingStepIndexProvider);
    final completedSteps = ref.watch(onboardingStepsCompletedProvider);
    final step = defaultOnboardingSteps[stepIdx];
    final gw = ref.watch(aiGatewayProvider);
    const icons = ['🕋', '🛡️', '🔥', '✨', '📖', '⚡'];

    final screenSize = MediaQuery.of(context).size;
    final dialogMaxWidth =
        screenSize.width > 740 ? 680.0 : screenSize.width * 0.94;
    final dialogMaxHeight = (screenSize.height * 0.86).clamp(420.0, 760.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      backgroundColor: MizanColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: MizanColors.borderEmerald),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF07201A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(color: MizanColors.borderSubtle),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [MizanColors.amber500, MizanColors.emerald600],
                      ),
                    ),
                    child: const Icon(Icons.smart_toy_outlined,
                        size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Interactive Onboarding Assistant',
                              style: MizanTypography.title(
                                fontSize: 15.5,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: MizanColors.amber500.withAlpha(51),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: MizanColors.amber400.withAlpha(128)),
                              ),
                              child: Text(
                                'Al-Murshid Guide',
                                style: MizanTypography.code(
                                  fontSize: 10,
                                  color: MizanColors.amber300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Guided navigation, habit logging tutorial & live Q&A',
                          style: MizanTypography.body(
                            fontSize: 11,
                            color: MizanColors.emerald300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x,
                        size: 18, color: MizanColors.slate400),
                  ),
                ],
              ),
            ),

            // Mode Tabs
            Container(
              width: double.infinity,
              color: const Color(0xFF051511),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _modeTab(
                      label:
                          'Guided Tour (${stepIdx + 1}/${defaultOnboardingSteps.length})',
                      icon: LucideIcons.compass,
                      active: _mode == 'tour',
                      onTap: () => setState(() => _mode = 'tour'),
                    ),
                    const SizedBox(width: 8),
                    _modeTab(
                      label: 'Ask Al-Murshid Q&A',
                      icon: LucideIcons.messageSquare,
                      active: _mode == 'qa',
                      onTap: () => setState(() => _mode = 'qa'),
                    ),
                    if (_mode == 'tour') ...[
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _syncBg,
                            activeColor: MizanColors.amber400,
                            onChanged: (v) =>
                                setState(() => _syncBg = v ?? true),
                          ),
                          Text(
                            'Auto-sync view',
                            style: MizanTypography.body(
                              fontSize: 11,
                              color: MizanColors.emerald300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: _mode == 'tour'
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'STEP ${stepIdx + 1} OF ${defaultOnboardingSteps.length}',
                                style: MizanTypography.code(
                                  fontSize: 11,
                                  color: MizanColors.emerald300,
                                ),
                              ),
                              Text(
                                step.title,
                                style: MizanTypography.body(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: MizanColors.amber300,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(
                              defaultOnboardingSteps.length,
                              (i) => Expanded(
                                child: Container(
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: i <= stepIdx
                                        ? MizanColors.amber400
                                        : MizanColors.emerald900,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF07241D),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: MizanColors.borderEmerald),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'FEATURE SPOTLIGHT',
                                            style: MizanTypography.code(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: MizanColors.amber300,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            step.title,
                                            style: MizanTypography.title(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            step.subtitle,
                                            style: MizanTypography.body(
                                              fontSize: 12,
                                              color: MizanColors.emerald300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: MizanColors.borderEmerald),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(icons[stepIdx],
                                          style: const TextStyle(fontSize: 20)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  step.explanation,
                                  style: MizanTypography.body(
                                    fontSize: 12.5,
                                    color: MizanColors.slate200,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: MizanColors.borderSubtle),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Ready to try this in the app?',
                                      style: MizanTypography.body(
                                        fontSize: 11,
                                        color: MizanColors.emerald300,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (step.targetFeature ==
                                            'accessibility_shield') ...[
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              showDialog<void>(
                                                context: context,
                                                builder: (_) =>
                                                    const ProminentDisclosureDialog(),
                                              );
                                            },
                                            icon: const Icon(
                                                LucideIcons.shield,
                                                size: 13,
                                                color: MizanColors.amber400),
                                            label: Text(
                                              'Accessibility Disclosure',
                                              style: MizanTypography.body(
                                                fontSize: 11,
                                                color: MizanColors.slate100,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                MizanColors.amber500,
                                            foregroundColor: Colors.black,
                                          ),
                                          onPressed: () => _jumpToTab(
                                            step.targetView,
                                            subView: step.targetSubView,
                                          ),
                                          icon: Text(
                                            step.actionLabel,
                                            style: MizanTypography.body(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          label: const Icon(
                                              LucideIcons.externalLink,
                                              size: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: stepIdx == 0
                                    ? null
                                    : () => _goToStep(stepIdx - 1),
                                icon:
                                    const Icon(LucideIcons.chevronLeft, size: 15),
                                label: const Text('Previous'),
                              ),
                              Row(
                                children: List.generate(
                                  defaultOnboardingSteps.length,
                                  (i) => GestureDetector(
                                    onTap: () => _goToStep(i),
                                    child: Container(
                                      width: i == stepIdx ? 12 : 9,
                                      height: i == stepIdx ? 12 : 9,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i == stepIdx
                                            ? MizanColors.amber400
                                            : completedSteps.contains(
                                                    defaultOnboardingSteps[i]
                                                        .id)
                                                ? MizanColors.emerald500
                                                : MizanColors.emerald900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (stepIdx < defaultOnboardingSteps.length - 1)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MizanColors.emerald700,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _goToStep(stepIdx + 1),
                                  icon: const Text('Next Pillar'),
                                  label: const Icon(LucideIcons.chevronRight,
                                      size: 15),
                                )
                              else
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MizanColors.amber400,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    dismissOnboardingBanner(ref);
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(LucideIcons.checkCircle2,
                                      size: 15),
                                  label: const Text('Complete Tour!'),
                                ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gateway Route: ${gw.activeProvider.name} · ${gw.activeModel}',
                                style: MizanTypography.code(
                                  fontSize: 10.5,
                                  color: MizanColors.amber300,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _jumpToTab(
                                  AppTab.coach,
                                  subView: 'gateway',
                                ),
                                child: Text(
                                  'Switch AI Provider',
                                  style: MizanTypography.body(
                                    fontSize: 11,
                                    color: MizanColors.amber300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: appHelpTopics.take(4).map((t) {
                              return ActionChip(
                                backgroundColor: const Color(0xFF07241D),
                                side: const BorderSide(
                                    color: MizanColors.borderEmerald),
                                label: Text(
                                  t.question,
                                  style: MizanTypography.body(
                                    fontSize: 10.5,
                                    color: MizanColors.emerald300,
                                  ),
                                ),
                                onPressed: () => _askQuestion(t.question),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: (screenSize.height * 0.30)
                                .clamp(180.0, 320.0),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: MizanColors.bgInput,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: MizanColors.borderSubtle),
                            ),
                            child: ListView.builder(
                              controller: _chatScroll,
                              itemCount:
                                  _chatLog.length + (_isAsking ? 1 : 0),
                              itemBuilder: (context, idx) {
                                if (idx == _chatLog.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Al-Murshid is composing guidance...',
                                      style: MizanTypography.body(
                                        fontSize: 11,
                                        color: MizanColors.amber300,
                                      ),
                                    ),
                                  );
                                }
                                final msg = _chatLog[idx];
                                return Align(
                                  alignment: msg.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    constraints: BoxConstraints(
                                      maxWidth: (screenSize.width * 0.72)
                                          .clamp(220.0, 460.0),
                                    ),
                                    decoration: BoxDecoration(
                                      color: msg.isUser
                                          ? MizanColors.emerald800
                                          : const Color(0xFF07251E),
                                      borderRadius: BorderRadius.circular(14),
                                      border: msg.isUser
                                          ? null
                                          : Border.all(
                                              color: MizanColors.borderEmerald),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg.text,
                                          style: MizanTypography.body(
                                            fontSize: 11.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (msg.actionTip != null) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            '💡 ${msg.actionTip}',
                                            style: MizanTypography.body(
                                              fontSize: 10,
                                              color: MizanColors.amber300,
                                            ),
                                          ),
                                        ],
                                        if (msg.targetFeature != null) ...[
                                          const SizedBox(height: 6),
                                          TextButton.icon(
                                            onPressed: () => _jumpToTab(
                                              msg.targetFeature!,
                                              subView: msg.targetSubView,
                                            ),
                                            icon: const Icon(
                                                LucideIcons.arrowRight,
                                                size: 12),
                                            label: Text(
                                              'Jump to ${msg.targetFeature!.name}',
                                              style: MizanTypography.body(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: MizanColors.amber300,
                                              ),
                                            ),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _queryCtrl,
                                  onSubmitted: (_) => _askQuestion(),
                                  style: MizanTypography.body(
                                      fontSize: 12, color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Ask any question about navigation, logging habits, or AI setup...',
                                    hintStyle: MizanTypography.body(
                                      fontSize: 11.5,
                                      color: MizanColors.slate500,
                                    ),
                                    filled: true,
                                    fillColor: MizanColors.bgInput,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: MizanColors.borderSubtle),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MizanColors.amber500,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.all(13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _askQuestion(),
                                child: const Icon(LucideIcons.send, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeTab({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF061E18) : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border(
            bottom: BorderSide(
              color: active ? MizanColors.amber400 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: active ? MizanColors.amber300 : MizanColors.emerald300,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: MizanTypography.body(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: active ? MizanColors.amber300 : MizanColors.emerald300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

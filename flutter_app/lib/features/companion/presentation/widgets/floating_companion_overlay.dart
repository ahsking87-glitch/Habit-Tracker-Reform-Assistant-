import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';

class FloatingCompanionOverlay extends ConsumerStatefulWidget {
  final double? boundsWidth;
  final double? boundsHeight;
  final String nextSalahName;
  final int nextSalahMinutes;

  const FloatingCompanionOverlay({
    super.key,
    this.boundsWidth,
    this.boundsHeight,
    required this.nextSalahName,
    required this.nextSalahMinutes,
  });

  @override
  ConsumerState<FloatingCompanionOverlay> createState() =>
      _FloatingCompanionOverlayState();
}

class _FloatingCompanionOverlayState
    extends ConsumerState<FloatingCompanionOverlay>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPinned = false;
  bool _showPetHeart = false;
  int _petCount = 0;
  int _energy = 88;
  ({String title, String body})? _alertCard;

  late final AnimationController _pulseCtrl;

  static const Map<AppTab, ({String title, String tip})> _tabCopy = {
    AppTab.salah: (
      title: 'Salah & Sunnah Anchor',
      tip:
          'Your solar prayer timetable & habit streaks stay 100% offline. Tap Assist anytime for setup help.',
    ),
    AppTab.shield: (
      title: 'Mindful Shield Active',
      tip:
          'Prominent Accessibility disclosure keeps Reels & Shorts paused calmly without guilt.',
    ),
    AppTab.quran: (
      title: 'Trilingual Quran & Sunnah',
      tip:
          'Search Uthmani Arabic, English & বাংলা offline anytime with bookmarks and Micro-Sunnah guidance.',
    ),
    AppTab.planner: (
      title: 'Goals & 24h Barakah',
      tip:
          'Create & schedule custom learning or task goals with visual progress metrics linked to solar prayer windows.',
    ),
    AppTab.coach: (
      title: 'Al-Murshid & Multi-AI',
      tip:
          'Chat with Al-Murshid, manage your BYOK AI keys, or customize Nūr chimes right inside Coach.',
    ),
    AppTab.profile: (
      title: 'Sovereign Vault & Ethics',
      tip:
          'Manage your offline identity, Ed25519 peer ledger, and ethical governance settings.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTapPet() {
    ref.read(companionProvider.notifier).tapReact();
    setState(() {
      _petCount++;
      _energy = (_energy + 2).clamp(0, 100);
      _showPetHeart = true;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showPetHeart = false);
    });
  }

  String _skinEmoji(CompanionSkin skin) {
    switch (skin) {
      case CompanionSkin.lantern:
        return '🏮';
      case CompanionSkin.crescent:
        return '🌙';
      case CompanionSkin.astrolabe:
        return '۞';
      case CompanionSkin.lotus:
        return '🪷';
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = ref.watch(companionProvider);
    final activeTab = ref.watch(appTabProvider);
    final gw = ref.watch(aiGatewayProvider);

    if (!comp.isEnabled) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.of(context).size;
        final boundsWidth = widget.boundsWidth ??
            (constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : mediaSize.width);
        final boundsHeight = widget.boundsHeight ??
            (constraints.hasBoundedHeight && constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : mediaSize.height);

        final maxLeft = (boundsWidth - comp.sizePx - 10.0).clamp(10.0, 9999.0);
        final maxTop = (boundsHeight - comp.sizePx - 18.0).clamp(18.0, 9999.0);
        final orbLeft =
            (comp.posX * boundsWidth - comp.sizePx / 2).clamp(10.0, maxLeft);
        final orbTop =
            (comp.posY * boundsHeight - comp.sizePx / 2).clamp(18.0, maxTop);

        final showCard = !comp.isHiding && (_isHovered || _isPinned);
        final alignRight = comp.posX > 0.52;
        final openBelow = comp.posY < 0.45;
        final copy = _tabCopy[activeTab]!;
        final cardMaxOffset = (boundsWidth - 236).clamp(8.0, 9999.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Bounded Draggable Companion Orb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              left: orbLeft,
              top: orbTop,
              child: MouseRegion(
                onEnter: (_) {
                  if (!comp.isHiding) setState(() => _isHovered = true);
                },
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: _onTapPet,
                  onSecondaryTap: () => setState(() => _isPinned = !_isPinned),
                  onLongPress: () => setState(() => _isPinned = !_isPinned),
                  onPanUpdate: (details) {
                    final nx = comp.posX + details.delta.dx / boundsWidth;
                    final ny = comp.posY + details.delta.dy / boundsHeight;
                    ref.read(companionProvider.notifier).setPosition(nx, ny);
                  },
                  onPanEnd: (_) {
                    ref.read(companionProvider.notifier).snapToNearestEdge();
                  },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: comp.isHiding ? 0.48 : 1.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showPetHeart)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Icon(
                          LucideIcons.heart,
                          size: 13,
                          color: MizanColors.amber400,
                        ),
                      ),
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, child) {
                        final glow = 4.0 + (_pulseCtrl.value * 8.0);
                        return Container(
                          width: comp.sizePx,
                          height: comp.sizePx,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: comp.mood == CompanionMood.salahLead
                                ? const Color(0xE61C230F)
                                : const Color(0xE607241D),
                            border: Border.all(
                              color: comp.mood == CompanionMood.salahLead
                                  ? MizanColors.amber400
                                  : MizanColors.emerald500,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: comp.mood == CompanionMood.salahLead
                                    ? MizanColors.amber400.withAlpha(115)
                                    : MizanColors.emerald400.withAlpha(89),
                                blurRadius: glow,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _skinEmoji(comp.skin),
                            style: TextStyle(fontSize: comp.sizePx * 0.42),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Hover / Pinned Assistant Card
        if (showCard)
          Positioned(
            left: alignRight ? null : orbLeft.clamp(8.0, cardMaxOffset),
            right: alignRight
                ? (boundsWidth - (orbLeft + comp.sizePx))
                    .clamp(8.0, cardMaxOffset)
                : null,
            top: openBelow ? orbTop + comp.sizePx + 8 : null,
            bottom: openBelow ? null : (boundsHeight - orbTop) + 8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 224,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xF5061D17),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MizanColors.amber400.withAlpha(128)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.sparkles,
                            size: 13, color: MizanColors.amber400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            copy.title,
                            overflow: TextOverflow.ellipsis,
                            style: MizanTypography.body(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: MizanColors.amber300,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isPinned = false;
                            _isHovered = false;
                          }),
                          child: const Icon(LucideIcons.x,
                              size: 13, color: MizanColors.slate400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.tip,
                      style: MizanTypography.body(
                        fontSize: 10,
                        color: MizanColors.emerald300.withAlpha(230),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041410),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: MizanColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AI Route:',
                            style: MizanTypography.code(
                              fontSize: 9,
                              color: MizanColors.emerald400,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${gw.activeProvider.name} · ${gw.activeModel}',
                              overflow: TextOverflow.ellipsis,
                              style: MizanTypography.code(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: MizanColors.amber300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _miniBtn(
                            label: 'Guide Tour',
                            icon: LucideIcons.helpCircle,
                            bg: MizanColors.amber500.withAlpha(51),
                            border: MizanColors.amber400.withAlpha(115),
                            fg: MizanColors.amber300,
                            onTap: () {
                              setState(() {
                                _isPinned = false;
                                _isHovered = false;
                              });
                              openGuidedTour(ref, view: 'tour');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _miniBtn(
                            label: 'AI Keys',
                            icon: LucideIcons.cpu,
                            bg: MizanColors.emerald900,
                            border: MizanColors.borderEmerald,
                            fg: MizanColors.emerald300,
                            onTap: () {
                              setState(() {
                                _isPinned = false;
                                _isHovered = false;
                              });
                              navigateToFeature(
                                ref,
                                AppTab.coach,
                                subView: 'gateway',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _miniBtn(
                      label: 'Open Mindful AI Coach',
                      icon: Icons.smart_toy_outlined,
                      bg: const Color(0xFF0A2B22),
                      border: MizanColors.borderEmerald,
                      fg: Colors.white,
                      onTap: () {
                        setState(() {
                          _isPinned = false;
                          _isHovered = false;
                        });
                        navigateToFeature(
                          ref,
                          AppTab.coach,
                          subView: 'chat',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Proactive Alert Bubble when triggered
        if (_alertCard != null && !showCard && !comp.isHiding)
          Positioned(
            left: 16,
            top: orbTop > 120 ? orbTop - 76 : orbTop + comp.sizePx + 10,
            child: Container(
              width: 210,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xF5061D17),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MizanColors.emerald500.withAlpha(179)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles,
                          size: 12, color: MizanColors.amber400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _alertCard!.title,
                          style: MizanTypography.body(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MizanColors.amber300,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _alertCard = null),
                        child: const Icon(LucideIcons.x,
                            size: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _alertCard!.body,
                    style: MizanTypography.body(
                      fontSize: 10,
                      color: MizanColors.slate200,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Compact Chassis Control Bar docked at bottom inside simulator
        Positioned(
          left: 10,
          right: 10,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xE0061E18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MizanColors.borderEmerald),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [MizanColors.amber400, MizanColors.emerald600],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(_skinEmoji(comp.skin),
                      style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Nūr · نور',
                        overflow: TextOverflow.ellipsis,
                        style: MizanTypography.body(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        comp.isHiding
                            ? 'Hiding at edge'
                            : '$_energy% · $_petCount pets · ${gw.activeProvider.name}',
                        overflow: TextOverflow.ellipsis,
                        style: MizanTypography.body(
                          fontSize: 9,
                          color: MizanColors.emerald300,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isPinned = !_isPinned),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isPinned
                          ? MizanColors.amber500.withAlpha(64)
                          : MizanColors.bgDeep,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isPinned
                            ? MizanColors.amber400
                            : MizanColors.borderEmerald,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.helpCircle,
                          size: 11,
                          color: _isPinned
                              ? MizanColors.amber300
                              : MizanColors.emerald300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Assist',
                          style: MizanTypography.body(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _isPinned
                                ? MizanColors.amber300
                                : MizanColors.emerald300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _chassisIconBtn(
                  icon: LucideIcons.clock,
                  color: MizanColors.amber300,
                  onTap: () {
                    ref.read(companionProvider.notifier).triggerSalah10mAlert();
                    setState(() {
                      _alertCard = (
                        title: '10m until ${widget.nextSalahName}',
                        body:
                            '432Hz Salah chime triggered. Time to wind down screens calmly.',
                      );
                    });
                  },
                ),
                const SizedBox(width: 4),
                _chassisIconBtn(
                  icon: LucideIcons.shield,
                  color: MizanColors.rose400,
                  onTap: () {
                    ref
                        .read(companionProvider.notifier)
                        .triggerScreenLimitAlert();
                    setState(() {
                      _alertCard = const (
                        title: 'Mindful Breathing Intermission',
                        body:
                            'Short-form video loop noticed. Take 7 seconds of calm dhikr.',
                      );
                    });
                  },
                ),
                const SizedBox(width: 4),
                _chassisIconBtn(
                  icon: comp.isHiding ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: MizanColors.emerald300,
                  onTap: () =>
                      ref.read(companionProvider.notifier).togglePeekABoo(),
                ),
                const SizedBox(width: 4),
                _chassisIconBtn(
                  icon: comp.soundEnabled
                      ? LucideIcons.volume2
                      : LucideIcons.volumeX,
                  color: MizanColors.emerald300,
                  onTap: () => ref
                      .read(companionProvider.notifier)
                      .setSoundEnabled(!comp.soundEnabled),
                ),
              ],
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  Widget _chassisIconBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: MizanColors.bgDeep,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: MizanColors.borderEmerald),
        ),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }

  Widget _miniBtn({
    required String label,
    required IconData icon,
    required Color bg,
    required Color border,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: MizanTypography.body(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

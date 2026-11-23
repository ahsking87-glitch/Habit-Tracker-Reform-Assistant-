import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/mizan_models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/adhan_prayer_service.dart';
import '../../../core/services/ai_gateway_service.dart';
import '../../../core/theme/mizan_theme.dart';
import '../../../core/widgets/mizan_ui_kit.dart';
import '../../agent/presentation/screens/holistic_ai_agent_screen.dart';
import '../../architecture/presentation/screens/system_architecture_diagram_screen.dart';
import '../../companion/presentation/screens/interactive_companion_screen.dart';
import '../../constitution/presentation/screens/ethical_constitution_screen.dart';
import '../../explorer/presentation/screens/architecture_explorer_screen.dart';
import '../../gateway/presentation/screens/multi_ai_gateway_screen.dart';
import '../../goals/presentation/screens/personal_goals_screen.dart';
import '../../onboarding/presentation/widgets/onboarding_assistant_dialog.dart';
import '../../profile/presentation/screens/profile_auth_screen.dart';
import '../../shield/presentation/widgets/prominent_disclosure_dialog.dart';
import '../../streaks/presentation/screens/streaks_and_rewards_screen.dart';

/// Reusable responsive pill segmented control used inside unified bottom tabs.
class _SubViewBar<T> extends StatelessWidget {
  final List<({T value, String label, IconData icon})> items;
  final T active;
  final ValueChanged<T> onChanged;
  final Widget? trailing;

  const _SubViewBar({
    required this.items,
    required this.active,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                final selected = item.value == active;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => onChanged(item.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? MizanColors.amber500
                            : MizanColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? MizanColors.amber400
                              : MizanColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 13.5,
                            color: selected
                                ? Colors.black
                                : MizanColors.emerald300,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: MizanTypography.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.black
                                  : MizanColors.emerald300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

/// 1. SALAH HUB: Offline Astronomical Prayer Engine + Micro-Sunnahs + Streaks
class SalahHubView extends ConsumerWidget {
  const SalahHubView({super.key});

  void _openTour(BuildContext context, WidgetRef ref, {String view = 'tour'}) {
    ref.read(onboardingInitialViewProvider.notifier).state = view;
    showDialog<void>(
      context: context,
      builder: (_) => const OnboardingAssistantDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subView = ref.watch(salahSubViewProvider);
    final settings = ref.watch(prayerSettingsProvider);
    final prayerCalc = ref.watch(prayerCalculationProvider);
    final streaks = ref.watch(streaksProvider);
    final bannerDismissed = ref.watch(onboardingBannerDismissedProvider);
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 420 ? 12.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 72),
      children: [
        if (!bannerDismissed) _buildOnboardingCard(context, ref),
        _SubViewBar<SalahSubView>(
          active: subView,
          onChanged: (v) => ref.read(salahSubViewProvider.notifier).state = v,
          items: const [
            (
              value: SalahSubView.prayer,
              label: 'Salah & Sunnah',
              icon: LucideIcons.compass,
            ),
            (
              value: SalahSubView.streaks,
              label: 'Streaks & Badges',
              icon: LucideIcons.flame,
            ),
          ],
          trailing: InkWell(
            onTap: () => _openTour(context, ref),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: MizanColors.amber500.withAlpha(38),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: MizanColors.amber400.withAlpha(115)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.helpCircle,
                      size: 13, color: MizanColors.amber300),
                  const SizedBox(width: 4),
                  Text(
                    'Tour',
                    style: MizanTypography.code(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: MizanColors.amber300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (subView == SalahSubView.streaks)
          const StreaksAndRewardsScreen()
        else ...[
          // Location, Calculation Method & Qibla Card
          MizanCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 15, color: MizanColors.amber400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CityLocation>(
                          value: settings.city,
                          dropdownColor: MizanColors.bgCardElevated,
                          isDense: true,
                          style: MizanTypography.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                          items: AdhanPrayerService.presetCities
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text('${c.name}, ${c.country}'),
                                  ))
                              .toList(),
                          onChanged: (c) {
                            if (c != null) {
                              ref
                                  .read(prayerSettingsProvider.notifier)
                                  .setCity(c);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: MizanColors.emerald950,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: MizanColors.borderEmerald),
                      ),
                      child: Text(
                        'Qibla ${prayerCalc.qiblaBearing.toInt()}°',
                        style: MizanTypography.code(
                          fontSize: 10.5,
                          color: MizanColors.amber300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 520;
                  final methodDropdown = DropdownButtonFormField<CalculationMethod>(
                    value: settings.method,
                    dropdownColor: MizanColors.bgCardElevated,
                    style:
                        MizanTypography.body(fontSize: 11.5, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Calculation Method',
                      labelStyle: MizanTypography.body(
                          fontSize: 10.5, color: MizanColors.emerald300),
                      isDense: true,
                      filled: true,
                      fillColor: MizanColors.bgInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: MizanColors.borderSubtle),
                      ),
                    ),
                    items: CalculationMethod.values
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.name.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (m) {
                      if (m != null) {
                        ref.read(prayerSettingsProvider.notifier).setMethod(m);
                      }
                    },
                  );
                  final madhabDropdown = DropdownButtonFormField<AsrMethod>(
                    value: settings.madhab,
                    dropdownColor: MizanColors.bgCardElevated,
                    style:
                        MizanTypography.body(fontSize: 11.5, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Asr Juristic School',
                      labelStyle: MizanTypography.body(
                          fontSize: 10.5, color: MizanColors.emerald300),
                      isDense: true,
                      filled: true,
                      fillColor: MizanColors.bgInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: MizanColors.borderSubtle),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AsrMethod.shafi,
                        child: Text('Shafi / Majority'),
                      ),
                      DropdownMenuItem(
                        value: AsrMethod.hanafi,
                        child: Text('Hanafi (2x Shadow)'),
                      ),
                    ],
                    onChanged: (m) {
                      if (m != null) {
                        ref.read(prayerSettingsProvider.notifier).setMadhab(m);
                      }
                    },
                  );
                  if (wide) {
                    return Row(
                      children: [
                        Expanded(child: methodDropdown),
                        const SizedBox(width: 10),
                        Expanded(child: madhabDropdown),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      methodDropdown,
                      const SizedBox(height: 8),
                      madhabDropdown,
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Next Prayer Hero Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A2E24), Color(0xFF061B15)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MizanColors.amber400.withAlpha(115)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'NEXT PRAYER',
                            style: MizanTypography.code(
                              fontSize: 10,
                              color: MizanColors.amber300,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${intl.DateFormat('HH:mm').format(settings.currentTime)}',
                            style: MizanTypography.code(
                              fontSize: 10,
                              color: MizanColors.emerald300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${prayerCalc.nextPrayer.name} (${prayerCalc.nextPrayer.arabicName})',
                        style: MizanTypography.title(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        prayerCalc.nextPrayer.time12,
                        style: MizanTypography.code(
                          fontSize: 13,
                          color: MizanColors.emerald300,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      prayerCalc.countdownString,
                      style: MizanTypography.code(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MizanColors.amber400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${settings.method.name.toUpperCase()} · ${settings.madhab.name.toUpperCase()}',
                      style: MizanTypography.code(
                        fontSize: 9.5,
                        color: MizanColors.slate400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 6 Daily Solar Times Grid
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth >= 720 ? 6 : 3;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: cols == 6 ? 1.35 : 1.45,
              children: prayerCalc.prayers.map((p) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: p.isNext
                        ? MizanColors.amber500.withAlpha(41)
                        : MizanColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: p.isNext
                          ? MizanColors.amber400
                          : MizanColors.borderSubtle,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p.name,
                        style: MizanTypography.body(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: p.isNext ? MizanColors.amber300 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.time12,
                        style: MizanTypography.code(
                          fontSize: 10,
                          color: MizanColors.emerald300,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),

          // Daily Micro-Sunnahs Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Daily Micro-Sunnahs (${streaks.completedTodayCount}/${streaks.sunnahs.length})',
                  style: MizanTypography.body(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: MizanColors.amber300,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(salahSubViewProvider.notifier).state =
                    SalahSubView.streaks,
                child: Text(
                  'Streaks & Grace Days →',
                  style: MizanTypography.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: MizanColors.emerald400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...streaks.sunnahs.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: s.completed
                    ? MizanColors.emerald950.withAlpha(204)
                    : MizanColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: s.completed
                      ? MizanColors.emerald500.withAlpha(128)
                      : MizanColors.borderSubtle,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () =>
                    ref.read(streaksProvider.notifier).toggleHabit(s.id),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        s.completed
                            ? LucideIcons.checkCircle2
                            : LucideIcons.circle,
                        size: 20,
                        color: s.completed
                            ? MizanColors.emerald400
                            : MizanColors.slate400,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: MizanTypography.body(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${s.streakDays}d streak · ${s.durationMinutes} min · ${s.hadithReference}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MizanTypography.code(
                                fontSize: 9.5,
                                color: MizanColors.amber300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildOnboardingCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2A22), Color(0xFF061B15)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MizanColors.amber400.withAlpha(115)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MizanColors.amber500.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: MizanColors.amber400.withAlpha(102)),
                ),
                child: const Icon(LucideIcons.compass,
                    size: 18, color: MizanColors.amber300),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New to Mīzān? Start Your Guided Onboarding',
                      style: MizanTypography.body(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: MizanColors.amber300,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Let Al-Murshid guide you through Salah timing, habit logging, the Shield, and Multi-AI setup.',
                      style: MizanTypography.body(
                        fontSize: 11.5,
                        color: MizanColors.slate300,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => dismissOnboardingBanner(ref),
                icon: const Icon(LucideIcons.x,
                    size: 16, color: MizanColors.slate400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MizanColors.amber500,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _openTour(context, ref, view: 'tour'),
                icon: const Icon(LucideIcons.sparkles, size: 13),
                label: Text(
                  'Start Guided Tour',
                  style: MizanTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: MizanColors.borderEmerald),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => _openTour(context, ref, view: 'qa'),
                icon: const Icon(LucideIcons.helpCircle,
                    size: 13, color: MizanColors.emerald300),
                label: Text(
                  'Ask How It Works',
                  style: MizanTypography.body(
                    fontSize: 11,
                    color: MizanColors.emerald300,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 2. SHIELD HUB: Non-Coercive Short-Form Video Shield + Ethical MI Reflection
class ShieldHubView extends ConsumerStatefulWidget {
  const ShieldHubView({super.key});

  @override
  ConsumerState<ShieldHubView> createState() => _ShieldHubViewState();
}

class _ShieldHubViewState extends ConsumerState<ShieldHubView> {
  String _reflectionMood = 'Overwhelmed by Reels/Scrolling';
  ReflectionResponse? _reflectionResult;
  bool _loadingReflection = false;

  Future<void> _runShieldReflection() async {
    setState(() => _loadingReflection = true);
    final gw = ref.read(aiGatewayProvider);
    final shield = ref.read(shieldProvider);
    final res = await AIGatewayService.instance.requestReflection(
      gateway: gw,
      appName: 'Instagram Reels',
      timeSpentMinutes: shield.dailyMinutesUsed,
      emotionalState: _reflectionMood,
    );
    await ref.read(aiGatewayProvider.notifier).incrementRequests();
    if (!mounted) return;
    setState(() {
      _reflectionResult = res;
      _loadingReflection = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shield = ref.watch(shieldProvider);
    final ratio =
        (shield.dailyMinutesUsed / shield.dailyLimitMinutes).clamp(0.0, 1.0);
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 420 ? 12.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 72),
      children: [
        MizanCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OS Short-Form Video Shield',
                          style: MizanTypography.title(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AccessibilityService: ${shield.accessibilityGranted ? "GRANTED (Local-Only)" : "Disclosure Required"}',
                          style: MizanTypography.code(
                            fontSize: 10.5,
                            color: shield.accessibilityGranted
                                ? MizanColors.emerald400
                                : MizanColors.amber300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: shield.shortsShieldEnabled,
                    activeColor: MizanColors.emerald400,
                    onChanged: (_) =>
                        ref.read(shieldProvider.notifier).toggleShortsShield(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: ratio,
                minHeight: 7,
                backgroundColor: MizanColors.bgDeep,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ratio > 0.85 ? MizanColors.rose400 : MizanColors.emerald400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${shield.dailyMinutesUsed}m / ${shield.dailyLimitMinutes}m daily budget · ${shield.blockedReelsCount} Reels paused today',
                style: MizanTypography.body(
                  fontSize: 11.5,
                  color: MizanColors.slate300,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Short-Form Budget (${shield.dailyLimitMinutes} min)',
                    style: MizanTypography.body(
                      fontSize: 11.5,
                      color: MizanColors.slate200,
                    ),
                  ),
                  Text(
                    '15m – 120m',
                    style: MizanTypography.code(
                      fontSize: 10,
                      color: MizanColors.slate400,
                    ),
                  ),
                ],
              ),
              Slider(
                value: shield.dailyLimitMinutes.toDouble(),
                min: 15,
                max: 120,
                divisions: 7,
                activeColor: MizanColors.amber400,
                onChanged: (v) =>
                    ref.read(shieldProvider.notifier).setDailyLimit(v.round()),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MizanIconButton(
                    label: 'Trigger 7s Shield Pause',
                    icon: LucideIcons.shieldAlert,
                    bgColor: MizanColors.amber500,
                    textColor: Colors.black,
                    onPressed: () {
                      ref.read(shieldProvider.notifier).incrementBlockedReels();
                      ref.read(shieldAppNameProvider.notifier).state =
                          'Instagram Reels';
                      ref.read(showShieldModalProvider.notifier).state = true;
                    },
                  ),
                  MizanIconButton(
                    label: 'Disclosure Policy',
                    icon: LucideIcons.lock,
                    bgColor: MizanColors.emerald950,
                    borderColor: MizanColors.borderEmerald,
                    textColor: MizanColors.emerald300,
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const ProminentDisclosureDialog(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Ethical MI Impulse Reflection Card
        MizanCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ethical MI Impulse Reflection',
                style: MizanTypography.title(
                  fontSize: 16,
                  color: MizanColors.amber300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Compassionate OARS reflection routed through your selected Multi-AI Gateway or deterministic offline matrix.',
                style: MizanTypography.body(
                  fontSize: 11.5,
                  color: MizanColors.slate300,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _reflectionMood,
                dropdownColor: MizanColors.bgCardElevated,
                style: MizanTypography.body(fontSize: 12, color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MizanColors.bgInput,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: MizanColors.borderSubtle),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Overwhelmed by Reels/Scrolling',
                    child: Text('Overwhelmed by Reels/Scrolling'),
                  ),
                  DropdownMenuItem(
                    value: 'Avoiding difficult deep work',
                    child: Text('Avoiding difficult deep work'),
                  ),
                  DropdownMenuItem(
                    value: 'Late night boredom / fatigue',
                    child: Text('Late night boredom / fatigue'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _reflectionMood = v);
                },
              ),
              const SizedBox(height: 10),
              MizanIconButton(
                label: _loadingReflection
                    ? 'Composing Empathy...'
                    : 'Trigger Non-Judgmental Reflection',
                icon: LucideIcons.sparkles,
                fullWidth: true,
                onPressed: _loadingReflection ? null : _runShieldReflection,
              ),
              if (_reflectionResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MizanColors.bgDeep,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MizanColors.borderEmerald),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _reflectionResult!.empathy,
                        style: MizanTypography.body(
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _reflectionResult!.inquiry,
                        style: MizanTypography.body(
                          fontSize: 11.5,
                          color: MizanColors.amber300,
                          height: 1.4,
                        ),
                      ),
                      if (_reflectionResult!.affirmation.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _reflectionResult!.affirmation,
                          style: MizanTypography.body(
                            fontSize: 11,
                            color: MizanColors.slate300,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        'Route: ${_reflectionResult!.source}',
                        style: MizanTypography.code(
                          fontSize: 9.5,
                          color: MizanColors.emerald400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 4. 24H PLANNER HUB: Personal Goal Tracking + Circadian Barakah Schedule
class PlannerHubView extends ConsumerWidget {
  const PlannerHubView({super.key});

  double _parseHour(String hhmm) {
    final parts = hhmm.split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return h + (m / 60.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subView = ref.watch(plannerSubViewProvider);
    final prayerCalc = ref.watch(prayerCalculationProvider);
    final goals = ref.watch(personalGoalsProvider);
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 420 ? 12.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 72),
      children: [
        _SubViewBar<PlannerSubView>(
          active: subView,
          onChanged: (v) => ref.read(plannerSubViewProvider.notifier).state = v,
          items: const [
            (
              value: PlannerSubView.goals,
              label: 'Personal Goals',
              icon: LucideIcons.target,
            ),
            (
              value: PlannerSubView.timeline,
              label: '24h Barakah',
              icon: LucideIcons.clock,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (subView == PlannerSubView.goals)
          const PersonalGoalsScreen()
        else ...[
          MizanCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MizanColors.amber500.withAlpha(38),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: MizanColors.amber400.withAlpha(115)),
                  ),
                  child: const Icon(LucideIcons.clock,
                      size: 22, color: MizanColors.amber300),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '24-Hour Circadian Barakah Schedule',
                        style: MizanTypography.title(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Aligned with ${prayerCalc.nextPrayer.name} at ${prayerCalc.nextPrayer.time12} (in ${prayerCalc.countdownString})',
                        style: MizanTypography.body(
                          fontSize: 11.5,
                          color: MizanColors.emerald300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...initialCircadianBlocks.map((b) {
            final color = Color(b.colorHex);
            final linkedGoals = goals.where((g) {
              if (g.isPaused || g.isCompleted) return false;
              final h = _parseHour(g.scheduledTime);
              return h >= b.startHour && h < b.endHour;
            }).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MizanColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withAlpha(115)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${b.startHour.toStringAsFixed(0)}:00 - ${b.endHour.toStringAsFixed(0)}:00',
                              style: MizanTypography.code(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              b.title,
                              style: MizanTypography.body(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.sunnahAnchor,
                          style: MizanTypography.body(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: MizanColors.amber300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.description,
                          style: MizanTypography.body(
                            fontSize: 11.5,
                            color: MizanColors.slate300,
                            height: 1.4,
                          ),
                        ),
                        if (linkedGoals.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: linkedGoals.map((g) {
                              return InkWell(
                                onTap: () => ref
                                    .read(plannerSubViewProvider.notifier)
                                    .state = PlannerSubView.goals,
                                borderRadius: BorderRadius.circular(999),
                                child: MizanBadge(
                                  icon: LucideIcons.target,
                                  label:
                                      '${g.scheduledTime} · ${g.title} (${g.progressPercent}%)',
                                  bgColor: color.withAlpha(32),
                                  borderColor: color.withAlpha(115),
                                  textColor: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

/// 5. COACH HUB: Al-Murshid Agent + Multi-AI Gateway (BYOK) + Floating Companion (Nūr)
class CoachHubView extends ConsumerWidget {
  const CoachHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subView = ref.watch(coachSubViewProvider);
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 420 ? 12.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 72),
      children: [
        _SubViewBar<CoachSubView>(
          active: subView,
          onChanged: (v) => ref.read(coachSubViewProvider.notifier).state = v,
          items: const [
            (
              value: CoachSubView.chat,
              label: 'Al-Murshid AI',
              icon: Icons.smart_toy_outlined,
            ),
            (
              value: CoachSubView.gateway,
              label: 'Multi-AI Gateway',
              icon: LucideIcons.cpu,
            ),
            (
              value: CoachSubView.companion,
              label: 'Nūr Companion',
              icon: LucideIcons.sparkles,
            ),
          ],
        ),
        const SizedBox(height: 14),
        switch (subView) {
          CoachSubView.chat => const HolisticAIAgentScreen(),
          CoachSubView.gateway => const MultiAIGatewayScreen(),
          CoachSubView.companion => const InteractiveCompanionScreen(),
        },
      ],
    );
  }
}

/// 6. PROFILE HUB: Account & Security + Peer Accountability + Ethics & Architecture
class ProfileHubView extends ConsumerWidget {
  const ProfileHubView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subView = ref.watch(profileSubViewProvider);
    final govSection = ref.watch(governanceSectionProvider);
    final shield = ref.watch(shieldProvider);
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 420 ? 12.0 : 16.0;

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 72),
      children: [
        _SubViewBar<ProfileSubView>(
          active: subView,
          onChanged: (v) => ref.read(profileSubViewProvider.notifier).state = v,
          items: const [
            (
              value: ProfileSubView.account,
              label: 'Account & Vault',
              icon: LucideIcons.user,
            ),
            (
              value: ProfileSubView.peers,
              label: 'Peer Ledger',
              icon: LucideIcons.users,
            ),
            (
              value: ProfileSubView.governance,
              label: 'Ethics & Arch',
              icon: LucideIcons.shield,
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (subView == ProfileSubView.account)
          const ProfileAuthScreen()
        else if (subView == ProfileSubView.peers)
          _buildPeersLedger(ref, shield)
        else ...[
          _SubViewBar<GovernanceSection>(
            active: govSection,
            onChanged: (v) =>
                ref.read(governanceSectionProvider.notifier).state = v,
            items: const [
              (
                value: GovernanceSection.ethics,
                label: 'Ethical Charter',
                icon: LucideIcons.shieldCheck,
              ),
              (
                value: GovernanceSection.architecture,
                label: 'System Layers',
                icon: LucideIcons.layers,
              ),
              (
                value: GovernanceSection.explorer,
                label: 'Code Explorer',
                icon: LucideIcons.code2,
              ),
            ],
          ),
          const SizedBox(height: 14),
          switch (govSection) {
            GovernanceSection.ethics => const EthicalConstitutionScreen(),
            GovernanceSection.architecture =>
              const SystemArchitectureDiagramScreen(),
            GovernanceSection.explorer => const ArchitectureExplorerScreen(),
          },
        ],
      ],
    );
  }

  Widget _buildPeersLedger(WidgetRef ref, ShieldState shield) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MizanCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ed25519 Peer Accountability Ledger',
                style: MizanTypography.title(fontSize: 17, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Zero-knowledge cryptographic streak proofs shared among trusted accountability companions with zero public leaderboards.',
                style: MizanTypography.body(
                  fontSize: 12,
                  color: MizanColors.slate300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...shield.peers.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MizanColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: MizanColors.borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: MizanColors.emerald900,
                    child: Text(p.alias[0],
                        style: const TextStyle(
                            color: MizanColors.amber300,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.alias} · ${p.streakDays}d streak',
                          style: MizanTypography.body(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.cryptographicSignature,
                          overflow: TextOverflow.ellipsis,
                          style: MizanTypography.code(
                            fontSize: 10,
                            color: MizanColors.emerald400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: p.encouragementSent
                        ? null
                        : () => ref
                            .read(shieldProvider.notifier)
                            .sendEncouragement(p.id),
                    child: Text(
                      p.encouragementSent ? 'Dua Sent ✓' : 'Make Dua',
                      style: MizanTypography.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: p.encouragementSent
                            ? MizanColors.emerald400
                            : MizanColors.amber300,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

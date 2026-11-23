import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/mizan_models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/mizan_theme.dart';
import '../../companion/presentation/widgets/floating_companion_overlay.dart';
import '../../home/presentation/mizan_tab_views.dart';
import '../../onboarding/presentation/widgets/onboarding_assistant_dialog.dart';
import '../../quran/presentation/screens/multilingual_quran_screen.dart';
import '../../shield/presentation/widgets/overlay_shield_modal.dart';

class MizanShellScreen extends ConsumerWidget {
  const MizanShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(appTabProvider);
    final prayerSettings = ref.watch(prayerSettingsProvider);
    final prayerCalc = ref.watch(prayerCalculationProvider);
    final showOverlayShield = ref.watch(showShieldModalProvider);
    final shieldTargetApp = ref.watch(shieldAppNameProvider);
    final reminderState = ref.watch(goalReminderProvider);
    final activeAlert = reminderState.activeAlert;
    final media = MediaQuery.of(context);

    ref.listen<bool>(showOnboardingModalProvider, (prev, next) {
      if (next && prev != true) {
        ref.read(showOnboardingModalProvider.notifier).state = false;
        showDialog<void>(
          context: context,
          builder: (_) => const OnboardingAssistantDialog(),
        );
      }
    });

    final nextDiff = prayerCalc.nextPrayer.dateObj
        .difference(prayerSettings.currentTime)
        .inMinutes
        .clamp(1, 999);
    final bottomInset = media.padding.bottom;
    final bottomNavHeight = 60.0 + bottomInset;

    return Scaffold(
      backgroundColor: MizanColors.bgDeep,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Subtle Islamic Lattice Background extending full screen edge-to-edge
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: IslamicPatternPainter()),
            ),
          ),

          // Unified Fluid Content + Native Bottom Navigation Bar
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: _buildActiveTabBody(context, activeTab),
                ),
              ),

              // Native Full-Width Edge-to-Edge Bottom Navigation Bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(6, 8, 6, 8 + bottomInset),
                decoration: const BoxDecoration(
                  color: MizanColors.bgHeader,
                  border: Border(
                    top: BorderSide(color: MizanColors.borderSubtle),
                  ),
                ),
                child: Row(
                  children: [
                    _navBtn(
                      ref: ref,
                      tab: AppTab.salah,
                      icon: LucideIcons.compass,
                      label: 'Salah',
                      active: activeTab == AppTab.salah,
                    ),
                    _navBtn(
                      ref: ref,
                      tab: AppTab.shield,
                      icon: LucideIcons.shield,
                      label: 'Shield',
                      active: activeTab == AppTab.shield,
                    ),
                    _navBtn(
                      ref: ref,
                      tab: AppTab.quran,
                      icon: LucideIcons.bookOpen,
                      label: 'Quran',
                      active: activeTab == AppTab.quran,
                    ),
                    _navBtn(
                      ref: ref,
                      tab: AppTab.planner,
                      icon: LucideIcons.clock,
                      label: '24h',
                      active: activeTab == AppTab.planner,
                    ),
                    _navBtn(
                      ref: ref,
                      tab: AppTab.coach,
                      icon: Icons.smart_toy_outlined,
                      label: 'Coach',
                      active: activeTab == AppTab.coach,
                    ),
                    _navBtn(
                      ref: ref,
                      tab: AppTab.profile,
                      icon: LucideIcons.user,
                      label: 'Profile',
                      active: activeTab == AppTab.profile,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Persistent Bounded Floating Companion Overlay (Nūr)
          Positioned.fill(
            top: media.padding.top + 4,
            bottom: bottomNavHeight,
            child: FloatingCompanionOverlay(
              nextSalahName: prayerCalc.nextPrayer.name,
              nextSalahMinutes: nextDiff,
            ),
          ),

          // Real-Time In-App Goal Reminder Notification Banner
          if (activeAlert != null)
            Positioned(
              top: media.padding.top + 8,
              left: 12,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0E352B), Color(0xFF07211A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: MizanColors.amber400,
                      width: 1.4,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xCC000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: MizanColors.amber500.withAlpha(46),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              size: 16,
                              color: MizanColors.amber300,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeAlert.isTest
                                      ? 'GOAL REMINDER PREVIEW · ${activeAlert.scheduledTime}'
                                      : 'SCHEDULED GOAL DUE · ${activeAlert.scheduledTime}',
                                  style: MizanTypography.code(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: MizanColors.amber300,
                                  ),
                                ),
                                Text(
                                  activeAlert.goalTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MizanTypography.title(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Dismiss',
                            onPressed: () => ref
                                .read(goalReminderProvider.notifier)
                                .dismissAlert(),
                            icon: const Icon(
                              LucideIcons.x,
                              size: 17,
                              color: MizanColors.slate300,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${activeAlert.scheduledSlot} · ${activeAlert.progressText}',
                        style: MizanTypography.body(
                          fontSize: 11.5,
                          color: MizanColors.emerald300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              backgroundColor: MizanColors.amber500,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              await ref
                                  .read(goalReminderProvider.notifier)
                                  .logFromActiveAlert();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: MizanColors.emerald900,
                                    content: Text(
                                      'Logged +1 for ${activeAlert.goalTitle}',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(LucideIcons.checkCircle2, size: 14),
                            label: Text(
                              'Log +1 Now',
                              style: MizanTypography.body(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              side: const BorderSide(
                                  color: MizanColors.borderEmerald),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                            ),
                            onPressed: () => ref
                                .read(goalReminderProvider.notifier)
                                .snoozeActiveAlert(),
                            icon: const Icon(
                              LucideIcons.clock,
                              size: 13,
                              color: MizanColors.emerald300,
                            ),
                            label: Text(
                              'Snooze 10m',
                              style: MizanTypography.body(
                                fontSize: 11,
                                color: MizanColors.emerald300,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () => navigateToFeature(
                              ref,
                              AppTab.planner,
                              subView: 'goals',
                            ),
                            child: Text(
                              'Open Goals',
                              style: MizanTypography.body(
                                fontSize: 11,
                                color: MizanColors.amber300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Full-Screen Non-Coercive Overlay Shield
          if (showOverlayShield)
            Positioned.fill(
              child: OverlayShieldModal(
                targetApp: shieldTargetApp,
                onDismiss: () =>
                    ref.read(showShieldModalProvider.notifier).state = false,
                onSelectAlternative: (alt) {
                  ref.read(showShieldModalProvider.notifier).state = false;
                  ref.read(appTabProvider.notifier).state = AppTab.quran;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: MizanColors.emerald900,
                      content: Text('Chosen offline alternative: $alt'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveTabBody(BuildContext context, AppTab tab) {
    final width = MediaQuery.of(context).size.width;
    final hPad = width < 420 ? 12.0 : 16.0;

    switch (tab) {
      case AppTab.salah:
        return const SalahHubView();
      case AppTab.shield:
        return const ShieldHubView();
      case AppTab.quran:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 72),
          child: const MultilingualQuranScreen(),
        );
      case AppTab.planner:
        return const PlannerHubView();
      case AppTab.coach:
        return const CoachHubView();
      case AppTab.profile:
        return const ProfileHubView();
    }
  }

  Widget _navBtn({
    required WidgetRef ref,
    required AppTab tab,
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(appTabProvider.notifier).state = tab,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 19,
                color: active ? MizanColors.amber400 : MizanColors.slate400,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MizanTypography.body(
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active ? MizanColors.amber300 : MizanColors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

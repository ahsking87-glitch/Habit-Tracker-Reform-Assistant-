import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class StreaksAndRewardsScreen extends ConsumerStatefulWidget {
  const StreaksAndRewardsScreen({super.key});

  @override
  ConsumerState<StreaksAndRewardsScreen> createState() =>
      _StreaksAndRewardsScreenState();
}

class _StreaksAndRewardsScreenState
    extends ConsumerState<StreaksAndRewardsScreen> {
  late final ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _showBadgeDetail(MilestoneBadge b) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: MizanColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: MizanColors.amber400),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                b.arabicName,
                style: MizanTypography.arabic(
                    fontSize: 22, color: MizanColors.amber300),
              ),
              Text(
                b.name,
                style: MizanTypography.title(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              MizanBadge(
                label:
                    '${b.tier.toUpperCase()} · ${b.requiredDays} Consecutive Days',
              ),
              const SizedBox(height: 12),
              Text(
                b.description,
                textAlign: TextAlign.center,
                style: MizanTypography.body(
                    fontSize: 12.5, color: MizanColors.slate200),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MizanColors.bgCardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MizanColors.borderSubtle),
                ),
                child: Text(
                  b.hadithReference,
                  textAlign: TextAlign.center,
                  style: MizanTypography.body(
                      fontSize: 11.5, color: MizanColors.emerald300),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MizanColors.amber500,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streaks = ref.watch(streaksProvider);

    ref.listen<StreaksState>(streaksProvider, (prev, next) {
      if (next.newlyUnlockedBadge != null &&
          prev?.newlyUnlockedBadge?.id != next.newlyUnlockedBadge?.id) {
        _confettiCtrl.play();
        _showBadgeDetail(next.newlyUnlockedBadge!);
        ref.read(streaksProvider.notifier).clearCelebration();
      }
    });

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4 KPI Summary Cards
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth > 760 ? 4 : 2;
              final aspect = constraints.maxWidth < 400 ? 1.55 : 1.9;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: aspect,
                children: [
                  _statCard(
                    'Active Habit Streak',
                    '${streaks.highestActiveStreak} Days',
                    LucideIcons.flame,
                    MizanColors.amber400,
                  ),
                  _statCard(
                    'Completed Today',
                    '${streaks.completedTodayCount} / ${streaks.sunnahs.length}',
                    LucideIcons.checkCircle2,
                    MizanColors.emerald400,
                  ),
                  _statCard(
                    'Istighfar Grace Days',
                    '${streaks.graceDaysRemaining} / 3 Left',
                    LucideIcons.heart,
                    MizanColors.sky400,
                  ),
                  _statCard(
                    'Milestones Unlocked',
                    '${streaks.unlockedBadgeCount} / ${streaks.badges.length}',
                    LucideIcons.award,
                    MizanColors.amber300,
                  ),
                ],
              );
            }),
            const SizedBox(height: 18),

            // Habits & Grace Day Repair List
            MizanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Micro-Sunnah Streak Ledger & Istighfar Grace Repair',
                          style: MizanTypography.title(
                              fontSize: 16.5, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => jumpToSourceFile(ref,
                            'lib/features/streaks/presentation/screens/streaks_and_rewards_screen.dart'),
                        icon: const Icon(LucideIcons.code2,
                            size: 13, color: MizanColors.amber300),
                        label: Text(
                          'Code',
                          style: MizanTypography.code(
                              fontSize: 10.5, color: MizanColors.emerald300),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...streaks.sunnahs.map((s) {
                    final pct = (s.streakDays / 40.0).clamp(0.0, 1.0);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: MizanColors.bgCardAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: s.completed
                              ? MizanColors.emerald500.withAlpha(140)
                              : MizanColors.borderSubtle,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (!s.completed) _confettiCtrl.play();
                                  ref
                                      .read(streaksProvider.notifier)
                                      .toggleHabit(s.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    s.completed
                                        ? LucideIcons.checkCircle2
                                        : LucideIcons.circle,
                                    size: 22,
                                    color: s.completed
                                        ? MizanColors.emerald400
                                        : MizanColors.slate400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.title,
                                      style: MizanTypography.body(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${s.streakDays}d active · Best: ${s.longestStreak}d · ${s.durationMinutes} min',
                                      style: MizanTypography.code(
                                        fontSize: 10.5,
                                        color: MizanColors.amber300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!s.completed &&
                              streaks.graceDaysRemaining > 0) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  side: const BorderSide(
                                      color: MizanColors.amber400),
                                ),
                                onPressed: () {
                                  _confettiCtrl.play();
                                  ref
                                      .read(streaksProvider.notifier)
                                      .repairWithIstighfar(s.id);
                                },
                                child: Text(
                                  'Repair with Istighfar',
                                  style: MizanTypography.body(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: MizanColors.amber300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: pct,
                            backgroundColor: MizanColors.bgInput,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                MizanColors.amber400),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 6 Milestone Badges Gallery
            MizanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Authentic Hadith Milestone Badges',
                    style: MizanTypography.title(
                        fontSize: 17, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(builder: (context, constraints) {
                    final cols = constraints.maxWidth > 760
                        ? 3
                        : constraints.maxWidth > 460
                            ? 2
                            : 1;

                    Widget buildBadgeCard(MilestoneBadge b) {
                      return InkWell(
                        onTap: () => _showBadgeDetail(b),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: b.unlocked
                                ? const Color(0xFF0A2E25)
                                : MizanColors.bgCardAlt.withAlpha(153),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: b.unlocked
                                  ? MizanColors.amber400.withAlpha(153)
                                  : MizanColors.borderSubtle,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MizanBadge(
                                    label: b.unlocked
                                        ? 'UNLOCKED'
                                        : '${b.requiredDays}d Goal',
                                    textColor: b.unlocked
                                        ? MizanColors.amber300
                                        : MizanColors.slate400,
                                  ),
                                  Icon(
                                    b.unlocked
                                        ? LucideIcons.award
                                        : LucideIcons.lock,
                                    size: 18,
                                    color: b.unlocked
                                        ? MizanColors.amber400
                                        : MizanColors.slate500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.name,
                                    style: MizanTypography.title(
                                      fontSize: 13.5,
                                      color: b.unlocked
                                          ? Colors.white
                                          : MizanColors.slate400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: MizanTypography.body(
                                      fontSize: 10.5,
                                      color: MizanColors.slate300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (cols == 1) {
                      return Column(
                        children: [
                          for (int i = 0; i < streaks.badges.length; i++) ...[
                            buildBadgeCard(streaks.badges[i]),
                            if (i < streaks.badges.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.45,
                      ),
                      itemCount: streaks.badges.length,
                      itemBuilder: (_, idx) =>
                          buildBadgeCard(streaks.badges[idx]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        ConfettiWidget(
          confettiController: _confettiCtrl,
          blastDirectionality: BlastDirectionality.explosive,
          colors: const [
            MizanColors.amber400,
            MizanColors.emerald400,
            Colors.white,
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color color) {
    return MizanCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: MizanTypography.body(
                      fontSize: 11, color: MizanColors.slate300),
                ),
                Text(
                  val,
                  style:
                      MizanTypography.title(fontSize: 17, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';
import '../widgets/weekly_progress_chart.dart';

class PersonalGoalsScreen extends ConsumerStatefulWidget {
  const PersonalGoalsScreen({super.key});

  @override
  ConsumerState<PersonalGoalsScreen> createState() =>
      _PersonalGoalsScreenState();
}

class _PersonalGoalsScreenState extends ConsumerState<PersonalGoalsScreen> {
  String _filter =
      'all'; // all | today | completed | learning | spiritual | task | wellness

  ({String label, Color color, IconData icon}) _categoryMeta(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.learning:
        return (
          label: 'Learning',
          color: MizanColors.cyan400,
          icon: Icons.school_outlined,
        );
      case GoalCategory.spiritual:
        return (
          label: 'Spiritual',
          color: MizanColors.amber400,
          icon: LucideIcons.sparkles,
        );
      case GoalCategory.task:
        return (
          label: 'Tasks & Work',
          color: MizanColors.sky400,
          icon: Icons.task_alt,
        );
      case GoalCategory.wellness:
        return (
          label: 'Wellbeing',
          color: MizanColors.emerald400,
          icon: LucideIcons.heart,
        );
    }
  }

  String _cadenceLabel(PersonalGoal g) {
    switch (g.cadence) {
      case GoalCadence.daily:
        return 'Daily';
      case GoalCadence.weekdays:
        return 'Weekdays';
      case GoalCadence.customDays:
        const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final days = g.scheduledDays
            .where((d) => d >= 1 && d <= 7)
            .map((d) => names[d - 1])
            .join('·');
        return days.isEmpty ? 'Custom' : days;
      case GoalCadence.oneTime:
        return 'One-Time';
    }
  }

  List<PersonalGoal> _applyFilter(List<PersonalGoal> goals) {
    switch (_filter) {
      case 'today':
        return goals.where((g) => g.isScheduledToday && !g.isCompleted).toList();
      case 'completed':
        return goals.where((g) => g.isCompleted).toList();
      case 'learning':
        return goals.where((g) => g.category == GoalCategory.learning).toList();
      case 'spiritual':
        return goals
            .where((g) => g.category == GoalCategory.spiritual)
            .toList();
      case 'task':
        return goals.where((g) => g.category == GoalCategory.task).toList();
      case 'wellness':
        return goals.where((g) => g.category == GoalCategory.wellness).toList();
      default:
        return goals;
    }
  }

  Future<void> _confirmDelete(PersonalGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MizanColors.bgCard,
        title: Text(
          'Delete Goal?',
          style: MizanTypography.title(fontSize: 17, color: Colors.white),
        ),
        content: Text(
          'Remove "${goal.title}" and its local progress logs?',
          style: MizanTypography.body(fontSize: 13, color: MizanColors.slate300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MizanColors.rose400,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(personalGoalsProvider.notifier).deleteGoal(goal.id);
    }
  }

  Future<void> _openGoalEditorSheet({PersonalGoal? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MizanColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _GoalEditorSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(personalGoalsProvider);
    final reminderState = ref.watch(goalReminderProvider);
    final filtered = _applyFilter(goals);

    final activeCount = goals.where((g) => !g.isCompleted && !g.isPaused).length;
    final completedCount = goals.where((g) => g.isCompleted).length;
    final todayCount =
        goals.where((g) => g.isScheduledToday && !g.isCompleted).length;
    final weeklyLogs =
        goals.fold<int>(0, (sum, g) => sum + g.weeklyCheckIns);

    final overallProgress = goals.isEmpty
        ? 0.0
        : goals.map((g) => g.progressRatio).reduce((a, b) => a + b) /
            goals.length;
    final overallPercent = (overallProgress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Visual Progress Metrics Hero Card
        MizanCard(
          padding: const EdgeInsets.all(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0A2E24), Color(0xFF061B15)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderColor: MizanColors.amber400.withAlpha(115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 62,
                    height: 62,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 62,
                          height: 62,
                          child: CircularProgressIndicator(
                            value: overallProgress,
                            strokeWidth: 6,
                            backgroundColor: MizanColors.bgDeep,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              MizanColors.amber400,
                            ),
                          ),
                        ),
                        Text(
                          '$overallPercent%',
                          style: MizanTypography.code(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PERSONAL GOAL TRACKER',
                          style: MizanTypography.code(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: MizanColors.amber300,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Learning & Task Mastery',
                          style: MizanTypography.title(
                            fontSize: 17.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${goals.length} local goals · Saved offline on-device',
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
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 680 ? 4 : 2;
                final aspect = constraints.maxWidth < 400 ? 1.65 : 2.3;
                return GridView.count(
                  crossAxisCount: cols,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: aspect,
                  children: [
                    _kpiTile(
                      'Active',
                      '$activeCount',
                      LucideIcons.target,
                      MizanColors.amber400,
                    ),
                    _kpiTile(
                      'Completed',
                      '$completedCount',
                      LucideIcons.award,
                      MizanColors.emerald400,
                    ),
                    _kpiTile(
                      'Due Today',
                      '$todayCount',
                      Icons.event_available_outlined,
                      MizanColors.cyan400,
                    ),
                    _kpiTile(
                      '7d Check-ins',
                      '$weeklyLogs',
                      Icons.trending_up,
                      MizanColors.sky400,
                    ),
                  ],
                );
              }),
              if (goals.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'CATEGORY MOMENTUM',
                  style: MizanTypography.code(
                    fontSize: 9.5,
                    color: MizanColors.slate400,
                  ),
                ),
                const SizedBox(height: 8),
                ...GoalCategory.values.map((cat) {
                  final catGoals =
                      goals.where((g) => g.category == cat).toList();
                  if (catGoals.isEmpty) return const SizedBox.shrink();
                  final avg = catGoals
                          .map((g) => g.progressRatio)
                          .reduce((a, b) => a + b) /
                      catGoals.length;
                  final meta = _categoryMeta(cat);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 92,
                          child: Text(
                            meta.label,
                            overflow: TextOverflow.ellipsis,
                            style: MizanTypography.body(
                              fontSize: 11,
                              color: MizanColors.slate200,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: avg,
                              minHeight: 6,
                              backgroundColor: MizanColors.bgDeep,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(meta.color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 34,
                          child: Text(
                            '${(avg * 100).round()}%',
                            textAlign: TextAlign.right,
                            style: MizanTypography.code(
                              fontSize: 10,
                              color: meta.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Comprehensive Weekly Progress Chart
        const WeeklyProgressChart(),
        const SizedBox(height: 14),

        // 3. Real-Time Goal Reminder Notifications Card
        _buildLiveRemindersCard(goals, reminderState),
        const SizedBox(height: 14),

        // 4. Action Header + Filter Chips
        Row(
          children: [
            Expanded(
              child: Text(
                'Scheduled Goals (${filtered.length})',
                style: MizanTypography.title(fontSize: 15.5, color: Colors.white),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MizanColors.amber500,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _openGoalEditorSheet(),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'New Goal',
                style: MizanTypography.body(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in [
                ('all', 'All (${goals.length})'),
                ('today', 'Today ($todayCount)'),
                ('learning', 'Learning'),
                ('spiritual', 'Spiritual'),
                ('task', 'Tasks'),
                ('wellness', 'Wellbeing'),
                ('completed', 'Done ($completedCount)'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    selected: _filter == f.$1,
                    selectedColor: MizanColors.amber500,
                    backgroundColor: MizanColors.bgCard,
                    label: Text(
                      f.$2,
                      style: MizanTypography.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _filter == f.$1 ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _filter = f.$1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Goals List or Empty State
        if (filtered.isEmpty)
          MizanCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(LucideIcons.compass,
                    size: 28, color: MizanColors.amber400),
                const SizedBox(height: 8),
                Text(
                  'No goals match this filter',
                  style: MizanTypography.title(
                    fontSize: 15.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a custom learning or task goal and anchor it to your daily Barakah schedule.',
                  textAlign: TextAlign.center,
                  style: MizanTypography.body(
                    fontSize: 12,
                    color: MizanColors.slate300,
                  ),
                ),
                const SizedBox(height: 12),
                MizanIconButton(
                  label: 'Create Your Next Goal',
                  icon: Icons.add,
                  onPressed: () => _openGoalEditorSheet(),
                ),
              ],
            ),
          )
        else
          ...filtered.map((goal) => _buildGoalCard(goal)),
      ],
    );
  }

  Widget _kpiTile(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: MizanColors.bgDeep.withAlpha(179),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MizanColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: MizanTypography.body(
                    fontSize: 10,
                    color: MizanColors.slate300,
                  ),
                ),
                Text(
                  val,
                  style: MizanTypography.title(
                    fontSize: 15.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveRemindersCard(
    List<PersonalGoal> goals,
    GoalReminderState reminderState,
  ) {
    final armed = goals
        .where((g) => !g.isPaused && !g.isCompleted && g.reminderEnabled)
        .toList();

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    PersonalGoal? nextGoal;
    int bestDelta = 999999;

    for (final g in armed) {
      if (!g.isScheduledToday) continue;
      final parts = g.scheduledTime.split(':');
      final hh = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
      final mm = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      final targetMins = hh * 60 + mm;
      final delta = targetMins >= nowMinutes
          ? targetMins - nowMinutes
          : (24 * 60 - nowMinutes) + targetMins;
      if (delta < bestDelta) {
        bestDelta = delta;
        nextGoal = g;
      }
    }

    String countdownLabel = 'No goal scheduled today';
    if (nextGoal != null) {
      if (bestDelta == 0) {
        countdownLabel = 'Due right now';
      } else if (bestDelta < 60) {
        countdownLabel = 'in ${bestDelta}m';
      } else {
        final h = bestDelta ~/ 60;
        final m = bestDelta % 60;
        countdownLabel = 'in ${h}h ${m}m';
      }
    }

    final reminderNotifier = ref.read(goalReminderProvider.notifier);

    return MizanCard(
      padding: const EdgeInsets.all(14),
      borderColor: MizanColors.amber400.withAlpha(115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MizanColors.amber500.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MizanColors.amber400.withAlpha(115),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 17,
                  color: MizanColors.amber300,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REAL-TIME GOAL REMINDERS',
                      style: MizanTypography.code(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: MizanColors.amber300,
                      ),
                    ),
                    Text(
                      '${armed.length} Active Schedules · Live 15s Clock',
                      style: MizanTypography.title(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              MizanBadge(
                label: reminderState.osPermissionGranted ? 'OS READY' : 'IN-APP',
                bgColor: reminderState.osPermissionGranted
                    ? MizanColors.emerald500.withAlpha(40)
                    : MizanColors.amber500.withAlpha(36),
                borderColor: reminderState.osPermissionGranted
                    ? MizanColors.emerald400
                    : MizanColors.amber400,
                textColor: reminderState.osPermissionGranted
                    ? MizanColors.emerald300
                    : MizanColors.amber300,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MizanColors.bgDeep.withAlpha(190),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MizanColors.borderSubtle),
            ),
            child: nextGoal == null
                ? Text(
                    'Enable reminders on any scheduled goal below to receive live alerts.',
                    style: MizanTypography.body(
                      fontSize: 11.5,
                      color: MizanColors.slate300,
                    ),
                  )
                : Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: MizanColors.emerald300,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Next: ${nextGoal.title} at ${nextGoal.scheduledTime} (${nextGoal.scheduledSlot})',
                          style: MizanTypography.body(
                            fontSize: 11.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        countdownLabel,
                        style: MizanTypography.code(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: MizanColors.amber300,
                        ),
                      ),
                    ],
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: armed.isEmpty && goals.isEmpty
                    ? null
                    : () => reminderNotifier.triggerTestReminder(nextGoal),
                icon: const Icon(Icons.notifications_outlined, size: 15),
                label: Text(
                  'Test Live Reminder',
                  style: MizanTypography.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (!reminderState.osPermissionGranted)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: MizanColors.borderEmerald),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => reminderNotifier.requestOsPermission(),
                  icon: const Icon(
                    Icons.security_update_good_outlined,
                    size: 15,
                    color: MizanColors.emerald300,
                  ),
                  label: Text(
                    'Enable OS Alerts',
                    style: MizanTypography.body(
                      fontSize: 11.5,
                      color: MizanColors.emerald300,
                    ),
                  ),
                ),
            ],
          ),
          if (reminderState.recentHistory.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'RECENT ALERTS (${reminderState.recentHistory.length})',
              style: MizanTypography.code(
                fontSize: 9.5,
                color: MizanColors.slate400,
              ),
            ),
            const SizedBox(height: 6),
            ...reminderState.recentHistory.take(3).map((item) {
              final hh = item.triggeredAt.hour.toString().padLeft(2, '0');
              final mm = item.triggeredAt.minute.toString().padLeft(2, '0');
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: MizanColors.emerald400,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${item.goalTitle} · ${item.scheduledSlot}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MizanTypography.body(
                          fontSize: 11,
                          color: MizanColors.slate200,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.isTest ? '$hh:$mm (Test)' : '$hh:$mm',
                      style: MizanTypography.code(
                        fontSize: 9.5,
                        color: MizanColors.amber300,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(PersonalGoal goal) {
    final meta = _categoryMeta(goal.category);
    final notifier = ref.read(personalGoalsProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MizanCard(
        padding: const EdgeInsets.all(14),
        color: goal.isPaused
            ? MizanColors.bgCard.withAlpha(170)
            : MizanColors.bgCard,
        borderColor: goal.isCompleted
            ? MizanColors.emerald500.withAlpha(153)
            : meta.color.withAlpha(115),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Meta Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MizanBadge(
                        label: meta.label,
                        icon: meta.icon,
                        bgColor: meta.color.withAlpha(32),
                        borderColor: meta.color.withAlpha(115),
                        textColor: meta.color,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: MizanColors.bgInput,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: MizanColors.borderSubtle),
                        ),
                        child: Text(
                          '${_cadenceLabel(goal)} · ${goal.scheduledTime} · ${goal.scheduledSlot}',
                          style: MizanTypography.code(
                            fontSize: 9.5,
                            color: MizanColors.amber300,
                          ),
                        ),
                      ),
                      if (goal.isPaused)
                        const MizanBadge(
                          label: 'PAUSED',
                          bgColor: Color(0x3394A3B8),
                          borderColor: MizanColors.slate500,
                          textColor: MizanColors.slate300,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: goal.reminderEnabled
                      ? 'Mute Reminder'
                      : 'Enable Reminder',
                  onPressed: () => notifier.toggleReminder(goal.id),
                  icon: Icon(
                    goal.reminderEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    size: 17,
                    color: goal.reminderEnabled
                        ? MizanColors.amber300
                        : MizanColors.slate500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Title & Description
            Text(
              goal.title,
              style: MizanTypography.title(
                fontSize: 15,
                color: goal.isCompleted ? MizanColors.emerald300 : Colors.white,
              ),
            ),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                goal.description,
                style: MizanTypography.body(
                  fontSize: 11.5,
                  color: MizanColors.slate300,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Progress Bar + Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${goal.completedUnits} / ${goal.targetUnits} ${goal.unitLabel}',
                    overflow: TextOverflow.ellipsis,
                    style: MizanTypography.code(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  goal.isCompleted
                      ? 'COMPLETED ✓'
                      : '${goal.progressPercent}%${goal.targetDate != null ? ' · Due ${goal.targetDate}' : ''}',
                  style: MizanTypography.code(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: goal.isCompleted
                        ? MizanColors.emerald400
                        : MizanColors.amber300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: goal.progressRatio,
                minHeight: 8,
                backgroundColor: MizanColors.bgDeep,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.isCompleted ? MizanColors.emerald400 : meta.color,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 7-Day Activity Dots
            _buildWeeklyDots(goal),
            const SizedBox(height: 10),

            // Action Buttons (Wrapped cleanly so zero overflow on narrow screens)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    side: const BorderSide(color: MizanColors.borderSubtle),
                  ),
                  onPressed: goal.completedUnits > 0
                      ? () => notifier.logProgress(goal.id, delta: -1)
                      : null,
                  child: Text(
                    '-1',
                    style: MizanTypography.code(
                      fontSize: 11.5,
                      color: goal.completedUnits > 0
                          ? Colors.white
                          : MizanColors.slate500,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: goal.isCompleted
                        ? MizanColors.emerald800
                        : MizanColors.amber500,
                    foregroundColor:
                        goal.isCompleted ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: goal.isCompleted
                      ? null
                      : () => notifier.logProgress(goal.id, delta: 1),
                  icon: Icon(
                    goal.isCompleted
                        ? LucideIcons.checkCircle2
                        : Icons.add_circle_outline,
                    size: 14,
                  ),
                  label: Text(
                    goal.isCompleted ? 'Completed' : '+1 Log',
                    style: MizanTypography.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: goal.isCompleted ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: MizanColors.borderEmerald),
                  ),
                  onPressed: () => _openGoalEditorSheet(existing: goal),
                  icon: const Icon(Icons.edit_outlined,
                      size: 14, color: MizanColors.emerald300),
                  label: Text(
                    'Edit',
                    style: MizanTypography.body(
                        fontSize: 11, color: MizanColors.emerald300),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: MizanColors.borderSubtle),
                  ),
                  onPressed: () => notifier.togglePause(goal.id),
                  icon: Icon(
                    goal.isPaused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    size: 15,
                    color: MizanColors.slate300,
                  ),
                  label: Text(
                    goal.isPaused ? 'Resume' : 'Pause',
                    style: MizanTypography.body(
                        fontSize: 11, color: MizanColors.slate300),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete Goal',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmDelete(goal),
                  icon: const Icon(Icons.delete_outline,
                      size: 17, color: MizanColors.rose400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyDots(PersonalGoal goal) {
    final now = DateTime.now();
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      children: [
        Text(
          '7d Log:',
          style: MizanTypography.code(
            fontSize: 9.5,
            color: MizanColors.slate400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: List.generate(7, (idx) {
              final dayDate = now.subtract(Duration(days: 6 - idx));
              final iso = dayDate.toIso8601String().split('T').first;
              final active = goal.completedLogs.contains(iso);
              final letter = dayLetters[dayDate.weekday - 1];
              return Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? MizanColors.emerald500.withAlpha(70)
                      : MizanColors.bgDeep,
                  border: Border.all(
                    color: active
                        ? MizanColors.emerald400
                        : MizanColors.borderSubtle,
                  ),
                ),
                child: Text(
                  letter,
                  style: MizanTypography.code(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: active ? MizanColors.emerald300 : MizanColors.slate500,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _GoalEditorSheet extends ConsumerStatefulWidget {
  final PersonalGoal? existing;

  const _GoalEditorSheet({this.existing});

  @override
  ConsumerState<_GoalEditorSheet> createState() => _GoalEditorSheetState();
}

class _GoalEditorSheetState extends ConsumerState<_GoalEditorSheet> {
  static const List<String> _barakahSlots = [
    'Fajr Dawn',
    'Morning Sprint',
    'After Dhuhr',
    'After Asr',
    'After Maghrib',
    'After Isha',
  ];

  static const List<String> _unitPresets = [
    'sessions',
    'lessons',
    'modules',
    'pages',
    'ayahs',
    'tasks',
    'mins',
  ];

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _unitCtrl;

  late GoalCategory _category;
  late GoalCadence _cadence;
  late String _slot;
  late String _timeStr;
  late Set<int> _selectedDays;
  String? _targetDate;
  late bool _reminder;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _targetCtrl = TextEditingController(text: (e?.targetUnits ?? 10).toString());
    _unitCtrl = TextEditingController(text: e?.unitLabel ?? 'sessions');

    _category = e?.category ?? GoalCategory.learning;
    _cadence = e?.cadence ?? GoalCadence.daily;
    _slot = e?.scheduledSlot ?? 'Morning Sprint';
    if (!_barakahSlots.contains(_slot)) {
      _slot = _barakahSlots.first;
    }
    _timeStr = e?.scheduledTime ?? '08:30';
    _selectedDays =
        Set<int>.from(e?.scheduledDays ?? const [1, 2, 3, 4, 5]);
    _targetDate = e?.targetDate;
    _reminder = e?.reminderEnabled ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeOfDay(String raw) {
    final parts = raw.split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  String _categoryLabel(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.learning:
        return 'Learning';
      case GoalCategory.spiritual:
        return 'Spiritual';
      case GoalCategory.task:
        return 'Tasks & Work';
      case GoalCategory.wellness:
        return 'Wellbeing';
    }
  }

  Future<void> _save() async {
    final cleanTitle = _titleCtrl.text.trim();
    final parsedTarget = int.tryParse(_targetCtrl.text.trim()) ?? 0;
    if (cleanTitle.isEmpty) {
      setState(() => _errorMsg = 'Please enter a goal title.');
      return;
    }
    if (parsedTarget < 1) {
      setState(() => _errorMsg = 'Target units must be at least 1.');
      return;
    }
    final cleanUnit =
        _unitCtrl.text.trim().isEmpty ? 'sessions' : _unitCtrl.text.trim();
    final nowIso = DateTime.now().toIso8601String();
    final finalDays = _cadence == GoalCadence.daily
        ? const [1, 2, 3, 4, 5, 6, 7]
        : _cadence == GoalCadence.weekdays
            ? const [1, 2, 3, 4, 5]
            : (_selectedDays.toList()..sort());

    final existing = widget.existing;
    if (existing == null) {
      final created = PersonalGoal(
        id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
        title: cleanTitle,
        description: _descCtrl.text.trim(),
        category: _category,
        targetUnits: parsedTarget,
        completedUnits: 0,
        unitLabel: cleanUnit,
        cadence: _cadence,
        scheduledSlot: _slot,
        scheduledTime: _timeStr,
        scheduledDays: finalDays,
        targetDate: _targetDate,
        reminderEnabled: _reminder,
        completedLogs: const [],
        createdAt: nowIso,
        updatedAt: nowIso,
      );
      await ref.read(personalGoalsProvider.notifier).addGoal(created);
    } else {
      final updated = existing.copyWith(
        title: cleanTitle,
        description: _descCtrl.text.trim(),
        category: _category,
        targetUnits: parsedTarget,
        completedUnits: existing.completedUnits.clamp(0, parsedTarget),
        unitLabel: cleanUnit,
        cadence: _cadence,
        scheduledSlot: _slot,
        scheduledTime: _timeStr,
        scheduledDays: finalDays,
        targetDate: _targetDate,
        clearTargetDate: _targetDate == null,
        reminderEnabled: _reminder,
        updatedAt: nowIso,
      );
      await ref.read(personalGoalsProvider.notifier).updateGoal(updated);
    }

    ref.read(goalReminderProvider.notifier).evaluateDueGoals();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          14,
          18,
          bottomInset + bottomPad + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: MizanColors.borderEmerald,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(LucideIcons.target,
                      size: 18, color: MizanColors.amber400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.existing == null
                          ? 'Create & Schedule Personal Goal'
                          : 'Edit Personal Goal',
                      style: MizanTypography.title(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x,
                        size: 18, color: MizanColors.slate400),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _titleCtrl,
                style: MizanTypography.body(fontSize: 13, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Goal Title (Learning or Task)',
                  hintText:
                      'e.g., Master Arabic Morphology or Complete Tax Filing',
                  hintStyle: MizanTypography.body(
                      fontSize: 11.5, color: MizanColors.slate500),
                  filled: true,
                  fillColor: MizanColors.bgInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: MizanColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                style:
                    MizanTypography.body(fontSize: 12.5, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Niyyah / Action Notes (Optional)',
                  filled: true,
                  fillColor: MizanColors.bgInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: MizanColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'CATEGORY',
                style: MizanTypography.code(
                    fontSize: 10, color: MizanColors.amber300),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: GoalCategory.values.map((c) {
                  final selected = _category == c;
                  return ChoiceChip(
                    selected: selected,
                    selectedColor: MizanColors.amber500,
                    backgroundColor: MizanColors.bgCardAlt,
                    label: Text(
                      _categoryLabel(c),
                      style: MizanTypography.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _category = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      style: MizanTypography.code(
                          fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Target Units',
                        filled: true,
                        fillColor: MizanColors.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: MizanColors.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _unitCtrl,
                      style: MizanTypography.body(
                          fontSize: 13, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Unit Label',
                        hintText: 'lessons / pages / tasks',
                        filled: true,
                        fillColor: MizanColors.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: MizanColors.borderSubtle),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _unitPresets.map((u) {
                  return ActionChip(
                    backgroundColor: MizanColors.bgCardAlt,
                    side: const BorderSide(color: MizanColors.borderSubtle),
                    label: Text(
                      u,
                      style: MizanTypography.code(
                          fontSize: 10, color: MizanColors.emerald300),
                    ),
                    onPressed: () => setState(() => _unitCtrl.text = u),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                'SCHEDULE CADENCE',
                style: MizanTypography.code(
                    fontSize: 10, color: MizanColors.amber300),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  (GoalCadence.daily, 'Daily'),
                  (GoalCadence.weekdays, 'Weekdays'),
                  (GoalCadence.customDays, 'Custom Days'),
                  (GoalCadence.oneTime, 'One-Time'),
                ].map((item) {
                  final selected = _cadence == item.$1;
                  return ChoiceChip(
                    selected: selected,
                    selectedColor: MizanColors.emerald500,
                    backgroundColor: MizanColors.bgCardAlt,
                    label: Text(
                      item.$2,
                      style: MizanTypography.body(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _cadence = item.$1),
                  );
                }).toList(),
              ),
              if (_cadence == GoalCadence.customDays) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (int d = 1; d <= 7; d++)
                      FilterChip(
                        selected: _selectedDays.contains(d),
                        selectedColor: MizanColors.amber500,
                        backgroundColor: MizanColors.bgCardAlt,
                        label: Text(
                          const [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ][d - 1],
                          style: MizanTypography.body(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: _selectedDays.contains(d)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        onSelected: (on) {
                          setState(() {
                            if (on) {
                              _selectedDays.add(d);
                            } else if (_selectedDays.length > 1) {
                              _selectedDays.remove(d);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _slot,
                dropdownColor: MizanColors.bgCardElevated,
                style:
                    MizanTypography.body(fontSize: 12.5, color: Colors.white),
                decoration: InputDecoration(
                  labelText: '24h Barakah Anchor Window',
                  filled: true,
                  fillColor: MizanColors.bgInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: MizanColors.borderSubtle),
                  ),
                ),
                items: _barakahSlots
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _slot = v);
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MizanColors.borderEmerald),
                    ),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _parseTimeOfDay(_timeStr),
                      );
                      if (picked != null) {
                        final hh = picked.hour.toString().padLeft(2, '0');
                        final mm = picked.minute.toString().padLeft(2, '0');
                        setState(() => _timeStr = '$hh:$mm');
                      }
                    },
                    icon: const Icon(LucideIcons.clock,
                        size: 14, color: MizanColors.amber300),
                    label: Text(
                      'Time: $_timeStr',
                      style: MizanTypography.code(
                          fontSize: 11.5, color: Colors.white),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: MizanColors.borderEmerald),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final initDate = _targetDate != null
                          ? DateTime.tryParse(_targetDate!) ?? now
                          : now.add(const Duration(days: 7));
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initDate,
                        firstDate: now.subtract(const Duration(days: 30)),
                        lastDate: now.add(const Duration(days: 1095)),
                      );
                      if (picked != null) {
                        setState(() => _targetDate =
                            picked.toIso8601String().split('T').first);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined,
                        size: 14, color: MizanColors.emerald300),
                    label: Text(
                      _targetDate == null
                          ? 'Set Target Date'
                          : 'Due: $_targetDate',
                      style: MizanTypography.code(
                          fontSize: 11.5, color: Colors.white),
                    ),
                  ),
                  if (_targetDate != null)
                    IconButton(
                      tooltip: 'Clear Target Date',
                      onPressed: () => setState(() => _targetDate = null),
                      icon: const Icon(Icons.cancel_outlined,
                          size: 17, color: MizanColors.slate400),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Gentle Barakah Reminder Cue',
                  style: MizanTypography.body(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                value: _reminder,
                activeColor: MizanColors.emerald400,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errorMsg!,
                  style: MizanTypography.body(
                    fontSize: 11.5,
                    color: MizanColors.rose400,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              MizanIconButton(
                label: widget.existing == null
                    ? 'Save & Schedule Goal'
                    : 'Update Goal',
                icon: LucideIcons.checkCircle2,
                fullWidth: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

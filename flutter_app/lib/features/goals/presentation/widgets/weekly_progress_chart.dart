import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class _DayBucket {
  final DateTime date;
  final String iso;
  final String shortLabel;
  final String fullLabel;
  final bool isToday;
  final int loggedGoalsCount;
  final int scheduledGoalsCount;
  final double completionRatio; // 0.0 .. 1.0
  final List<PersonalGoal> loggedGoals;

  const _DayBucket({
    required this.date,
    required this.iso,
    required this.shortLabel,
    required this.fullLabel,
    required this.isToday,
    required this.loggedGoalsCount,
    required this.scheduledGoalsCount,
    required this.completionRatio,
    required this.loggedGoals,
  });
}

class WeeklyProgressChart extends ConsumerStatefulWidget {
  const WeeklyProgressChart({super.key});

  @override
  ConsumerState<WeeklyProgressChart> createState() =>
      _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends ConsumerState<WeeklyProgressChart> {
  int _selectedDayIndex = 6; // Defaults to Today (last of the 7-day window)

  bool _isScheduledForDate(PersonalGoal g, DateTime day) {
    if (g.isPaused) return false;
    final weekday = day.weekday;
    switch (g.cadence) {
      case GoalCadence.daily:
        return true;
      case GoalCadence.weekdays:
        return weekday >= 1 && weekday <= 5;
      case GoalCadence.customDays:
        return g.scheduledDays.contains(weekday);
      case GoalCadence.oneTime:
        return !g.isCompleted ||
            g.completedLogs.contains(day.toIso8601String().split('T').first);
    }
  }

  List<_DayBucket> _buildBuckets(
    List<PersonalGoal> goals,
    StreaksState streaks,
  ) {
    final now = DateTime.now();
    const dayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthAbbr = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return List.generate(7, (idx) {
      final raw = now.subtract(Duration(days: 6 - idx));
      final date = DateTime(raw.year, raw.month, raw.day);
      final iso = date.toIso8601String().split('T').first;
      final isToday = idx == 6;

      final scheduled = goals.where((g) => _isScheduledForDate(g, date)).toList();
      final logged = goals.where((g) => g.completedLogs.contains(iso)).toList();

      final sunnahTotal = streaks.sunnahs.length;
      final sunnahBonusLogged = isToday ? streaks.completedTodayCount : 0;
      final sunnahBonusDenom = isToday ? sunnahTotal : 0;

      final numerator = logged.length + sunnahBonusLogged;
      final denominator =
          math.max(1, scheduled.length + sunnahBonusDenom);
      final ratio = (numerator / denominator).clamp(0.0, 1.0);

      final shortLabel = isToday ? 'Today' : dayAbbr[date.weekday - 1];
      final fullLabel =
          '${isToday ? 'Today' : dayAbbr[date.weekday - 1]} · ${monthAbbr[date.month - 1]} ${date.day}';

      return _DayBucket(
        date: date,
        iso: iso,
        shortLabel: shortLabel,
        fullLabel: fullLabel,
        isToday: isToday,
        loggedGoalsCount: logged.length,
        scheduledGoalsCount: scheduled.length,
        completionRatio: ratio,
        loggedGoals: logged,
      );
    });
  }

  Color _catColor(GoalCategory cat) {
    switch (cat) {
      case GoalCategory.learning:
        return MizanColors.cyan400;
      case GoalCategory.spiritual:
        return MizanColors.amber400;
      case GoalCategory.task:
        return MizanColors.sky400;
      case GoalCategory.wellness:
        return MizanColors.emerald400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(personalGoalsProvider);
    final streaks = ref.watch(streaksProvider);
    final buckets = _buildBuckets(goals, streaks);

    final selectedIdx = _selectedDayIndex.clamp(0, buckets.length - 1);
    final selected = buckets[selectedIdx];

    final total7dCheckIns =
        buckets.fold<int>(0, (sum, b) => sum + b.loggedGoalsCount);
    final avgRatio = buckets.isEmpty
        ? 0.0
        : buckets.map((b) => b.completionRatio).reduce((a, b) => a + b) /
            buckets.length;
    final avgPercent = (avgRatio * 100).round();

    _DayBucket bestBucket = buckets.first;
    for (final b in buckets) {
      if (b.completionRatio > bestBucket.completionRatio ||
          (b.completionRatio == bestBucket.completionRatio &&
              b.loggedGoalsCount > bestBucket.loggedGoalsCount)) {
        bestBucket = b;
      }
    }

    return MizanCard(
      padding: const EdgeInsets.all(16),
      gradient: const LinearGradient(
        colors: [Color(0xFF0A2422), Color(0xFF061613)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: MizanColors.emerald400.withAlpha(115),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MizanColors.emerald500.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: MizanColors.emerald400.withAlpha(102),
                  ),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: MizanColors.emerald300,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY PROGRESS ANALYTICS',
                      style: MizanTypography.code(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: MizanColors.emerald300,
                      ),
                    ),
                    Text(
                      '7-Day Consistency & Momentum',
                      style: MizanTypography.title(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: MizanColors.amber500.withAlpha(32),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: MizanColors.amber400.withAlpha(115),
                  ),
                ),
                child: Text(
                  '$avgPercent% Avg',
                  style: MizanTypography.code(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: MizanColors.amber300,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary KPI Strip
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 380;
              return GridView.count(
                crossAxisCount: narrow ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: narrow ? 2.2 : 1.7,
                children: [
                  _miniStat(
                    '7d Logs',
                    '$total7dCheckIns',
                    MizanColors.cyan400,
                  ),
                  _miniStat(
                    'Hit Rate',
                    '$avgPercent%',
                    MizanColors.amber400,
                  ),
                  _miniStat(
                    'Peak Day',
                    bestBucket.shortLabel,
                    MizanColors.emerald400,
                  ),
                  _miniStat(
                    'Sunnah',
                    '${streaks.completedTodayCount}/${streaks.sunnahs.length}',
                    MizanColors.sky400,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Responsive Interactive CustomPaint Chart
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final chartHeight = chartWidth > 540 ? 184.0 : 156.0;
              final slotWidth = chartWidth / 7;

              return Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final tapped =
                          (details.localPosition.dx / slotWidth).floor();
                      setState(() {
                        _selectedDayIndex = tapped.clamp(0, 6);
                      });
                    },
                    child: SizedBox(
                      width: chartWidth,
                      height: chartHeight,
                      child: CustomPaint(
                        painter: _WeeklyBarTrendPainter(
                          buckets: buckets,
                          selectedIndex: selectedIdx,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(buckets.length, (i) {
                      final b = buckets[i];
                      final isSelected = i == selectedIdx;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _selectedDayIndex = i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? MizanColors.amber500.withAlpha(42)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color:
                                          MizanColors.amber400.withAlpha(140),
                                    )
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  b.shortLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MizanTypography.code(
                                    fontSize: 9.5,
                                    fontWeight: isSelected || b.isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? MizanColors.amber300
                                        : b.isToday
                                            ? MizanColors.emerald300
                                            : MizanColors.slate400,
                                  ),
                                ),
                                Text(
                                  '${(b.completionRatio * 100).round()}%',
                                  style: MizanTypography.code(
                                    fontSize: 8.5,
                                    color: isSelected
                                        ? Colors.white
                                        : MizanColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),

          // Legend Row
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _legendDot(MizanColors.emerald400, 'Daily Goal Volume'),
              _legendDot(MizanColors.amber400, 'Momentum Trend %'),
              _legendDot(MizanColors.slate400, 'Tap Any Bar to Inspect'),
            ],
          ),
          const SizedBox(height: 12),

          // Selected Day Breakdown Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MizanColors.bgDeep.withAlpha(200),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MizanColors.borderEmerald),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.target,
                      size: 14,
                      color: MizanColors.amber300,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Day Breakdown · ${selected.fullLabel}',
                        style: MizanTypography.body(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${selected.loggedGoalsCount}/${math.max(1, selected.scheduledGoalsCount)} goals',
                      style: MizanTypography.code(
                        fontSize: 10.5,
                        color: MizanColors.emerald300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (selected.loggedGoals.isEmpty)
                  Text(
                    selected.isToday
                        ? 'No goals checked in yet today. Tap "+1 Log" on any goal below to record progress.'
                        : 'No check-ins recorded on ${selected.fullLabel}.',
                    style: MizanTypography.body(
                      fontSize: 11.5,
                      color: MizanColors.slate400,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selected.loggedGoals.map((g) {
                      final color = _catColor(g.category);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withAlpha(28),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withAlpha(115)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.checkCircle2,
                              size: 11.5,
                              color: color,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              g.title,
                              style: MizanTypography.body(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                if (selected.isToday && streaks.completedTodayCount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    '+ ${streaks.completedTodayCount} daily Micro-Sunnahs completed today',
                    style: MizanTypography.code(
                      fontSize: 10,
                      color: MizanColors.amber300,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MizanColors.bgDeep.withAlpha(185),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MizanColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MizanTypography.body(
              fontSize: 9.5,
              color: MizanColors.slate400,
            ),
          ),
          Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MizanTypography.code(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: MizanTypography.body(
            fontSize: 10.5,
            color: MizanColors.slate300,
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarTrendPainter extends CustomPainter {
  final List<_DayBucket> buckets;
  final int selectedIndex;

  const _WeeklyBarTrendPainter({
    required this.buckets,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty) return;

    const topPad = 18.0;
    const bottomPad = 8.0;
    final plotHeight = math.max(20.0, size.height - topPad - bottomPad);
    final slotWidth = size.width / buckets.length;
    final barWidth = math.min(28.0, slotWidth * 0.46);

    // Subtle horizontal guide lines at 100%, 50%, 0%
    final gridPaint = Paint()
      ..color = MizanColors.borderSubtle.withAlpha(160)
      ..strokeWidth = 1;

    for (final frac in [0.0, 0.5, 1.0]) {
      final y = topPad + plotHeight * (1.0 - frac);
      _drawDashedLine(
        canvas,
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final trendPoints = <Offset>[];

    for (int i = 0; i < buckets.length; i++) {
      final b = buckets[i];
      final centerX = slotWidth * i + slotWidth / 2;
      final isSelected = i == selectedIndex;

      // Minimum stub bar so even 0% days remain cleanly visible & tappable
      final visualFrac = b.completionRatio <= 0 ? 0.06 : b.completionRatio;
      final barH = plotHeight * visualFrac;
      final barTop = topPad + plotHeight - barH;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - barWidth / 2,
          barTop,
          barWidth,
          barH,
        ),
        const Radius.circular(7),
      );

      if (isSelected) {
        final highlightBg = Paint()
          ..color = MizanColors.amber500.withAlpha(24)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              slotWidth * i + 3,
              topPad - 4,
              slotWidth - 6,
              plotHeight + 8,
            ),
            const Radius.circular(10),
          ),
          highlightBg,
        );
      }

      final barPaint = Paint()
        ..shader = LinearGradient(
          colors: b.completionRatio <= 0
              ? [
                  MizanColors.slate700.withAlpha(120),
                  MizanColors.bgCardElevated,
                ]
              : isSelected
                  ? const [MizanColors.amber400, MizanColors.emerald400]
                  : const [MizanColors.emerald300, MizanColors.emerald700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect.outerRect);

      canvas.drawRRect(rect, barPaint);

      if (isSelected) {
        final borderPaint = Paint()
          ..color = MizanColors.amber300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawRRect(rect, borderPaint);
      }

      // Draw count label above bar
      final countText = b.loggedGoalsCount > 0 ? '${b.loggedGoalsCount}' : '0';
      final tp = TextPainter(
        text: TextSpan(
          text: countText,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? MizanColors.amber300
                : b.loggedGoalsCount > 0
                    ? MizanColors.emerald300
                    : MizanColors.slate500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(centerX - tp.width / 2, math.max(0, barTop - 15)),
      );

      final pointY = topPad + plotHeight * (1.0 - b.completionRatio);
      trendPoints.add(Offset(centerX, pointY));
    }

    // Smooth trend polyline across the 7 days
    if (trendPoints.length >= 2) {
      final path = Path()..moveTo(trendPoints.first.dx, trendPoints.first.dy);
      for (int i = 0; i < trendPoints.length - 1; i++) {
        final p0 = trendPoints[i];
        final p1 = trendPoints[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      }
      final linePaint = Paint()
        ..color = MizanColors.amber400.withAlpha(220)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);

      for (int i = 0; i < trendPoints.length; i++) {
        final pt = trendPoints[i];
        final isSelected = i == selectedIndex;
        canvas.drawCircle(
          pt,
          isSelected ? 4.5 : 3.0,
          Paint()..color = MizanColors.bgDeep,
        );
        canvas.drawCircle(
          pt,
          isSelected ? 3.5 : 2.2,
          Paint()
            ..color =
                isSelected ? Colors.white : MizanColors.amber300,
        );
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double x = start.dx;
    while (x < end.dx) {
      final nextX = math.min(x + dashWidth, end.dx);
      canvas.drawLine(Offset(x, start.dy), Offset(nextX, end.dy), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarTrendPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.buckets != buckets;
  }
}

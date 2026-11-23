import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import confetti from 'canvas-confetti';
import {
  Flame,
  Award,
  Sparkles,
  Shield,
  Sun,
  Moon,
  Crown,
  CheckCircle2,
  Lock,
  HeartHandshake,
  Info,
  RefreshCw,
  Zap,
  TrendingUp,
  Check
} from 'lucide-react';
import { MilestoneBadge, MicroSunnah } from '../types';
import { INITIAL_MILESTONE_BADGES, INITIAL_MICRO_SUNNAHS } from '../data/mockData';

interface StreaksAndRewardsViewProps {
  onOpenCodeFile?: (path: string) => void;
}

export const StreaksAndRewardsView: React.FC<StreaksAndRewardsViewProps> = ({
  onOpenCodeFile,
}) => {
  const [badges, setBadges] = useState<MilestoneBadge[]>(INITIAL_MILESTONE_BADGES);
  const [habits, setHabits] = useState<MicroSunnah[]>(INITIAL_MICRO_SUNNAHS);
  const [graceDays, setGraceDays] = useState(2);
  const [selectedBadge, setSelectedBadge] = useState<MilestoneBadge | null>(null);
  const [celebrationBadge, setCelebrationBadge] = useState<MilestoneBadge | null>(null);

  // Trigger habit completion and streak increment
  const handleToggleHabit = (id: string) => {
    setHabits((prev) =>
      prev.map((h) => {
        if (h.id === id) {
          const isNowCompleted = !h.completed;
          const newStreak = isNowCompleted ? h.streakDays + 1 : Math.max(0, h.streakDays - 1);
          const newLongest = Math.max(h.longestStreak, newStreak);

          if (isNowCompleted) {
            confetti({
              particleCount: 35,
              spread: 65,
              origin: { y: 0.65 },
              colors: ['#cfa859', '#10b981', '#34d399', '#f3df9f'],
            });

            // Check if this triggers the 7-day or 14-day milestone
            if (newStreak === 7) {
              const target = badges.find((b) => b.id === 'badge-istiqamah');
              if (target) triggerBadgeCelebration(target);
            } else if (newStreak === 14) {
              const target = badges.find((b) => b.id === 'badge-noor-fajr');
              if (target) triggerBadgeCelebration(target);
            } else if (newStreak === 21) {
              const target = badges.find((b) => b.id === 'badge-taqwa-shield');
              if (target) triggerBadgeCelebration(target);
            }
          }

          return {
            ...h,
            completed: isNowCompleted,
            streakDays: newStreak,
            longestStreak: newLongest,
            lastCompletedDate: isNowCompleted ? new Date().toISOString().split('T')[0] : h.lastCompletedDate,
          };
        }
        return h;
      })
    );
  };

  const triggerBadgeCelebration = (badge: MilestoneBadge) => {
    // Unlock badge
    setBadges((prev) =>
      prev.map((b) => (b.id === badge.id ? { ...b, unlocked: true, unlockedAt: 'Just now' } : b))
    );
    setCelebrationBadge(badge);
    confetti({
      particleCount: 70,
      spread: 90,
      origin: { y: 0.5 },
      colors: ['#cfa859', '#38bdf8', '#10b981', '#f59e0b'],
    });
  };

  // Render badge icon according to string identifier
  const renderBadgeIcon = (icon: string, unlocked: boolean) => {
    const className = `w-7 h-7 ${unlocked ? 'text-amber-300' : 'text-slate-500'}`;
    switch (icon) {
      case 'Moon':
        return <Moon className={className} />;
      case 'Sun':
        return <Sun className={className} />;
      case 'Shield':
        return <Shield className={className} />;
      case 'Crown':
        return <Crown className={className} />;
      case 'Flame':
        return <Flame className={className} />;
      default:
        return <Sparkles className={className} />;
    }
  };

  const totalCompletions = habits.reduce((acc, curr) => acc + curr.streakDays, 0);
  const highestStreak = Math.max(...habits.map((h) => h.longestStreak));
  const unlockedCount = badges.filter((b) => b.unlocked).length;

  return (
    <div className="space-y-6">
      {/* Overview Stats Bar */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <div className="p-4 rounded-2xl bg-[#09221b] border border-emerald-800/60 shadow-lg">
          <div className="flex items-center justify-between">
            <span className="text-xs text-emerald-300/80 font-medium">Longest Active Streak</span>
            <Flame className="w-4 h-4 text-amber-400" />
          </div>
          <div className="flex items-baseline gap-1 mt-1">
            <span className="text-2xl font-mono font-bold text-amber-300">{highestStreak}</span>
            <span className="text-xs text-emerald-400 font-mono">days</span>
          </div>
          <p className="text-[11px] text-emerald-300/60 mt-0.5">Siwak &amp; Oral Purification</p>
        </div>

        <div className="p-4 rounded-2xl bg-[#09221b] border border-emerald-800/60 shadow-lg">
          <div className="flex items-center justify-between">
            <span className="text-xs text-emerald-300/80 font-medium">Unlocked Milestones</span>
            <Award className="w-4 h-4 text-emerald-400" />
          </div>
          <div className="flex items-baseline gap-1 mt-1">
            <span className="text-2xl font-mono font-bold text-white">
              {unlockedCount} / {badges.length}
            </span>
          </div>
          <p className="text-[11px] text-emerald-300/60 mt-0.5">Next at 21 days (Shield)</p>
        </div>

        <div className="p-4 rounded-2xl bg-[#09221b] border border-emerald-800/60 shadow-lg">
          <div className="flex items-center justify-between">
            <span className="text-xs text-emerald-300/80 font-medium">Total Consistent Days</span>
            <TrendingUp className="w-4 h-4 text-cyan-400" />
          </div>
          <div className="flex items-baseline gap-1 mt-1">
            <span className="text-2xl font-mono font-bold text-cyan-300">{totalCompletions}</span>
            <span className="text-xs text-emerald-400 font-mono">logs</span>
          </div>
          <p className="text-[11px] text-emerald-300/60 mt-0.5">Zero network / 100% offline</p>
        </div>

        <div className="p-4 rounded-2xl bg-[#09221b] border border-emerald-800/60 shadow-lg">
          <div className="flex items-center justify-between">
            <span className="text-xs text-emerald-300/80 font-medium">Istighfar Grace Days</span>
            <HeartHandshake className="w-4 h-4 text-amber-300" />
          </div>
          <div className="flex items-baseline gap-1 mt-1">
            <span className="text-2xl font-mono font-bold text-amber-200">{graceDays}</span>
            <span className="text-xs text-emerald-400 font-mono">tokens</span>
          </div>
          <p className="text-[11px] text-emerald-300/60 mt-0.5">Ethical non-punitive buffer</p>
        </div>
      </div>

      {/* Main Grid: Habits with Streaks & Milestones Showcase */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: Habit Streaks List (7 cols) */}
        <div className="lg:col-span-7 space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-serif text-lg font-bold text-white flex items-center gap-2">
                <Flame className="w-5 h-5 text-amber-400" />
                Active Micro-Sunnah Streaks
              </h3>
              <p className="text-xs text-emerald-300/70">
                Click a habit to mark today's completion and test instant streak progression.
              </p>
            </div>
            {onOpenCodeFile && (
              <button
                onClick={() =>
                  onOpenCodeFile(
                    'lib/features/streaks/presentation/providers/habit_streak_provider.dart'
                  )
                }
                className="text-xs text-amber-300 hover:underline font-mono"
              >
                Inspect Riverpod Provider
              </button>
            )}
          </div>

          <div className="space-y-3">
            {habits.map((habit) => {
              const nextMilestone =
                habit.streakDays < 3
                  ? 3
                  : habit.streakDays < 7
                  ? 7
                  : habit.streakDays < 14
                  ? 14
                  : habit.streakDays < 21
                  ? 21
                  : habit.streakDays < 30
                  ? 30
                  : 40;
              const progressPercent = Math.min(100, (habit.streakDays / nextMilestone) * 100);

              return (
                <div
                  key={habit.id}
                  className={`p-4 rounded-2xl border transition-all ${
                    habit.completed
                      ? 'bg-[#0a271f] border-emerald-700/60 shadow-sm'
                      : 'bg-[#081e18] border-emerald-900/60 hover:border-emerald-700/50'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-start gap-3">
                      <button
                        onClick={() => handleToggleHabit(habit.id)}
                        className={`mt-0.5 w-6 h-6 rounded-lg flex items-center justify-center border transition-all ${
                          habit.completed
                            ? 'bg-amber-400 border-amber-400 text-black shadow-md shadow-amber-400/20'
                            : 'border-emerald-700 bg-emerald-950/80 hover:border-amber-400'
                        }`}
                        title="Click to toggle today's completion"
                      >
                        {habit.completed && <Check className="w-4 h-4 stroke-[3]" />}
                      </button>

                      <div>
                        <div className="flex items-center gap-2">
                          <h4 className="font-medium text-sm text-white">{habit.title}</h4>
                          <span className="font-arabic text-xs text-amber-300/80">
                            {habit.arabicTitle}
                          </span>
                        </div>
                        <p className="text-xs text-emerald-300/70 mt-0.5 line-clamp-1">
                          {habit.hadithReference}
                        </p>
                      </div>
                    </div>

                    {/* Streak Flame Pill */}
                    <div className="flex flex-col items-end">
                      <div className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-amber-500/15 border border-amber-400/30 text-amber-300 text-xs font-mono font-bold">
                        <Flame className="w-3.5 h-3.5 fill-amber-400 text-amber-400 animate-pulse" />
                        <span>{habit.streakDays}d</span>
                      </div>
                      <span className="text-[10px] text-emerald-400/70 font-mono mt-1">
                        Best: {habit.longestStreak}d
                      </span>
                    </div>
                  </div>

                  {/* Milestone Progress Bar */}
                  <div className="mt-3 pt-2.5 border-t border-emerald-900/40">
                    <div className="flex items-center justify-between text-[11px] mb-1">
                      <span className="text-emerald-300/70 font-mono">
                        Progress to next milestone ({nextMilestone}d)
                      </span>
                      <span className="text-amber-200/90 font-mono font-semibold">
                        {habit.streakDays} / {nextMilestone} days
                      </span>
                    </div>
                    <div className="w-full h-1.5 rounded-full bg-emerald-950 overflow-hidden border border-emerald-900/40">
                      <motion.div
                        className="h-full bg-gradient-to-r from-emerald-500 via-teal-400 to-amber-400 rounded-full"
                        initial={{ width: 0 }}
                        animate={{ width: `${progressPercent}%` }}
                        transition={{ duration: 0.5, ease: 'easeOut' }}
                      />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Right Column: Islamic Milestone Badges Gallery (5 cols) */}
        <div className="lg:col-span-5 space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-serif text-lg font-bold text-white flex items-center gap-2">
                <Award className="w-5 h-5 text-amber-400" />
                Islamic Milestones Gallery
              </h3>
              <p className="text-xs text-emerald-300/70">
                Purely offline badges earned through Istiqamah (Steadfastness).
              </p>
            </div>
            <button
              onClick={() => {
                const target = badges.find((b) => !b.unlocked) || badges[0];
                triggerBadgeCelebration(target);
              }}
              className="py-1 px-2.5 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-200 text-xs font-medium transition-colors"
            >
              Test Unlock Modal
            </button>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {badges.map((badge) => {
              const isUnlocked = badge.unlocked;
              return (
                <div
                  key={badge.id}
                  onClick={() => setSelectedBadge(badge)}
                  className={`p-3.5 rounded-2xl border transition-all cursor-pointer relative overflow-hidden flex flex-col justify-between ${
                    isUnlocked
                      ? 'bg-gradient-to-b from-[#0e332a] to-[#071d17] border-amber-400/50 shadow-lg shadow-emerald-950/40 hover:scale-[1.02]'
                      : 'bg-[#061814]/70 border-emerald-950/80 opacity-60 hover:opacity-75'
                  }`}
                >
                  {isUnlocked && (
                    <div className="absolute top-2 right-2">
                      <span className="w-2 h-2 rounded-full bg-emerald-400 inline-block shadow-sm shadow-emerald-400" />
                    </div>
                  )}

                  <div>
                    {/* Badge Icon Chassis */}
                    <div
                      className={`w-12 h-12 rounded-2xl flex items-center justify-center border mx-auto mb-2 transition-all ${
                        isUnlocked
                          ? 'bg-gradient-to-tr from-[#1b443a] to-[#0d2a23] border-amber-400/60 shadow-inner'
                          : 'bg-emerald-950/40 border-emerald-900/40'
                      }`}
                    >
                      {isUnlocked ? (
                        renderBadgeIcon(badge.icon, true)
                      ) : (
                        <Lock className="w-5 h-5 text-emerald-600" />
                      )}
                    </div>

                    <div className="text-center">
                      <h4
                        className={`font-serif text-xs font-bold ${
                          isUnlocked ? 'text-amber-200' : 'text-slate-400'
                        }`}
                      >
                        {badge.name}
                      </h4>
                      <span className="font-arabic text-[11px] text-emerald-300/80 block mt-0.5">
                        {badge.arabicName}
                      </span>
                    </div>
                  </div>

                  <div className="mt-3 pt-2 border-t border-emerald-900/40 flex items-center justify-between text-[10px] font-mono">
                    <span className="text-emerald-400">{badge.requiredDays} Days</span>
                    <span
                      className={`uppercase font-bold ${
                        badge.tier === 'emerald'
                          ? 'text-emerald-300'
                          : badge.tier === 'gold'
                          ? 'text-amber-300'
                          : badge.tier === 'silver'
                          ? 'text-slate-300'
                          : 'text-amber-600'
                      }`}
                    >
                      {badge.tier}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Ethical Gamification Policy Card */}
          <div className="p-4 rounded-2xl bg-[#071b16] border border-emerald-800/50 space-y-2">
            <div className="flex items-center gap-2 text-amber-300 font-semibold text-xs">
              <Shield className="w-4 h-4 text-amber-400" />
              <span>Ethical Gamification Constitution</span>
            </div>
            <p className="text-[11px] text-emerald-200/80 leading-relaxed">
              Mīzān explicitly rejects dark patterns:
              <br />
              • <strong>No Loss-Aversion Shaming:</strong> You are never guilt-tripped or threatened if life interrupts a streak.
              <br />
              • <strong>Istighfar Grace Days:</strong> 2 non-punitive grace days automatically buffer sick days or travel.
              <br />
              • <strong>Intrinsic Spiritual Meaning:</strong> Badges connect back to authentic Hadith on perseverance, not dopamine addiction.
            </p>
          </div>
        </div>
      </div>

      {/* Detail Modal for Selected Badge */}
      <AnimatePresence>
        {selectedBadge && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="w-full max-w-md p-6 rounded-3xl bg-[#061814] border-2 border-amber-400/60 shadow-2xl text-white space-y-4 relative"
            >
              <div className="text-center">
                <div className="w-16 h-16 rounded-2xl bg-[#13382f] border-2 border-amber-400/80 flex items-center justify-center mx-auto mb-3 shadow-lg">
                  {renderBadgeIcon(selectedBadge.icon, selectedBadge.unlocked)}
                </div>
                <span className="font-arabic text-xl text-amber-300 font-bold block">
                  {selectedBadge.arabicName}
                </span>
                <h3 className="font-serif text-lg font-bold text-white mt-0.5">
                  {selectedBadge.name}
                </h3>
                <span className="text-xs font-mono text-emerald-400">
                  {selectedBadge.requiredDays} Days of Istiqamah ({selectedBadge.tier.toUpperCase()} TIER)
                </span>
              </div>

              <p className="text-xs text-emerald-100/90 text-center leading-relaxed">
                {selectedBadge.description}
              </p>

              {/* Hadith citation */}
              <div className="p-3 rounded-xl bg-[#0b2821] border border-emerald-800/50 text-center">
                <p className="text-xs italic text-amber-100">"{selectedBadge.virtueQuote}"</p>
                <p className="text-[10px] text-emerald-300/70 mt-1">
                  {selectedBadge.hadithReference}
                </p>
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => setSelectedBadge(null)}
                  className="w-full py-2 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-200 text-xs font-medium transition-colors"
                >
                  Close Badge Details
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Milestone Unlock Celebration Modal (Simulating Flutter MilestoneCelebrationDialog) */}
      <AnimatePresence>
        {celebrationBadge && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
            <motion.div
              initial={{ opacity: 0, scale: 0.85, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.85, y: 20 }}
              className="w-full max-w-sm p-6 rounded-3xl bg-gradient-to-b from-[#0c2f26] to-[#051713] border-2 border-amber-400 shadow-2xl text-white space-y-4 relative text-center"
            >
              <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-amber-500 to-amber-200 flex items-center justify-center mx-auto shadow-lg shadow-amber-400/30 text-black">
                <Crown className="w-10 h-10 fill-amber-950 text-amber-950" />
              </div>

              <div>
                <span className="text-[10px] uppercase font-mono tracking-widest text-amber-300 font-bold">
                  ★ Milestone Unlocked ★
                </span>
                <h3 className="font-arabic text-2xl font-bold text-amber-300 mt-1">
                  {celebrationBadge.arabicName}
                </h3>
                <h4 className="font-serif text-lg font-bold text-white">
                  {celebrationBadge.name}
                </h4>
                <p className="text-xs text-emerald-300/80 font-mono mt-0.5">
                  {celebrationBadge.requiredDays} Days of Steadfastness Achieved
                </p>
              </div>

              <div className="p-3 rounded-xl bg-[#071f19] border border-emerald-800/60">
                <p className="text-xs italic text-amber-100">"{celebrationBadge.virtueQuote}"</p>
                <p className="text-[10px] text-emerald-400/70 mt-1">
                  {celebrationBadge.hadithReference}
                </p>
              </div>

              <button
                onClick={() => setCelebrationBadge(null)}
                className="w-full py-2.5 rounded-xl bg-gradient-to-r from-amber-400 to-amber-500 text-black font-bold text-xs shadow-md hover:from-amber-300 hover:to-amber-400 transition-all"
              >
                Al-Hamdulillah • Continue Journey
              </button>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
};

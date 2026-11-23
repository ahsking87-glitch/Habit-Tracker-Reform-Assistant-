import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ShieldAlert, Compass, Sparkles, CheckCircle2, X, RefreshCw, Droplets, Sun, BookOpen } from 'lucide-react';
import { ShieldTriggerEvent } from '../types';

interface OverlayShieldModalProps {
  event: ShieldTriggerEvent | null;
  onDismiss: () => void;
  onSelectAlternative: (actionTitle: string) => void;
}

export const OverlayShieldModal: React.FC<OverlayShieldModalProps> = ({
  event,
  onDismiss,
  onSelectAlternative,
}) => {
  const [breathPhase, setBreathPhase] = useState<'inhale' | 'exhale'>('inhale');
  const [secondsRemaining, setSecondsRemaining] = useState(7);
  const [canConsciouslyUnlock, setCanConsciouslyUnlock] = useState(false);

  useEffect(() => {
    if (!event) return;
    setSecondsRemaining(7);
    setCanConsciouslyUnlock(false);

    const interval = setInterval(() => {
      setSecondsRemaining((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          setCanConsciouslyUnlock(true);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    const breathInterval = setInterval(() => {
      setBreathPhase((prev) => (prev === 'inhale' ? 'exhale' : 'inhale'));
    }, 3500);

    return () => {
      clearInterval(interval);
      clearInterval(breathInterval);
    };
  }, [event]);

  if (!event || !event.active) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0, scale: 0.96 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.96 }}
        className="absolute inset-0 z-50 flex flex-col justify-between bg-[#061814]/95 backdrop-blur-xl p-5 text-white overflow-y-auto"
      >
        {/* Top Header Badge */}
        <div>
          <div className="flex items-center justify-between pt-2">
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-950/80 border border-emerald-700/50 text-emerald-300 text-xs font-medium">
              <ShieldAlert className="w-3.5 h-3.5 text-amber-400" />
              <span>OS Overlay Shield Active</span>
            </div>
            <button
              onClick={onDismiss}
              className="text-emerald-300/60 hover:text-white p-1 rounded-lg hover:bg-emerald-900/40 transition-colors"
              title="Close simulator overlay"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* Trigger Context */}
          <div className="mt-4 text-center">
            <span className="text-[11px] uppercase tracking-widest text-amber-300/80 font-mono">
              Intervention Trigger
            </span>
            <h2 className="text-xl font-serif font-bold text-white mt-0.5">
              {event.targetApp === 'Salah Approaching'
                ? '🕌 Time for Salah Focus'
                : `A Mindful Pause (${event.targetApp})`}
            </h2>
            <p className="text-xs text-emerald-200/80 mt-1 max-w-xs mx-auto leading-relaxed">
              {event.targetApp === 'Salah Approaching'
                ? 'Adhan is approaching in moments. Reclaim your stillness and prepare for the divine audience.'
                : `You opened ${event.targetApp} during a focus window. Before the algorithm captures your attention, pause here.`}
            </p>
          </div>

          {/* Arabic Spiritual Verse Anchor */}
          <div className="mt-4 p-3 rounded-xl bg-emerald-950/40 border border-emerald-800/40 text-center">
            <p className="font-arabic text-lg text-amber-200 leading-relaxed dir-rtl">
              وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ
            </p>
            <p className="text-[10px] text-emerald-300/70 italic mt-1">
              "And seek help through patience and prayer..." (Surah Al-Baqarah 2:45)
            </p>
          </div>

          {/* Physiological Breathing Pacer */}
          <div className="mt-4 flex flex-col items-center">
            <div className="relative flex items-center justify-center w-28 h-28 my-1">
              <motion.div
                animate={{
                  scale: breathPhase === 'inhale' ? 1.25 : 0.85,
                  opacity: breathPhase === 'inhale' ? 0.9 : 0.5,
                }}
                transition={{ duration: 3.5, ease: 'easeInOut' }}
                className="absolute inset-0 rounded-full bg-gradient-to-tr from-emerald-600/30 to-amber-500/20 blur-md"
              />
              <motion.div
                animate={{
                  scale: breathPhase === 'inhale' ? 1.15 : 0.9,
                }}
                transition={{ duration: 3.5, ease: 'easeInOut' }}
                className="w-20 h-20 rounded-full border-2 border-amber-400/60 flex flex-col items-center justify-center bg-emerald-900/60 text-center shadow-inner"
              >
                <span className="text-[11px] font-mono font-bold text-amber-300 uppercase tracking-wider">
                  {breathPhase}
                </span>
                <span className="text-xs text-white/80 font-mono mt-0.5">
                  {secondsRemaining > 0 ? `${secondsRemaining}s` : '✓ Centered'}
                </span>
              </motion.div>
            </div>
            <p className="text-[11px] text-emerald-300/70 text-center">
              Physiological sigh: double inhale through the nose, long exhale through the mouth.
            </p>
          </div>
        </div>

        {/* 2-Minute Actionable Offline Alternatives */}
        <div className="mt-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs font-semibold text-amber-200 flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5 text-amber-400" />
              Immediate 2-Minute Alternatives
            </span>
            <span className="text-[10px] text-emerald-400 font-mono">Offline Ready</span>
          </div>

          <div className="grid grid-cols-2 gap-2 text-left">
            <button
              onClick={() => onSelectAlternative('Cool Wudu Refresh')}
              className="p-2.5 rounded-xl bg-emerald-950/70 hover:bg-emerald-900/80 border border-emerald-800/50 hover:border-amber-400/60 text-left transition-all group"
            >
              <div className="flex items-center gap-1.5 text-emerald-300 font-medium text-xs mb-1">
                <Droplets className="w-3.5 h-3.5 text-cyan-400" />
                <span>Wudu Reset</span>
              </div>
              <p className="text-[10px] text-emerald-200/70 leading-snug">
                Wash hands & face with cool water to activate physiological relaxation.
              </p>
            </button>

            <button
              onClick={() => onSelectAlternative('33x Tasbih Remembrance')}
              className="p-2.5 rounded-xl bg-emerald-950/70 hover:bg-emerald-900/80 border border-emerald-800/50 hover:border-amber-400/60 text-left transition-all group"
            >
              <div className="flex items-center gap-1.5 text-amber-300 font-medium text-xs mb-1">
                <Compass className="w-3.5 h-3.5 text-amber-400" />
                <span>33x Tasbih</span>
              </div>
              <p className="text-[10px] text-emerald-200/70 leading-snug">
                Recite 'SubhanAllah wa bihamdihi' with fingers to calm cognitive frenzy.
              </p>
            </button>

            <button
              onClick={() => onSelectAlternative('Read 5 Ayahs of Quran')}
              className="p-2.5 rounded-xl bg-emerald-950/70 hover:bg-emerald-900/80 border border-emerald-800/50 hover:border-amber-400/60 text-left transition-all group"
            >
              <div className="flex items-center gap-1.5 text-emerald-300 font-medium text-xs mb-1">
                <BookOpen className="w-3.5 h-3.5 text-emerald-400" />
                <span>5 Ayahs Quran</span>
              </div>
              <p className="text-[10px] text-emerald-200/70 leading-snug">
                Open Mizan's low-friction reader and feed the soul instead of the feed.
              </p>
            </button>

            <button
              onClick={() => onSelectAlternative('Horizon & Sky Gaze')}
              className="p-2.5 rounded-xl bg-emerald-950/70 hover:bg-emerald-900/80 border border-emerald-800/50 hover:border-amber-400/60 text-left transition-all group"
            >
              <div className="flex items-center gap-1.5 text-amber-300 font-medium text-xs mb-1">
                <Sun className="w-3.5 h-3.5 text-amber-400" />
                <span>Sky Horizon Gaze</span>
              </div>
              <p className="text-[10px] text-emerald-200/70 leading-snug">
                Step to a window, let your optic field widen, and contemplate creation.
              </p>
            </button>
          </div>
        </div>

        {/* Ethical Autonomy Guarantee (No Dark Patterns) */}
        <div className="pt-3 border-t border-emerald-900/60">
          <div className="flex items-center justify-between gap-2">
            <button
              disabled={!canConsciouslyUnlock}
              onClick={onDismiss}
              className={`flex-1 py-2 px-3 rounded-xl font-medium text-xs transition-all flex items-center justify-center gap-1.5 ${
                canConsciouslyUnlock
                  ? 'bg-amber-500/20 hover:bg-amber-500/30 text-amber-200 border border-amber-400/40 cursor-pointer'
                  : 'bg-emerald-950/40 text-emerald-500 border border-emerald-900/40 cursor-not-allowed opacity-60'
              }`}
            >
              {canConsciouslyUnlock ? (
                <>
                  <CheckCircle2 className="w-3.5 h-3.5 text-amber-400" />
                  <span>Conscious 15-Min Unlock</span>
                </>
              ) : (
                <>
                  <RefreshCw className="w-3 h-3 animate-spin" />
                  <span>Pause for {secondsRemaining}s...</span>
                </>
              )}
            </button>

            <button
              onClick={onDismiss}
              className="py-2 px-3 rounded-xl text-xs font-medium text-emerald-300/80 hover:text-white bg-emerald-950/60 border border-emerald-800/40 hover:bg-emerald-900/60 transition-colors"
            >
              Return Home
            </button>
          </div>
          <p className="text-[9px] text-emerald-400/50 text-center mt-1.5">
            Ethical Design: Mīzān never traps you. After a mindful breath, your autonomy is 100% respected.
          </p>
        </div>
      </motion.div>
    </AnimatePresence>
  );
};

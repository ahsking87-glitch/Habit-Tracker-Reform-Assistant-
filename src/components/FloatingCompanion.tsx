import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  Sparkles,
  Volume2,
  VolumeX,
  Clock,
  Shield,
  Eye,
  EyeOff,
  X,
  HelpCircle,
  Cpu,
  Bot,
  Heart,
} from 'lucide-react';
import { CompanionMood, FloatingCompanionConfig } from '../types';
import { companionAudio } from '../utils/companionSoundEngine';
import { loadGatewayConfig } from '../utils/aiGatewayClient';

interface FloatingCompanionProps {
  boundsWidth?: number;
  boundsHeight?: number;
  config: FloatingCompanionConfig;
  onUpdateConfig?: (config: FloatingCompanionConfig) => void;
  nextSalahName?: string;
  nextSalahMinutes?: number;
  activeAppTab?: string;
  screenMinutesRatio?: number;
  onOpenCodeFile?: (path: string) => void;
  onTriggerSalahAlert?: () => void;
  onTriggerScreenLimit?: () => void;
  onLaunchOnboarding?: () => void;
  onNavigatePhoneTab?: (tab: 'prayer' | 'shield' | 'quran' | 'planner' | 'coach' | 'profile') => void;
}

const TAB_CONTEXT_GUIDANCE: Record<string, { title: string; tip: string }> = {
  prayer: {
    title: 'Salah & Adhan Anchor',
    tip: 'Your solar prayer timetable stays 100% offline. Hover or tap Tour anytime for setup help.',
  },
  shield: {
    title: 'Mindful Shield Active',
    tip: 'Prominent Accessibility disclosure keeps Reels & Shorts paused calmly without guilt.',
  },
  quran: {
    title: 'Habit & Quran Logging',
    tip: 'Tap any Micro-Sunnah circle below to log a daily habit locally with instant celebration.',
  },
  planner: {
    title: '24h Circadian Alignment',
    tip: 'Sleep, Fajr, deep work, and Qaylulah blocks synchronize automatically with solar Adhan.',
  },
  coach: {
    title: 'Multi-AI OARS Coach',
    tip: 'Reflections route through your chosen BYOK provider or fall back to offline wisdom.',
  },
  profile: {
    title: 'Sovereign Local Vault',
    tip: 'Credentials and habit proofs stay encrypted inside on-device Hive & Keystore vaults.',
  },
};

export const FloatingCompanion: React.FC<FloatingCompanionProps> = ({
  boundsWidth = 356,
  boundsHeight = 640,
  config,
  onUpdateConfig,
  nextSalahName = 'Dhuhr',
  nextSalahMinutes = 35,
  activeAppTab = 'prayer',
  screenMinutesRatio = 0.5,
  onTriggerSalahAlert,
  onTriggerScreenLimit,
  onLaunchOnboarding,
  onNavigatePhoneTab,
}) => {
  const [position, setPosition] = useState({ x: 84, y: 30 });
  const [mood, setMood] = useState<CompanionMood>('serene');
  const [isHiding, setIsHiding] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [isAssistantPinned, setIsAssistantPinned] = useState(false);
  const [petScale, setPetScale] = useState({ x: 1, y: 1 });
  const [petCount, setPetCount] = useState(0);
  const [showPetHeart, setShowPetHeart] = useState(false);
  const [companionEnergy, setCompanionEnergy] = useState(88);

  const [activeAlertCard, setActiveAlertCard] = useState<{
    title: string;
    body: string;
    type: 'salah' | 'screentime' | 'habit';
  } | null>(null);

  const wanderTimerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const hoverCloseTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const salahTriggeredRef = useRef<boolean>(false);
  const screenTriggeredRef = useRef<boolean>(false);

  const gatewayConfig = loadGatewayConfig();

  useEffect(() => {
    companionAudio.setMuted(!config.soundEnabled);
    companionAudio.setVolume(config.soundVolume);
  }, [config.soundEnabled, config.soundVolume]);

  // Listen for Micro-Sunnah completion events to celebrate warmly without speech
  useEffect(() => {
    const onHabitLogged = () => {
      if (!config.enabled) return;
      companionAudio.playSound('habit_celebration');
      setMood('joyful');
      setCompanionEnergy((prev) => Math.min(100, prev + 4));
      setPetScale({ x: 1.2, y: 0.85 });
      setTimeout(() => setPetScale({ x: 1, y: 1 }), 220);
      setTimeout(() => setMood('serene'), 2400);
    };
    window.addEventListener('mizan:habit-logged', onHabitLogged);
    return () => window.removeEventListener('mizan:habit-logged', onHabitLogged);
  }, [config.enabled]);

  // Proactive non-verbal context cues (10m Salah threshold & high screen-time threshold)
  useEffect(() => {
    if (!config.enabled || isDragging || isHiding) return;

    if (nextSalahMinutes <= config.salahLeadMinutes && !salahTriggeredRef.current) {
      salahTriggeredRef.current = true;
      companionAudio.playSound('salah_10m');
      setMood('vigilant');
      setActiveAlertCard({
        title: `${nextSalahMinutes}m until ${nextSalahName}`,
        body: 'Pause gently to refresh wudu and prepare your heart for prayer.',
        type: 'salah',
      });
    } else if (nextSalahMinutes > config.salahLeadMinutes + 2) {
      salahTriggeredRef.current = false;
    }

    if (screenMinutesRatio >= 0.88 && !screenTriggeredRef.current) {
      screenTriggeredRef.current = true;
      companionAudio.playSound('screen_threshold');
      setMood('mindful');
      setActiveAlertCard({
        title: 'Mindful Screen Pause',
        body: 'You are nearing today’s quota. Step away for 2 minutes of calm dhikr.',
        type: 'screentime',
      });
    } else if (screenMinutesRatio < 0.7) {
      screenTriggeredRef.current = false;
    }
  }, [
    config.enabled,
    config.salahLeadMinutes,
    isDragging,
    isHiding,
    nextSalahMinutes,
    nextSalahName,
    screenMinutesRatio,
  ]);

  // Bounded autonomous edge-to-edge wandering
  useEffect(() => {
    if (
      !config.enabled ||
      isDragging ||
      isHiding ||
      isHovered ||
      isAssistantPinned ||
      config.wanderSpeed === 'stationary'
    ) {
      return;
    }

    const intervalMs = config.wanderSpeed === 'calm' ? 9500 : 5200;
    wanderTimerRef.current = setInterval(() => {
      const edgeSpots = [
        { x: 84, y: 24 },
        { x: 16, y: 28 },
        { x: 84, y: 66 },
        { x: 16, y: 64 },
      ];
      setPosition(edgeSpots[Math.floor(Math.random() * edgeSpots.length)]);
    }, intervalMs);

    return () => {
      if (wanderTimerRef.current) clearInterval(wanderTimerRef.current);
    };
  }, [config.enabled, config.wanderSpeed, isDragging, isHiding, isHovered, isAssistantPinned]);

  useEffect(() => {
    return () => {
      if (wanderTimerRef.current) clearInterval(wanderTimerRef.current);
      if (hoverCloseTimerRef.current) clearTimeout(hoverCloseTimerRef.current);
    };
  }, []);

  const handlePet = () => {
    if (isHiding) {
      togglePeekABoo();
      return;
    }
    setMood('joyful');
    setPetCount((c) => c + 1);
    setCompanionEnergy((prev) => Math.min(100, prev + 2));
    setShowPetHeart(true);
    companionAudio.playSound('interactive_tap');
    setPetScale({ x: 1.18, y: 0.84 });
    setTimeout(() => setPetScale({ x: 1, y: 1 }), 180);
    setTimeout(() => setShowPetHeart(false), 900);
    setTimeout(() => setMood((prev) => (prev === 'joyful' ? 'serene' : prev)), 2200);
  };

  const triggerSalah10mProactive = () => {
    setIsHiding(false);
    setMood('vigilant');
    setPosition({ x: 50, y: 26 });
    companionAudio.playSound('salah_10m');
    setActiveAlertCard({
      title: `10m until ${nextSalahName}`,
      body: '432Hz Salah chime triggered. Time to wind down screens calmly.',
      type: 'salah',
    });
    onTriggerSalahAlert?.();
  };

  const triggerScreenLimitProactive = () => {
    setIsHiding(false);
    setMood('mindful');
    setPosition({ x: 50, y: 34 });
    companionAudio.playSound('screen_threshold');
    setActiveAlertCard({
      title: 'Mindful Breathing Intermission',
      body: 'Short-form video loop noticed. Take 7 seconds of calm dhikr.',
      type: 'screentime',
    });
    onTriggerScreenLimit?.();
  };

  const togglePeekABoo = () => {
    if (!config.allowHidingBehindApps && !isHiding) {
      companionAudio.playSound('gentle_nudge');
      return;
    }
    if (!isHiding) {
      setIsHiding(true);
      setIsHovered(false);
      setIsAssistantPinned(false);
      setActiveAlertCard(null);
      setMood('hiding');
      setPosition((prev) => ({ ...prev, x: prev.x > 50 ? 95 : 5 }));
      companionAudio.playSound('gentle_nudge');
    } else {
      setIsHiding(false);
      setMood('joyful');
      setPosition((prev) => ({ ...prev, x: prev.x > 50 ? 82 : 18 }));
      companionAudio.playSound('peek_a_boo');
      setTimeout(() => setMood('serene'), 1800);
    }
  };

  const handleOpenOnboarding = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsAssistantPinned(false);
    setIsHovered(false);
    if (onLaunchOnboarding) {
      onLaunchOnboarding();
    } else {
      window.dispatchEvent(new CustomEvent('mizan:open-onboarding'));
    }
  };

  const handleOpenGateway = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsAssistantPinned(false);
    setIsHovered(false);
    window.dispatchEvent(new CustomEvent('mizan:navigate-tab', { detail: 'gateway' }));
  };

  const handleOpenAICoach = (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsAssistantPinned(false);
    setIsHovered(false);
    if (onNavigatePhoneTab) {
      onNavigatePhoneTab('coach');
    } else {
      window.dispatchEvent(new CustomEvent('mizan:navigate-tab', { detail: 'agent' }));
    }
  };

  if (!config.enabled) return null;

  const showHoverCard = !isHiding && !isDragging && (isHovered || isAssistantPinned);
  const contextCopy = TAB_CONTEXT_GUIDANCE[activeAppTab] || TAB_CONTEXT_GUIDANCE.prayer;
  const alignRight = position.x > 55;
  const openBelow = position.y < 42;

  return (
    <>
      {/* Bounded Floating System Overlay Container */}
      <div
        className="absolute inset-0 pointer-events-none overflow-hidden z-25"
        style={{ width: boundsWidth, height: boundsHeight }}
      >
        <motion.div
          drag
          dragMomentum={false}
          dragConstraints={{
            left: 14,
            right: boundsWidth - 68,
            top: 24,
            bottom: boundsHeight - 108,
          }}
          onDragStart={() => {
            setIsDragging(true);
            setIsHovered(false);
            setMood('mindful');
          }}
          onDragEnd={(_e, info) => {
            setIsDragging(false);
            if (config.edgeRestingSnap) {
              const approxPct = Math.max(12, Math.min(88, (info.point.x / boundsWidth) * 100));
              setPosition((prev) => ({ ...prev, x: approxPct > 50 ? 84 : 16 }));
              companionAudio.playSound('purr_resting');
            }
            setMood('serene');
          }}
          onMouseEnter={() => {
            if (hoverCloseTimerRef.current) clearTimeout(hoverCloseTimerRef.current);
            if (!isHiding) setIsHovered(true);
          }}
          onMouseLeave={() => {
            hoverCloseTimerRef.current = setTimeout(() => setIsHovered(false), 180);
          }}
          animate={{
            left: `${position.x}%`,
            top: `${position.y}%`,
            x: '-50%',
            y: '-50%',
            scaleX: isDragging ? 1.12 : isHiding ? 0.72 : petScale.x,
            scaleY: isDragging ? 1.12 : isHiding ? 0.72 : petScale.y,
            opacity: isHiding ? 0.48 : 1,
          }}
          transition={{ type: 'spring', stiffness: 165, damping: 18 }}
          className="absolute pointer-events-auto cursor-grab active:cursor-grabbing select-none"
        >
          {/* Floating Sparkle Reaction on Touch Pet */}
          <AnimatePresence>
            {showPetHeart && (
              <motion.div
                initial={{ opacity: 0, y: 4, scale: 0.7 }}
                animate={{ opacity: 1, y: -22, scale: 1 }}
                exit={{ opacity: 0, y: -32 }}
                className="absolute left-1/2 -translate-x-1/2 -top-1 pointer-events-none text-amber-300 flex items-center gap-0.5 text-[10px] font-bold"
              >
                <Heart className="w-3 h-3 fill-amber-400 text-amber-400" />
              </motion.div>
            )}
          </AnimatePresence>

          {/* Bounded Floating Assistant Orb / Skin */}
          <div
            onClick={handlePet}
            onContextMenu={(e) => {
              e.preventDefault();
              setIsAssistantPinned((prev) => !prev);
            }}
            title="Tap to pet (cute chime) · Drag to snap edges · Hover for AI & Tour guide"
            className="relative"
          >
            {/* Ambient Breathing Halo */}
            <motion.div
              animate={{
                scale: mood === 'vigilant' ? [1, 1.24, 1] : [1, 1.14, 1],
                opacity: isHiding ? 0.15 : [0.35, 0.65, 0.35],
              }}
              transition={{ duration: mood === 'vigilant' ? 1.6 : 3.2, repeat: Infinity, ease: 'easeInOut' }}
              className={`absolute -inset-1.5 rounded-full blur-sm pointer-events-none ${
                mood === 'vigilant'
                  ? 'bg-amber-400/50'
                  : mood === 'mindful'
                  ? 'bg-sky-400/40'
                  : 'bg-emerald-400/40'
              }`}
            />

            <div
              className={`w-12 h-12 rounded-full flex items-center justify-center relative shadow-lg backdrop-blur-md border transition-colors ${
                mood === 'vigilant'
                  ? 'border-amber-400/80 bg-[#1c230f]/90 text-amber-200'
                  : mood === 'joyful'
                  ? 'border-emerald-400/80 bg-[#083024]/90 text-amber-300'
                  : 'border-emerald-500/55 bg-[#07241d]/88 text-amber-300'
              }`}
            >
              {config.skin === 'luminous_orb' && (
                <div className="w-7 h-7 rounded-full bg-gradient-to-tr from-amber-400 via-yellow-200 to-emerald-400 flex items-center justify-center shadow-inner">
                  <span className="text-[11px] font-bold text-[#061814]">
                    {mood === 'joyful'
                      ? '◠‿◠'
                      : mood === 'vigilant'
                      ? '•̀‿•́'
                      : mood === 'hiding'
                      ? 'ᵕ‿ᵕ'
                      : '•‿•'}
                  </span>
                </div>
              )}
              {config.skin === 'hilal_sprite' && <span className="text-xl">🌙</span>}
              {config.skin === 'origami_dove' && <span className="text-xl">🕊️</span>}
              {config.skin === 'geometric_star' && <span className="text-xl text-amber-300">۞</span>}
            </div>
          </div>

          {/* Hoverable Persistent Assistant Card (Integrated with Multi-AI Gateway & Onboarding Tour) */}
          <AnimatePresence>
            {showHoverCard && (
              <motion.div
                initial={{ opacity: 0, y: openBelow ? -6 : 6, scale: 0.94 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: openBelow ? -4 : 4, scale: 0.95 }}
                onClick={(e) => e.stopPropagation()}
                className={`absolute ${openBelow ? 'top-full mt-2' : 'bottom-full mb-2'} ${
                  alignRight ? 'right-0' : 'left-0'
                } w-56 p-3 rounded-2xl shadow-2xl border backdrop-blur-md text-xs pointer-events-auto bg-[#061d17]/95 border-amber-400/45 text-emerald-100 z-30`}
              >
                <div className="flex items-center justify-between gap-1 mb-1">
                  <div className="flex items-center gap-1.5 font-bold text-[11px] text-amber-300 min-w-0">
                    <Sparkles className="w-3 h-3 text-amber-400 shrink-0" />
                    <span className="truncate">{contextCopy.title}</span>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setIsAssistantPinned(false);
                      setIsHovered(false);
                    }}
                    className="text-white/50 hover:text-white"
                    title="Close assistant card"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </div>

                <p className="text-[10px] leading-snug text-emerald-100/85 mb-2">
                  {contextCopy.tip}
                </p>

                <div className="mb-2 px-2 py-1 rounded-lg bg-[#041410] border border-emerald-800/50 flex items-center justify-between text-[9px] font-mono">
                  <span className="text-emerald-300/80">AI Route:</span>
                  <span className="text-amber-300 font-semibold truncate max-w-[115px]">
                    {gatewayConfig.provider} · {gatewayConfig.model}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-1.5">
                  <button
                    onClick={handleOpenOnboarding}
                    className="py-1 px-2 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-200 text-[10px] font-semibold flex items-center justify-center gap-1 transition-colors"
                  >
                    <HelpCircle className="w-3 h-3 text-amber-300" />
                    <span>Guide Tour</span>
                  </button>
                  <button
                    onClick={handleOpenGateway}
                    className="py-1 px-2 rounded-lg bg-emerald-900/60 hover:bg-emerald-800/70 border border-emerald-700/50 text-emerald-200 text-[10px] font-semibold flex items-center justify-center gap-1 transition-colors"
                  >
                    <Cpu className="w-3 h-3 text-emerald-300" />
                    <span>AI Keys</span>
                  </button>
                </div>
                <button
                  onClick={handleOpenAICoach}
                  className="mt-1.5 w-full py-1 px-2 rounded-lg bg-[#0a2b22] hover:bg-[#0f3a2e] border border-emerald-700/40 text-emerald-100 text-[10px] font-medium flex items-center justify-center gap-1 transition-colors"
                >
                  <Bot className="w-3 h-3 text-amber-300" />
                  <span>Open Mindful AI Coach</span>
                </button>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Bounded Proactive Alert Pill (Salah / Screen Threshold) when not hovered */}
          <AnimatePresence>
            {activeAlertCard && !showHoverCard && !isHiding && (
              <motion.div
                initial={{ opacity: 0, y: openBelow ? -6 : 6, scale: 0.92 }}
                animate={{ opacity: 1, y: 0, scale: 1 }}
                exit={{ opacity: 0, y: 4, scale: 0.95 }}
                onClick={(e) => e.stopPropagation()}
                className={`absolute ${openBelow ? 'top-full mt-2' : 'bottom-full mb-2'} ${
                  alignRight ? 'right-0' : 'left-0'
                } w-48 p-2.5 rounded-2xl shadow-2xl border backdrop-blur-md text-xs pointer-events-auto bg-[#061d17]/95 border-emerald-600/60 text-emerald-100`}
              >
                <div className="flex items-center justify-between mb-1">
                  <div className="flex items-center gap-1 font-bold text-[11px] text-amber-300">
                    <Sparkles className="w-3 h-3 text-amber-400" />
                    <span className="truncate">{activeAlertCard.title}</span>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setActiveAlertCard(null);
                    }}
                    className="text-white/60 hover:text-white"
                  >
                    <X className="w-3 h-3" />
                  </button>
                </div>
                <p className="text-[10px] leading-snug text-white/80">{activeAlertCard.body}</p>
              </motion.div>
            )}
          </AnimatePresence>
        </motion.div>
      </div>

      {/* Compact Chassis Control Bar */}
      <div className="p-2 mx-3 mb-2 rounded-xl bg-[#061e18]/85 border border-emerald-800/40 backdrop-blur-sm flex items-center justify-between text-xs gap-1.5">
        <div className="flex items-center gap-1.5 min-w-0">
          <div className="w-6 h-6 shrink-0 rounded-full bg-gradient-to-tr from-amber-400 to-emerald-600 flex items-center justify-center text-[11px] font-bold text-black shadow-sm">
            {config.skin === 'hilal_sprite'
              ? '🌙'
              : config.skin === 'origami_dove'
              ? '🕊️'
              : config.skin === 'geometric_star'
              ? '۞'
              : '✨'}
          </div>
          <div className="min-w-0">
            <div className="font-semibold text-white text-[10px] truncate">{config.name}</div>
            <p className="text-[9px] text-emerald-300/75 truncate">
              {isHiding
                ? 'Hiding at edge'
                : `${companionEnergy}% · ${petCount} pets · ${gatewayConfig.provider}`}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-1 shrink-0">
          <button
            onClick={() => setIsAssistantPinned((prev) => !prev)}
            title="Toggle Hoverable Assistant & Onboarding Menu"
            className={`px-2 py-1 rounded-lg border text-[10px] font-semibold flex items-center gap-1 whitespace-nowrap shrink-0 transition-colors ${
              isAssistantPinned
                ? 'bg-amber-500/25 border-amber-400/50 text-amber-300'
                : 'bg-emerald-950 border-emerald-700/50 text-emerald-300 hover:text-white'
            }`}
          >
            <HelpCircle className="w-3 h-3" />
            <span>Assist</span>
          </button>

          <button
            onClick={triggerSalah10mProactive}
            title="Trigger 10m Pre-Salah Harmonic Chime"
            className="p-1.5 rounded-lg bg-emerald-950 hover:bg-emerald-900 border border-emerald-700/50 text-amber-300"
          >
            <Clock className="w-3 h-3" />
          </button>

          <button
            onClick={triggerScreenLimitProactive}
            title="Trigger Mindful Screen Pause Chime"
            className="p-1.5 rounded-lg bg-emerald-950 hover:bg-emerald-900 border border-emerald-700/50 text-rose-300"
          >
            <Shield className="w-3 h-3" />
          </button>

          <button
            onClick={togglePeekABoo}
            title={isHiding ? 'Emerge from edge' : 'Play Peek-a-Boo (hide on edge)'}
            className="p-1.5 rounded-lg bg-emerald-950 hover:bg-emerald-900 border border-emerald-700/50 text-emerald-300"
          >
            {isHiding ? <Eye className="w-3 h-3" /> : <EyeOff className="w-3 h-3" />}
          </button>

          <button
            onClick={() => {
              if (onUpdateConfig) {
                onUpdateConfig({ ...config, soundEnabled: !config.soundEnabled });
              }
            }}
            title={config.soundEnabled ? 'Mute sound' : 'Unmute sound'}
            className="p-1.5 rounded-lg bg-emerald-950 hover:bg-emerald-900 border border-emerald-700/50 text-emerald-300"
          >
            {config.soundEnabled ? <Volume2 className="w-3 h-3" /> : <VolumeX className="w-3 h-3" />}
          </button>
        </div>
      </div>
    </>
  );
};

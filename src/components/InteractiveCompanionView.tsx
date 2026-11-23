import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  Sparkles,
  Volume2,
  VolumeX,
  Eye,
  EyeOff,
  Code2,
  Sliders,
  Clock,
  Shield,
  Award,
  Heart,
  HelpCircle,
  Cpu,
  Bot,
  Move,
  RotateCcw,
} from 'lucide-react';
import { CompanionSkin, CompanionMood, FloatingCompanionConfig } from '../types';
import { companionAudio, CompanionSoundType } from '../utils/companionSoundEngine';
import { loadGatewayConfig } from '../utils/aiGatewayClient';

interface InteractiveCompanionViewProps {
  onOpenCodeFile: (path: string) => void;
  onNavigateTab?: (tab: string) => void;
}

const SKIN_OPTIONS: {
  id: CompanionSkin;
  label: string;
  arabic: string;
  emoji: string;
  desc: string;
}[] = [
  {
    id: 'luminous_orb',
    label: 'Nūr Luminous Orb',
    arabic: 'نور',
    emoji: '✨',
    desc: 'Warm golden-emerald glowing sphere with reactive facial expressions.',
  },
  {
    id: 'hilal_sprite',
    label: 'Qamar Crescent Sprite',
    arabic: 'قمر',
    emoji: '🌙',
    desc: 'Gentle crescent lantern symbol honoring lunar Salah cycles.',
  },
  {
    id: 'origami_dove',
    label: 'Hudhud Origami Dove',
    arabic: 'هدهد',
    emoji: '🕊️',
    desc: 'Graceful folded paper messenger of calm mindfulness.',
  },
  {
    id: 'geometric_star',
    label: 'Najm Rub el-Hizb',
    arabic: 'نجم',
    emoji: '۞',
    desc: 'Classic Islamic geometric octagram badge with soft aura.',
  },
];

const SOUNDBOARD_ITEMS: {
  id: CompanionSoundType;
  label: string;
  freqLabel: string;
  desc: string;
  color: string;
}[] = [
  {
    id: 'salah_10m',
    label: '10m Salah Harmonic Bell',
    freqLabel: '432 Hz',
    desc: 'Warm resonant chime played 10 minutes before Adhan.',
    color: 'border-amber-400/50 bg-amber-500/10 text-amber-200',
  },
  {
    id: 'screen_threshold',
    label: 'Screen Time Nudge',
    freqLabel: '528 → 396 Hz',
    desc: 'Gentle two-tone alert signaling high short-form feed usage.',
    color: 'border-rose-400/40 bg-rose-500/10 text-rose-200',
  },
  {
    id: 'habit_celebration',
    label: 'Micro-Sunnah Harp',
    freqLabel: 'C5 Pentatonic',
    desc: 'Ascending arpeggio honoring logged habits and streaks.',
    color: 'border-emerald-400/50 bg-emerald-500/10 text-emerald-200',
  },
  {
    id: 'interactive_tap',
    label: 'Petting Water-Drop',
    freqLabel: '600 → 1100 Hz',
    desc: 'Cute crystalline droplet tone when tapping or petting Nūr.',
    color: 'border-sky-400/40 bg-sky-500/10 text-sky-200',
  },
  {
    id: 'peek_a_boo',
    label: 'Peek-a-Boo Flutter',
    freqLabel: '320 → 880 Hz',
    desc: 'Playful rising glissando when emerging from an edge.',
    color: 'border-violet-400/40 bg-violet-500/10 text-violet-200',
  },
  {
    id: 'purr_resting',
    label: 'Edge-Snap Resting Hum',
    freqLabel: '196 → 220 Hz',
    desc: 'Cozy triangle-wave hum when snapping softly to a screen edge.',
    color: 'border-teal-400/40 bg-teal-500/10 text-teal-200',
  },
  {
    id: 'gentle_nudge',
    label: 'Marimba Soft Tick',
    freqLabel: '740 Hz',
    desc: 'Subtle crisp marimba tap for tucking into Peek-a-Boo state.',
    color: 'border-orange-400/40 bg-orange-500/10 text-orange-200',
  },
];

export const InteractiveCompanionView: React.FC<InteractiveCompanionViewProps> = ({
  onOpenCodeFile,
  onNavigateTab,
}) => {
  const [config, setConfig] = useState<FloatingCompanionConfig>({
    enabled: true,
    skin: 'luminous_orb',
    name: 'Nūr (نور)',
    soundEnabled: true,
    soundVolume: 0.7,
    wanderSpeed: 'calm',
    salahLeadMinutes: 10,
    screenTimeThresholdMinutes: 15,
    allowHidingBehindApps: true,
    edgeRestingSnap: true,
  });

  const [mood, setMood] = useState<CompanionMood>('serene');
  const [isHiding, setIsHiding] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [petCount, setPetCount] = useState(0);
  const [energy, setEnergy] = useState(88);
  const [activeSound, setActiveSound] = useState<CompanionSoundType | null>(null);
  const [pos, setPos] = useState({ x: 82, y: 32 });
  const [petScale, setPetScale] = useState({ x: 1, y: 1 });
  const [statusNote, setStatusNote] = useState(
    'Bounded Floating Overlay Active — Drag Nūr, tap to pet, or hover to access Onboarding & AI Gateway.'
  );

  const stageRef = useRef<HTMLDivElement>(null);
  const gatewayCfg = loadGatewayConfig();

  useEffect(() => {
    companionAudio.setMuted(!config.soundEnabled);
    companionAudio.setVolume(config.soundVolume);
  }, [config.soundEnabled, config.soundVolume]);

  // Gentle autonomous edge wandering inside bounded stage
  useEffect(() => {
    if (!config.enabled || isHiding || isHovered || config.wanderSpeed === 'stationary') return;
    const ms = config.wanderSpeed === 'calm' ? 7500 : 4000;
    const timer = setInterval(() => {
      const edgeSpots = [
        { x: 84, y: 24 },
        { x: 16, y: 28 },
        { x: 84, y: 74 },
        { x: 16, y: 70 },
      ];
      setPos(edgeSpots[Math.floor(Math.random() * edgeSpots.length)]);
    }, ms);
    return () => clearInterval(timer);
  }, [config.enabled, config.wanderSpeed, isHiding, isHovered]);

  const playSoundDemo = (soundId: CompanionSoundType, note?: string) => {
    setActiveSound(soundId);
    companionAudio.playSound(soundId);
    if (note) setStatusNote(note);
    setTimeout(() => setActiveSound(null), 950);
  };

  const handlePetOrb = () => {
    if (isHiding) {
      handleTogglePeekABoo();
      return;
    }
    setPetCount((p) => p + 1);
    setEnergy((e) => Math.min(100, e + 3));
    setMood('joyful');
    setPetScale({ x: 1.2, y: 0.84 });
    playSoundDemo('interactive_tap', 'Tap response: Nūr chirped happily (water-drop 600→1100Hz tone).');
    setTimeout(() => setPetScale({ x: 1, y: 1 }), 190);
    setTimeout(() => setMood('serene'), 2000);
  };

  const handleTogglePeekABoo = () => {
    if (!isHiding) {
      setIsHiding(true);
      setMood('hiding');
      setPos((prev) => ({ ...prev, x: prev.x > 50 ? 96 : 4 }));
      playSoundDemo('gentle_nudge', 'Peek-a-Boo: Nūr tucked behind the screen edge.');
    } else {
      setIsHiding(false);
      setMood('joyful');
      setPos((prev) => ({ ...prev, x: prev.x > 50 ? 82 : 18 }));
      playSoundDemo('peek_a_boo', 'Peek-a-Boo: Nūr emerged with a soft upward glissando.');
      setTimeout(() => setMood('serene'), 1800);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="p-6 rounded-3xl bg-gradient-to-br from-[#07211b] via-[#061814] to-[#08241d] border border-emerald-800/60 shadow-xl flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div className="space-y-1.5">
          <div className="flex items-center gap-2">
            <span className="text-[10px] font-mono uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-amber-500/20 border border-amber-400/40 text-amber-300 font-bold">
              Bounded Floating Overlay • WindowManager
            </span>
            <span className="text-[10px] font-mono text-emerald-300/80">
              Non-Verbal Audio Only • Zero Speech Synthesis
            </span>
          </div>
          <h2 className="font-serif text-2xl font-bold text-white">
            Interactive AI Companion Workbench <span className="font-arabic text-amber-300">نور</span>
          </h2>
          <p className="text-xs text-emerald-200/80 max-w-2xl leading-relaxed">
            Test Nūr strictly in its bounded floating overlay state: touch-responsive petting, spring edge-resting snap, Peek-a-Boo edge hiding, cute reactive sound chimes, and instant hover access to the Onboarding Tour and Multi-AI Gateway.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2 shrink-0">
          <button
            onClick={() => window.dispatchEvent(new CustomEvent('mizan:open-onboarding'))}
            className="py-2 px-3.5 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-200 text-xs font-semibold flex items-center gap-1.5 transition-colors"
          >
            <HelpCircle className="w-4 h-4 text-amber-300" />
            <span>Open Onboarding Tour</span>
          </button>
          {onNavigateTab && (
            <button
              onClick={() => onNavigateTab('gateway')}
              className="py-2 px-3.5 rounded-xl bg-emerald-900/60 hover:bg-emerald-800/70 border border-emerald-700/50 text-emerald-200 text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              <Cpu className="w-4 h-4 text-amber-300" />
              <span>Multi-AI Gateway ({gatewayCfg.provider})</span>
            </button>
          )}
        </div>
      </div>

      {/* Main 2-Column Interactive Stage + Config */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left: Bounded Overlay Sandbox & Proactive Triggers (7 cols) */}
        <div className="lg:col-span-7 space-y-4">
          <div className="p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Sparkles className="w-4 h-4 text-amber-400" />
                <h3 className="font-serif text-base font-bold text-white">
                  Bounded Floating Overlay Stage
                </h3>
              </div>
              <div className="flex items-center gap-2 text-[11px] font-mono">
                <span className="px-2 py-0.5 rounded bg-emerald-950 border border-emerald-800 text-emerald-300">
                  Mood: <strong className="text-amber-300">{mood}</strong>
                </span>
                <span className="px-2 py-0.5 rounded bg-emerald-950 border border-emerald-800 text-emerald-300">
                  Energy: <strong className="text-emerald-200">{energy}%</strong>
                </span>
                <span className="px-2 py-0.5 rounded bg-emerald-950 border border-emerald-800 text-amber-300 flex items-center gap-1">
                  <Heart className="w-3 h-3 fill-amber-400 text-amber-400" />
                  {petCount}
                </span>
              </div>
            </div>

            {/* Bounded Overlay Sandbox */}
            <div
              ref={stageRef}
              className="relative h-80 rounded-2xl bg-gradient-to-b from-[#07201a] to-[#04120e] border border-emerald-800/60 overflow-hidden select-none"
            >
              {/* Decorative Mock Mobile Cards Inside Bounded Viewport */}
              <div className="p-4 grid grid-cols-2 gap-3 opacity-60 pointer-events-none">
                <div className="p-3 rounded-xl bg-[#0a2921] border border-emerald-800/40 space-y-1">
                  <span className="text-[10px] font-mono text-amber-300">Next Prayer</span>
                  <p className="text-sm font-serif font-bold text-white">Asr • العصر</p>
                  <p className="text-[10px] text-emerald-300/70">Adhan offline GPS active</p>
                </div>
                <div className="p-3 rounded-xl bg-[#0a2921] border border-emerald-800/40 space-y-1">
                  <span className="text-[10px] font-mono text-emerald-300">Micro-Sunnahs</span>
                  <p className="text-sm font-serif font-bold text-white">4 / 6 Logged</p>
                  <p className="text-[10px] text-emerald-300/70">Local binary storage</p>
                </div>
                <div className="col-span-2 p-3 rounded-xl bg-[#08221b] border border-emerald-800/40 flex items-center justify-between">
                  <div>
                    <span className="text-[10px] font-mono text-amber-300">Active AI Route</span>
                    <p className="text-xs font-semibold text-white">
                      {gatewayCfg.provider.toUpperCase()} ({gatewayCfg.model})
                    </p>
                  </div>
                  <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-emerald-900/70 text-emerald-200">
                    Bounded Overlay
                  </span>
                </div>
              </div>

              {/* Bounded Draggable Floating Companion */}
              {config.enabled && (
                <motion.div
                  drag
                  dragConstraints={stageRef}
                  dragElastic={0.08}
                  dragMomentum={false}
                  onDragStart={() => {
                    setIsHovered(false);
                    setMood('mindful');
                  }}
                  onDragEnd={(_e, info) => {
                    if (config.edgeRestingSnap && stageRef.current) {
                      const rect = stageRef.current.getBoundingClientRect();
                      const relX = ((info.point.x - rect.left) / rect.width) * 100;
                      setPos((prev) => ({
                        x: relX > 50 ? 84 : 16,
                        y: prev.y,
                      }));
                      playSoundDemo('purr_resting', 'Edge snap: Nūr rested cleanly against the nearest border.');
                    }
                    setMood('serene');
                  }}
                  onMouseEnter={() => {
                    if (!isHiding) setIsHovered(true);
                  }}
                  onMouseLeave={() => setIsHovered(false)}
                  animate={{
                    left: `${pos.x}%`,
                    top: `${pos.y}%`,
                    x: '-50%',
                    y: '-50%',
                    scaleX: isHiding ? 0.72 : petScale.x,
                    scaleY: isHiding ? 0.72 : petScale.y,
                    opacity: isHiding ? 0.45 : 1,
                  }}
                  transition={{ type: 'spring', stiffness: 170, damping: 18 }}
                  className="absolute z-20 cursor-grab active:cursor-grabbing"
                >
                  <div
                    onClick={handlePetOrb}
                    className="relative group"
                    title="Click to pet · Drag to snap edge · Hover for AI & Onboarding actions"
                  >
                    <motion.div
                      animate={{ scale: [1, 1.15, 1], opacity: isHiding ? 0.2 : [0.35, 0.7, 0.35] }}
                      transition={{ duration: 2.8, repeat: Infinity, ease: 'easeInOut' }}
                      className={`absolute -inset-2 rounded-full blur-md ${
                        mood === 'vigilant' ? 'bg-amber-400/50' : 'bg-emerald-400/40'
                      }`}
                    />
                    <div
                      className={`w-14 h-14 rounded-full flex items-center justify-center relative shadow-2xl border backdrop-blur-md transition-colors ${
                        mood === 'vigilant'
                          ? 'border-amber-400 bg-[#1e2610]/95 text-amber-200'
                          : 'border-emerald-400/60 bg-[#082920]/95 text-amber-300'
                      }`}
                    >
                      {config.skin === 'luminous_orb' && (
                        <div className="w-9 h-9 rounded-full bg-gradient-to-tr from-amber-400 via-yellow-200 to-emerald-400 flex items-center justify-center shadow-inner">
                          <span className="text-xs font-bold text-[#061814]">
                            {mood === 'joyful' ? '◠‿◠' : mood === 'vigilant' ? '•̀‿•́' : '•‿•'}
                          </span>
                        </div>
                      )}
                      {config.skin === 'hilal_sprite' && <span className="text-2xl">🌙</span>}
                      {config.skin === 'origami_dove' && <span className="text-2xl">🕊️</span>}
                      {config.skin === 'geometric_star' && <span className="text-2xl">۞</span>}
                    </div>
                  </div>

                  {/* Persistent Hoverable Assistant Popover */}
                  <AnimatePresence>
                    {isHovered && !isHiding && (
                      <motion.div
                        initial={{ opacity: 0, y: 6, scale: 0.94 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        exit={{ opacity: 0, y: 4, scale: 0.95 }}
                        className={`absolute ${pos.y < 42 ? 'top-full mt-2' : 'bottom-full mb-2'} ${
                          pos.x > 55 ? 'right-0' : 'left-0'
                        } w-56 p-3 rounded-2xl bg-[#051a14]/95 border border-amber-400/50 shadow-2xl text-xs space-y-2 z-30`}
                      >
                        <div className="flex items-center justify-between text-amber-300 font-bold text-[11px]">
                          <span>Hover Assistant • {config.name}</span>
                          <span className="font-mono text-[9px] text-emerald-300">Bounded</span>
                        </div>
                        <p className="text-[10px] text-emerald-100/80 leading-snug">
                          Quick access to interactive onboarding tutorials and your configured AI provider.
                        </p>
                        <div className="grid grid-cols-2 gap-1.5">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              window.dispatchEvent(new CustomEvent('mizan:open-onboarding'));
                            }}
                            className="py-1 px-2 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-200 text-[10px] font-semibold flex items-center justify-center gap-1"
                          >
                            <HelpCircle className="w-3 h-3" />
                            <span>Tour</span>
                          </button>
                          {onNavigateTab && (
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                onNavigateTab('gateway');
                              }}
                              className="py-1 px-2 rounded-lg bg-emerald-900/60 hover:bg-emerald-800/70 border border-emerald-700/50 text-emerald-200 text-[10px] font-semibold flex items-center justify-center gap-1"
                            >
                              <Cpu className="w-3 h-3" />
                              <span>Gateway</span>
                            </button>
                          )}
                        </div>
                        {onNavigateTab && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onNavigateTab('agent');
                            }}
                            className="w-full py-1 px-2 rounded-lg bg-[#0b2f25] hover:bg-[#104033] border border-emerald-700/50 text-emerald-100 text-[10px] font-medium flex items-center justify-center gap-1"
                          >
                            <Bot className="w-3 h-3 text-amber-300" />
                            <span>Open Al-Murshid Coach</span>
                          </button>
                        )}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              )}

              {/* Bottom Status Strip inside Stage */}
              <div className="absolute bottom-2.5 inset-x-3 px-3 py-1.5 rounded-xl bg-[#04120e]/85 border border-emerald-800/50 backdrop-blur-sm flex items-center justify-between text-[10px] text-emerald-200/85">
                <span className="truncate">{statusNote}</span>
                <span className="font-mono text-amber-300 shrink-0 ml-2">
                  x:{pos.x}% y:{pos.y}%
                </span>
              </div>
            </div>

            {/* Interactive Simulation Action Buttons */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
              <button
                onClick={() => {
                  setIsHiding(false);
                  setMood('vigilant');
                  setPos({ x: 50, y: 32 });
                  playSoundDemo('salah_10m', 'Triggered 10m Pre-Salah 432Hz bell cue.');
                }}
                className="py-2 px-3 rounded-xl bg-amber-500/15 hover:bg-amber-500/25 border border-amber-400/40 text-amber-200 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors"
              >
                <Clock className="w-3.5 h-3.5 text-amber-400" />
                <span>10m Salah</span>
              </button>

              <button
                onClick={() => {
                  setIsHiding(false);
                  setMood('mindful');
                  setPos({ x: 50, y: 44 });
                  playSoundDemo('screen_threshold', 'Triggered gentle Shorts/Reels threshold chime.');
                }}
                className="py-2 px-3 rounded-xl bg-rose-500/15 hover:bg-rose-500/25 border border-rose-400/40 text-rose-200 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors"
              >
                <Shield className="w-3.5 h-3.5 text-rose-400" />
                <span>Screen Nudge</span>
              </button>

              <button
                onClick={() => {
                  setIsHiding(false);
                  setMood('joyful');
                  playSoundDemo('habit_celebration', 'Celebrated Micro-Sunnah habit completion with pentatonic harp.');
                  setTimeout(() => setMood('serene'), 1800);
                }}
                className="py-2 px-3 rounded-xl bg-emerald-500/15 hover:bg-emerald-500/25 border border-emerald-400/40 text-emerald-200 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors"
              >
                <Award className="w-3.5 h-3.5 text-emerald-400" />
                <span>Habit Harp</span>
              </button>

              <button
                onClick={handleTogglePeekABoo}
                className="py-2 px-3 rounded-xl bg-[#0b2a22] hover:bg-[#10382d] border border-emerald-700/50 text-emerald-200 text-xs font-semibold flex items-center justify-center gap-1.5 transition-colors"
              >
                {isHiding ? <Eye className="w-3.5 h-3.5 text-amber-300" /> : <EyeOff className="w-3.5 h-3.5 text-emerald-300" />}
                <span>{isHiding ? 'Emerge' : 'Peek-a-Boo'}</span>
              </button>
            </div>
          </div>

          {/* Non-Verbal Acoustic Soundboard */}
          <div className="p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Volume2 className="w-4 h-4 text-amber-400" />
                <h3 className="font-serif text-base font-bold text-white">
                  Non-Verbal Expressive Soundboard
                </h3>
              </div>
              <span className="text-[10px] font-mono text-emerald-300/75">
                Web Audio API • Android SoundPool Parity
              </span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {SOUNDBOARD_ITEMS.map((item) => {
                const isPlaying = activeSound === item.id;
                return (
                  <button
                    key={item.id}
                    onClick={() => playSoundDemo(item.id, `Played "${item.label}" (${item.freqLabel}).`)}
                    className={`p-3 rounded-2xl border text-left transition-all flex items-start justify-between gap-2 ${
                      isPlaying
                        ? 'ring-2 ring-amber-400/70 scale-[0.99] ' + item.color
                        : item.color + ' hover:brightness-110'
                    }`}
                  >
                    <div className="space-y-0.5">
                      <div className="font-semibold text-xs text-white flex items-center gap-1.5">
                        <span>{item.label}</span>
                      </div>
                      <p className="text-[10px] opacity-80 leading-snug">{item.desc}</p>
                    </div>
                    <span className="text-[9px] font-mono px-1.5 py-0.5 rounded bg-black/30 shrink-0">
                      {item.freqLabel}
                    </span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Right: Skins, Behavior Settings & Native Code Links (5 cols) */}
        <div className="lg:col-span-5 space-y-4">
          {/* Skin Switcher */}
          <div className="p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="font-serif text-base font-bold text-white">Overlay Persona Skins</h3>
              <span className="text-[10px] font-mono text-amber-300">4 Bounded Forms</span>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {SKIN_OPTIONS.map((skin) => {
                const selected = config.skin === skin.id;
                return (
                  <button
                    key={skin.id}
                    onClick={() => {
                      setConfig((prev) => ({ ...prev, skin: skin.id }));
                      playSoundDemo('interactive_tap', `Switched overlay skin to ${skin.label}.`);
                    }}
                    className={`p-3 rounded-2xl border text-left transition-all space-y-1 ${
                      selected
                        ? 'bg-amber-500/15 border-amber-400/70 shadow-md'
                        : 'bg-[#08201a] border-emerald-900/60 hover:border-emerald-700/60'
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-xl">{skin.emoji}</span>
                      <span className="font-arabic text-xs text-amber-300">{skin.arabic}</span>
                    </div>
                    <div className="text-xs font-semibold text-white">{skin.label}</div>
                    <p className="text-[10px] text-emerald-200/70 leading-snug">{skin.desc}</p>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Behavior & Audio Controls */}
          <div className="p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Sliders className="w-4 h-4 text-amber-400" />
                <h3 className="font-serif text-base font-bold text-white">Overlay &amp; Audio Controls</h3>
              </div>
              <button
                onClick={() => {
                  setPos({ x: 82, y: 32 });
                  setIsHiding(false);
                  setMood('serene');
                  setStatusNote('Reset companion to default resting corner.');
                }}
                className="text-[10px] font-mono text-emerald-300 hover:text-amber-300 flex items-center gap-1"
              >
                <RotateCcw className="w-3 h-3" />
                <span>Reset Pos</span>
              </button>
            </div>

            <div className="space-y-3 text-xs">
              {/* Toggle Companion */}
              <div className="flex items-center justify-between p-2.5 rounded-xl bg-[#08201a] border border-emerald-900/60">
                <div>
                  <span className="font-medium text-white block">Floating Overlay Active</span>
                  <span className="text-[10px] text-emerald-300/70">Persistent hoverable assistant over tabs</span>
                </div>
                <input
                  type="checkbox"
                  checked={config.enabled}
                  onChange={(e) => setConfig((prev) => ({ ...prev, enabled: e.target.checked }))}
                  className="accent-amber-400 w-4 h-4 cursor-pointer"
                />
              </div>

              {/* Toggle Edge Snap */}
              <div className="flex items-center justify-between p-2.5 rounded-xl bg-[#08201a] border border-emerald-900/60">
                <div className="flex items-center gap-2">
                  <Move className="w-3.5 h-3.5 text-amber-400" />
                  <div>
                    <span className="font-medium text-white block">Spring Edge-Resting Snap</span>
                    <span className="text-[10px] text-emerald-300/70">Automatically settles cleanly along edges</span>
                  </div>
                </div>
                <input
                  type="checkbox"
                  checked={config.edgeRestingSnap}
                  onChange={(e) => setConfig((prev) => ({ ...prev, edgeRestingSnap: e.target.checked }))}
                  className="accent-amber-400 w-4 h-4 cursor-pointer"
                />
              </div>

              {/* Wander Speed */}
              <div className="p-2.5 rounded-xl bg-[#08201a] border border-emerald-900/60 space-y-1.5">
                <div className="flex items-center justify-between">
                  <span className="font-medium text-white">Autonomous Edge Drift</span>
                  <span className="font-mono text-[10px] text-amber-300 uppercase">{config.wanderSpeed}</span>
                </div>
                <div className="grid grid-cols-3 gap-1.5">
                  {(['stationary', 'calm', 'lively'] as const).map((speed) => (
                    <button
                      key={speed}
                      onClick={() => setConfig((prev) => ({ ...prev, wanderSpeed: speed }))}
                      className={`py-1 rounded-lg text-[10px] font-medium capitalize border transition-colors ${
                        config.wanderSpeed === speed
                          ? 'bg-amber-500/20 border-amber-400/60 text-amber-200'
                          : 'bg-[#051511] border-emerald-900/60 text-emerald-300/70 hover:text-white'
                      }`}
                    >
                      {speed}
                    </button>
                  ))}
                </div>
              </div>

              {/* Volume & Mute */}
              <div className="p-2.5 rounded-xl bg-[#08201a] border border-emerald-900/60 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-medium text-white">Non-Verbal Audio Volume</span>
                  <button
                    onClick={() => setConfig((prev) => ({ ...prev, soundEnabled: !prev.soundEnabled }))}
                    className="flex items-center gap-1 text-[10px] font-mono text-amber-300"
                  >
                    {config.soundEnabled ? <Volume2 className="w-3.5 h-3.5" /> : <VolumeX className="w-3.5 h-3.5 text-rose-300" />}
                    <span>{config.soundEnabled ? `${Math.round(config.soundVolume * 100)}%` : 'Muted'}</span>
                  </button>
                </div>
                <input
                  type="range"
                  min={0}
                  max={1}
                  step={0.05}
                  value={config.soundVolume}
                  onChange={(e) =>
                    setConfig((prev) => ({ ...prev, soundVolume: parseFloat(e.target.value) }))
                  }
                  className="w-full accent-amber-400 cursor-pointer"
                />
              </div>

              {/* Salah Alert Lead Time */}
              <div className="p-2.5 rounded-xl bg-[#08201a] border border-emerald-900/60 space-y-1.5">
                <div className="flex items-center justify-between">
                  <span className="font-medium text-white">Pre-Salah Chime Lead</span>
                  <span className="font-mono text-[10px] text-amber-300">{config.salahLeadMinutes} mins</span>
                </div>
                <input
                  type="range"
                  min={5}
                  max={20}
                  step={1}
                  value={config.salahLeadMinutes}
                  onChange={(e) =>
                    setConfig((prev) => ({ ...prev, salahLeadMinutes: parseInt(e.target.value, 10) }))
                  }
                  className="w-full accent-amber-400 cursor-pointer"
                />
              </div>
            </div>
          </div>

          {/* Native & Flutter Source Code Links */}
          <div className="p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-2.5">
            <div className="flex items-center gap-2 text-amber-300 text-xs font-semibold">
              <Code2 className="w-4 h-4 text-amber-400" />
              <span>Bounded Overlay Production Source</span>
            </div>
            <div className="grid grid-cols-1 gap-1.5 text-xs">
              {[
                {
                  label: 'FloatingCompanionOverlayService.kt (Android WindowManager)',
                  path: 'android/app/src/main/kotlin/com/mizan/app/FloatingCompanionOverlayService.kt',
                },
                {
                  label: 'CompanionAudioPoolManager.kt (SoundPool Non-Verbal Audio)',
                  path: 'android/app/src/main/kotlin/com/mizan/app/CompanionAudioPoolManager.kt',
                },
                {
                  label: 'companion_controller.dart (Flutter Riverpod State)',
                  path: 'lib/features/companion/presentation/controllers/companion_controller.dart',
                },
                {
                  label: 'companion_customizer_screen.dart (Skin & Audio UI)',
                  path: 'lib/features/companion/presentation/screens/companion_customizer_screen.dart',
                },
              ].map((file) => (
                <button
                  key={file.path}
                  onClick={() => onOpenCodeFile(file.path)}
                  className="w-full py-2 px-3 rounded-xl bg-[#08201a] hover:bg-[#0d2d25] border border-emerald-900/60 text-left text-[11px] text-emerald-200 hover:text-amber-300 transition-colors truncate"
                >
                  {file.label}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

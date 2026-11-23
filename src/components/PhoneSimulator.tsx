import React, { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import confetti from 'canvas-confetti';
import {
  Compass,
  Clock,
  BookOpen,
  Sparkles,
  Shield,
  Users,
  Check,
  ChevronRight,
  Flame,
  Volume2,
  RefreshCw,
  MapPin,
  Calendar,
  Layers,
  Heart,
  Send,
  Sliders,
  HelpCircle,
  Smartphone,
  Eye,
  AlertTriangle,
  User,
  Fingerprint,
  Key
} from 'lucide-react';
import {
  CalculationMethod,
  Coordinates,
  Madhab,
  MicroSunnah,
  PrayerTimesResult,
  ShieldTriggerEvent,
  CoachingReflection,
  PeerAccountabilityNode,
  UserProfile,
  FloatingCompanionConfig
} from '../types';
import { calculatePrayerTimes, PRESET_CITIES, formatTime, formatDuration } from '../utils/prayerEngine';
import { INITIAL_MICRO_SUNNAHS, INITIAL_CIRCADIAN_BLOCKS, INITIAL_PEER_NODES } from '../data/mockData';
import { OverlayShieldModal } from './OverlayShieldModal';
import { ProfileAuthView } from './ProfileAuthView';
import { FloatingCompanion } from './FloatingCompanion';
import { loadGatewayConfig, getActiveGatewayHeaders } from '../utils/aiGatewayClient';

interface PhoneSimulatorProps {
  onShowProminentDisclosure: () => void;
  onOpenCodeFile: (path: string) => void;
  onLaunchOnboarding?: () => void;
  user: UserProfile | null;
  onUpdateUser: (user: UserProfile) => void;
  onLogout: () => void;
}

export const PhoneSimulator: React.FC<PhoneSimulatorProps> = ({
  onShowProminentDisclosure,
  onOpenCodeFile,
  onLaunchOnboarding,
  user,
  onUpdateUser,
  onLogout,
}) => {
  // Navigation tabs inside phone
  const [activeTab, setActiveTab] = useState<'prayer' | 'shield' | 'quran' | 'planner' | 'coach' | 'peers' | 'profile'>('prayer');

  // Location & Prayer calculation state
  const [selectedCity, setSelectedCity] = useState<Coordinates>(PRESET_CITIES[0]); // Makkah default
  const [calculationMethod, setCalculationMethod] = useState<CalculationMethod>('MWL');
  const [madhab, setMadhab] = useState<Madhab>('SHAFI');
  const [prayerResult, setPrayerResult] = useState<PrayerTimesResult>(() =>
    calculatePrayerTimes(PRESET_CITIES[0], new Date(), 'MWL', 'SHAFI')
  );
  const [currentTime, setCurrentTime] = useState(new Date());

  // Shield & Wellbeing state
  const [shortsBlockingEnabled, setShortsBlockingEnabled] = useState(true);
  const [salahLockLeadMinutes, setSalahLockLeadMinutes] = useState(10);
  const [activeShieldEvent, setActiveShieldEvent] = useState<ShieldTriggerEvent | null>(null);
  const [todayScreenMinutes, setTodayScreenMinutes] = useState(24);
  const [screenLimitMinutes, setScreenLimitMinutes] = useState(45);

  // Quran state
  const [quranAyah, setQuranAyah] = useState(28);
  const [quranSurah, setQuranSurah] = useState({ number: 2, name: 'Al-Baqarah', total: 286, juz: 2 });
  const [todayQuranGoal] = useState(20);
  const [todayAyahsRead, setTodayAyahsRead] = useState(14);

  // Micro-Sunnahs state
  const [sunnahs, setSunnahs] = useState<MicroSunnah[]>(() => {
    const saved = localStorage.getItem('mizan_sunnahs');
    return saved ? JSON.parse(saved) : INITIAL_MICRO_SUNNAHS;
  });

  // Peer Accountability state
  const [peers, setPeers] = useState<PeerAccountabilityNode[]>(INITIAL_PEER_NODES);
  const [myProofHash, setMyProofHash] = useState<string>('ed25519_sig:7b3f910a284c...e89');
  const [proofGenerated, setProofGenerated] = useState(false);

  // Ethical AI Coach state
  const [coachTrigger, setCoachTrigger] = useState('Feeling exhausted after work and mindlessly opened Reels');
  const [coachResponse, setCoachResponse] = useState<CoachingReflection | null>(null);
  const [isCoachLoading, setIsCoachLoading] = useState(false);

  // Dynamic Floating Companion State
  const [companionConfig, setCompanionConfig] = useState<FloatingCompanionConfig>({
    enabled: true,
    skin: 'luminous_orb',
    name: 'Nūr',
    soundEnabled: true,
    soundVolume: 0.7,
    wanderSpeed: 'calm',
    salahLeadMinutes: 10,
    screenTimeThresholdMinutes: 15,
    allowHidingBehindApps: true,
    edgeRestingSnap: true,
  });

  // Update clock & prayers
  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      setCurrentTime(now);
      setPrayerResult(calculatePrayerTimes(selectedCity, now, calculationMethod, madhab));
    }, 1000);
    return () => clearInterval(timer);
  }, [selectedCity, calculationMethod, madhab]);

  const [showHabitGuideTip, setShowHabitGuideTip] = useState<boolean>(() => {
    try {
      return localStorage.getItem('mizan_habit_tip_dismissed') !== 'true';
    } catch {
      return true;
    }
  });

  // Save Sunnahs
  const toggleSunnah = (id: string) => {
    if (showHabitGuideTip) {
      setShowHabitGuideTip(false);
      try {
        localStorage.setItem('mizan_habit_tip_dismissed', 'true');
      } catch {
        // ignore
      }
    }
    setSunnahs((prev) => {
      const updated = prev.map((s) => {
        if (s.id === id) {
          const nextVal = !s.completed;
          if (nextVal) {
            window.dispatchEvent(new CustomEvent('mizan:habit-logged'));
            confetti({
              particleCount: 25,
              spread: 60,
              origin: { y: 0.7 },
              colors: ['#cfa859', '#10b981', '#34d399'],
            });
          }
          return { ...s, completed: nextVal };
        }
        return s;
      });
      localStorage.setItem('mizan_sunnahs', JSON.stringify(updated));
      return updated;
    });
  };

  const handleReadMoreAyahs = (count: number) => {
    setQuranAyah((prev) => Math.min(quranSurah.total, prev + count));
    setTodayAyahsRead((prev) => prev + count);
    confetti({
      particleCount: 30,
      spread: 70,
      origin: { y: 0.65 },
      colors: ['#10b981', '#cfa859', '#6ee7b7'],
    });
  };

  // Trigger simulated OS Shield
  const triggerSimulatedShield = (app: 'YouTube Shorts' | 'Instagram Reels' | 'Salah Approaching') => {
    setActiveShieldEvent({
      targetApp: app,
      timeSpentMinutes: 18,
      thresholdMinutes: 15,
      active: true,
    });
  };

  // Generate Daily Proof Hash for Peer network
  const handleGenerateProof = () => {
    const randomHex = Array.from({ length: 64 }, () =>
      Math.floor(Math.random() * 16).toString(16)
    ).join('');
    setMyProofHash(`ed25519_proof:${randomHex.substring(0, 24)}...`);
    setProofGenerated(true);
    confetti({
      particleCount: 40,
      spread: 80,
      origin: { y: 0.6 },
      colors: ['#cfa859', '#38bdf8', '#10b981'],
    });
    setTimeout(() => setProofGenerated(false), 3000);
  };

  // Send encouragement to peer
  const handleEncouragePeer = (id: string) => {
    setPeers((prev) =>
      prev.map((p) => (p.id === id ? { ...p, encouragementSent: true } : p))
    );
  };

  // Submit to Ethical AI Coach (routed via configured Multi-AI Gateway)
  const handleAskCoach = async () => {
    setIsCoachLoading(true);
    const gatewayCfg = loadGatewayConfig();

    try {
      const res = await fetch('/api/reflect', {
        method: 'POST',
        headers: getActiveGatewayHeaders(),
        body: JSON.stringify({
          appName: 'Instagram Reels',
          timeSpentMinutes: 20,
          emotionalState: 'Mental fatigue / Avoidance',
          promptContext: coachTrigger,
          provider: gatewayCfg.provider,
          model: gatewayCfg.model,
          temperature: gatewayCfg.temperature,
          maxTokens: gatewayCfg.maxTokens,
        }),
      });
      const data = await res.json();
      setCoachResponse(data);
    } catch {
      setCoachResponse({
        source: 'offline-fallback',
        empathy: 'Reaching for distraction is often our nervous system requesting an intermission from tension.',
        inquiry: 'If your attention stepped away from the screen for just 120 seconds, what would bring genuine relief?',
        offlineAlternatives: [
          {
            title: 'Cool Water Wudu',
            duration: '2 mins',
            action: 'Slowly rinse your hands and face with cool water to stimulate the vagus nerve and refresh taharah.',
            category: 'spiritual',
          },
          {
            title: '33x SubhanAllah',
            duration: '2 mins',
            action: 'Breathe in deeply, then exhale while counting 11 beads of tasbih.',
            category: 'somatic',
          },
        ],
        affirmation: 'You have complete sovereignty over your next decision. Choose with intention.',
      });
    } finally {
      setIsCoachLoading(false);
    }
  };

  return (
    <div className="relative flex flex-col items-center">
      {/* Smartphone Chassis Frame */}
      <div className="relative w-[380px] h-[780px] bg-[#030a08] rounded-[48px] p-3 shadow-2xl border-4 border-[#1c332e] shadow-emerald-950/40 select-none overflow-hidden flex flex-col">
        {/* Dynamic Island / Speaker Notch */}
        <div className="absolute top-4 left-1/2 -translate-x-1/2 w-32 h-6 bg-black rounded-full z-40 flex items-center justify-between px-3">
          <div className="w-2.5 h-2.5 rounded-full bg-[#11241f] border border-[#234d42]" />
          <div className="flex items-center gap-1.5">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
            <span className="text-[9px] font-mono text-emerald-400 font-semibold">Mīzān</span>
          </div>
        </div>

        {/* Screen Content Container */}
        <div className="relative flex-1 bg-[#071915] rounded-[38px] overflow-hidden flex flex-col text-white pt-8 pb-3">
          {/* OS Top Status Bar */}
          <div className="px-6 py-1 flex items-center justify-between text-[11px] font-mono text-emerald-200/80 border-b border-emerald-900/30">
            <span>{currentTime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
            <div className="flex items-center gap-1.5">
              <span className="text-[10px] text-amber-300 font-sans font-medium flex items-center gap-1">
                <MapPin className="w-3 h-3 text-amber-400" />
                {selectedCity.city}
              </span>
              {onLaunchOnboarding && (
                <button
                  onClick={onLaunchOnboarding}
                  className="text-[10px] bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 px-1.5 py-0.5 rounded text-amber-300 font-mono flex items-center gap-1 transition-colors"
                  title="Interactive Onboarding Guide"
                >
                  <HelpCircle className="w-2.5 h-2.5 text-amber-400" />
                  <span>Tour</span>
                </button>
              )}
              <button
                onClick={() => setActiveTab('profile')}
                className="text-[10px] bg-emerald-900/80 hover:bg-emerald-800 px-1.5 py-0.5 rounded text-emerald-300 font-mono flex items-center gap-1 transition-colors"
                title="Account & Security"
              >
                <User className="w-2.5 h-2.5 text-amber-400" />
                <span>{user ? user.displayName.split(' ')[0] : 'Sign In'}</span>
              </button>
            </div>
          </div>

          {/* Bounded Floating AI Companion System Overlay */}
          <FloatingCompanion
            boundsWidth={356}
            boundsHeight={640}
            config={companionConfig}
            onUpdateConfig={setCompanionConfig}
            nextSalahName={prayerResult.nextPrayer.name}
            nextSalahMinutes={Math.max(1, Math.round(prayerResult.nextPrayer.remainingMs / 60000))}
            activeAppTab={activeTab}
            screenMinutesRatio={todayScreenMinutes / screenLimitMinutes}
            onOpenCodeFile={onOpenCodeFile}
            onTriggerSalahAlert={() => triggerSimulatedShield('Salah Approaching')}
            onTriggerScreenLimit={() => triggerSimulatedShield('YouTube Shorts')}
            onLaunchOnboarding={onLaunchOnboarding}
            onNavigatePhoneTab={(tab) => setActiveTab(tab)}
          />

          {/* Active Screen Tab Content */}
          <div className="flex-1 overflow-y-auto px-4 py-3 space-y-3.5">
            {/* TAB 1: PRAYER & ADHAN ENGINE */}
            {activeTab === 'prayer' && (
              <div className="space-y-3">
                {/* Hero Card: Next Prayer & Countdown */}
                <div
                  className="p-4 rounded-2xl bg-gradient-to-b from-emerald-900/70 to-emerald-950/90 border border-emerald-700/40 shadow-lg relative overflow-hidden"
                >
                  <div className="absolute top-0 right-0 p-3 opacity-15 pointer-events-none">
                    <span className="font-arabic text-6xl text-amber-300">م</span>
                  </div>

                  <div className="flex items-start justify-between">
                    <div>
                      <span className="text-[10px] uppercase tracking-wider text-amber-300/90 font-mono font-medium">
                        Next Obligatory Prayer
                      </span>
                      <div className="flex items-baseline gap-2 mt-0.5">
                        <h2 className="text-2xl font-serif font-bold text-white tracking-tight">
                          {prayerResult.nextPrayer.name}
                        </h2>
                        <span className="font-arabic text-lg text-amber-200">
                          {prayerResult.nextPrayer.arabicName}
                        </span>
                      </div>
                      <p className="text-xs text-emerald-200/80 font-mono mt-0.5">
                        at {formatTime(prayerResult.nextPrayer.time)}
                      </p>
                    </div>

                    <div className="text-right">
                      <span className="text-[10px] uppercase text-emerald-300/70 font-mono">Countdown</span>
                      <p className="text-sm font-mono font-bold text-amber-300 mt-0.5">
                        {formatDuration(prayerResult.nextPrayer.remainingMs)}
                      </p>
                    </div>
                  </div>

                  {/* Pre-Salah Lock Indicator */}
                  <div className="mt-3 pt-2.5 border-t border-emerald-800/40 flex items-center justify-between text-xs">
                    <div className="flex items-center gap-1.5 text-emerald-300/90">
                      <Shield className="w-3.5 h-3.5 text-amber-400" />
                      <span>Salah Lock:</span>
                      <span className="font-mono text-amber-300">{salahLockLeadMinutes}m before Adhan</span>
                    </div>
                    <button
                      onClick={() => triggerSimulatedShield('Salah Approaching')}
                      className="px-2 py-0.5 rounded-md bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 text-[10px] font-medium border border-amber-400/30 transition-colors"
                    >
                      Test Shield
                    </button>
                  </div>
                </div>

                {/* All 6 Prayer Times Horizontal Grid */}
                <div className="grid grid-cols-3 gap-2">
                  {[
                    { name: 'Fajr', ar: 'الفجر', time: prayerResult.fajr },
                    { name: 'Sunrise', ar: 'الشروق', time: prayerResult.sunrise },
                    { name: 'Dhuhr', ar: 'الظهر', time: prayerResult.dhuhr },
                    { name: 'Asr', ar: 'العصر', time: prayerResult.asr },
                    { name: 'Maghrib', ar: 'المغرب', time: prayerResult.maghrib },
                    { name: 'Isha', ar: 'العشاء', time: prayerResult.isha },
                  ].map((p) => {
                    const isNext = p.name === prayerResult.nextPrayer.name;
                    return (
                      <div
                        key={p.name}
                        className={`p-2.5 rounded-xl border transition-all text-center ${
                          isNext
                            ? 'bg-amber-500/15 border-amber-400/60 shadow-sm'
                            : 'bg-emerald-950/50 border-emerald-900/60'
                        }`}
                      >
                        <div className="flex items-center justify-between text-[10px] text-emerald-300/70">
                          <span className={isNext ? 'text-amber-300 font-bold' : ''}>{p.name}</span>
                          <span className="font-arabic">{p.ar}</span>
                        </div>
                        <p className={`text-xs font-mono font-semibold mt-1 ${isNext ? 'text-amber-200' : 'text-white'}`}>
                          {formatTime(p.time)}
                        </p>
                      </div>
                    );
                  })}
                </div>

                {/* Offline Astronomical Engine Settings & Qibla */}
                <div
                  className="p-3 rounded-xl bg-emerald-950/40 border border-emerald-900/40 space-y-2 text-xs"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-emerald-300 font-medium flex items-center gap-1.5">
                      <Compass className="w-3.5 h-3.5 text-amber-400" />
                      Qibla Bearing: <strong className="text-white font-mono">{prayerResult.qiblaDegrees}°</strong> from North
                    </span>
                    <span className="text-[10px] font-mono text-emerald-400">Batoul Adhan v2.1</span>
                  </div>

                  <div className="grid grid-cols-2 gap-2 pt-1">
                    <div>
                      <label className="text-[10px] text-emerald-300/70 block mb-0.5">Preset City</label>
                      <select
                        value={selectedCity.city}
                        onChange={(e) => {
                          const found = PRESET_CITIES.find((c) => c.city === e.target.value);
                          if (found) setSelectedCity(found);
                        }}
                        className="w-full bg-[#0a201a] border border-emerald-800/60 rounded-lg p-1.5 text-xs text-white focus:outline-none focus:border-amber-400"
                      >
                        {PRESET_CITIES.map((c) => (
                          <option key={c.city} value={c.city}>
                            {c.city} ({c.country})
                          </option>
                        ))}
                      </select>
                    </div>

                    <div>
                      <label className="text-[10px] text-emerald-300/70 block mb-0.5">Method</label>
                      <select
                        value={calculationMethod}
                        onChange={(e) => setCalculationMethod(e.target.value as CalculationMethod)}
                        className="w-full bg-[#0a201a] border border-emerald-800/60 rounded-lg p-1.5 text-xs text-white focus:outline-none focus:border-amber-400"
                      >
                        <option value="MWL">Muslim World League (18°)</option>
                        <option value="ISNA">ISNA (15°)</option>
                        <option value="MAKKAH">Umm Al-Qura (Makkah)</option>
                        <option value="EGYPT">Egyptian General</option>
                        <option value="KARACHI">Univ of Karachi</option>
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* TAB 2: SHIELD & OS APP BLOCKER */}
            {activeTab === 'shield' && (
              <div className="space-y-3">
                {/* Shield Status Card */}
                <div
                  className="p-4 rounded-2xl bg-emerald-950/70 border border-emerald-800/50 space-y-3"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="p-2 rounded-xl bg-amber-500/15 border border-amber-400/30">
                        <Shield className="w-4 h-4 text-amber-400" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-sm text-white">Algorithmic Shield</h3>
                        <p className="text-[11px] text-emerald-300/70">Android Accessibility &amp; iOS ScreenTime</p>
                      </div>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input
                        type="checkbox"
                        checked={shortsBlockingEnabled}
                        onChange={(e) => setShortsBlockingEnabled(e.target.checked)}
                        className="sr-only peer"
                      />
                      <div className="w-9 h-5 bg-emerald-950 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-amber-500"></div>
                    </label>
                  </div>

                  {/* Daily Screen Quota */}
                  <div className="pt-2 border-t border-emerald-900/60">
                    <div className="flex items-center justify-between text-xs mb-1">
                      <span className="text-emerald-300/80">Social Media Time Today</span>
                      <span className="font-mono text-amber-300 font-bold">
                        {todayScreenMinutes}m / {screenLimitMinutes}m
                      </span>
                    </div>
                    <div className="w-full h-2 rounded-full bg-emerald-950 overflow-hidden border border-emerald-900/60">
                      <div
                        className="h-full bg-gradient-to-r from-emerald-500 to-amber-400 rounded-full transition-all"
                        style={{ width: `${(todayScreenMinutes / screenLimitMinutes) * 100}%` }}
                      />
                    </div>
                  </div>
                </div>

                {/* Live OS Interception Simulator Buttons */}
                <div
                  className="p-3.5 rounded-xl bg-[#081e18] border border-emerald-800/40 space-y-2"
                >
                  <span className="text-xs font-semibold text-amber-300 flex items-center gap-1.5">
                    <Smartphone className="w-3.5 h-3.5 text-amber-400" />
                    Simulate OS Video Feed Detection
                  </span>
                  <p className="text-[11px] text-emerald-200/70 leading-relaxed">
                    Test what occurs when Android's <code className="text-amber-200 font-mono">AccessibilityService</code> or iOS's <code className="text-amber-200 font-mono">ShieldExtension</code> intercepts short-form loops:
                  </p>

                  <div className="grid grid-cols-2 gap-2 pt-1">
                    <button
                      onClick={() => triggerSimulatedShield('YouTube Shorts')}
                      className="py-2 px-2.5 rounded-lg bg-red-950/40 hover:bg-red-900/50 border border-red-700/40 text-red-200 text-xs font-medium text-left flex items-center justify-between transition-colors"
                    >
                      <span>▶ YouTube Shorts</span>
                      <ChevronRight className="w-3.5 h-3.5 opacity-60" />
                    </button>

                    <button
                      onClick={() => triggerSimulatedShield('Instagram Reels')}
                      className="py-2 px-2.5 rounded-lg bg-purple-950/40 hover:bg-purple-900/50 border border-purple-700/40 text-purple-200 text-xs font-medium text-left flex items-center justify-between transition-colors"
                    >
                      <span>📷 IG Reels</span>
                      <ChevronRight className="w-3.5 h-3.5 opacity-60" />
                    </button>
                  </div>
                </div>

                {/* Google Play Prominent Disclosure Button */}
                <div className="p-3 rounded-xl bg-emerald-950/40 border border-emerald-900/50 flex items-center justify-between">
                  <div className="text-xs">
                    <span className="text-white font-medium block">Google Play Policy</span>
                    <span className="text-[10px] text-emerald-300/70">Mandatory prominent disclosure modal</span>
                  </div>
                  <button
                    onClick={onShowProminentDisclosure}
                    className="py-1 px-2.5 rounded-lg bg-emerald-800/50 hover:bg-emerald-700/50 text-emerald-200 text-xs font-medium border border-emerald-600/30 transition-colors"
                  >
                    View Disclosure
                  </button>
                </div>
              </div>
            )}

            {/* TAB 3: QURAN & MICRO-SUNNAHS */}
            {activeTab === 'quran' && (
              <div className="space-y-3">
                {/* Low-Friction Quran Reading Card */}
                <div
                  className="p-4 rounded-2xl bg-emerald-950/80 border border-emerald-800/50 space-y-2.5"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <span className="text-[10px] uppercase tracking-wider text-amber-300/80 font-mono">
                        Active Bookmark
                      </span>
                      <h3 className="font-serif text-base font-bold text-white">
                        Surah {quranSurah.name} ({quranSurah.number})
                      </h3>
                      <p className="text-xs text-emerald-200/80 font-mono">
                        Ayah {quranAyah} of {quranSurah.total} • Juz {quranSurah.juz}
                      </p>
                    </div>

                    <div className="text-right">
                      <span className="text-[10px] text-emerald-300/70 font-mono">Today</span>
                      <p className="text-xs font-mono font-bold text-amber-300">
                        {todayAyahsRead} / {todayQuranGoal} ayahs
                      </p>
                    </div>
                  </div>

                  <div className="w-full h-1.5 rounded-full bg-emerald-950 overflow-hidden border border-emerald-900/50">
                    <div
                      className="h-full bg-emerald-400 rounded-full transition-all"
                      style={{ width: `${(quranAyah / quranSurah.total) * 100}%` }}
                    />
                  </div>

                  <div className="flex items-center gap-2 pt-1">
                    <button
                      onClick={() => handleReadMoreAyahs(1)}
                      className="flex-1 py-1.5 px-3 rounded-lg bg-emerald-800/50 hover:bg-emerald-700/60 border border-emerald-600/40 text-xs font-medium text-emerald-100 transition-colors"
                    >
                      +1 Ayah Read
                    </button>
                    <button
                      onClick={() => handleReadMoreAyahs(5)}
                      className="flex-1 py-1.5 px-3 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-xs font-medium text-amber-200 transition-colors"
                    >
                      +5 Ayahs Sprint
                    </button>
                  </div>
                </div>

                {/* Trilingual Ayah Reader Card (Arabic, Transliteration, English, Bengali) */}
                <div className="p-3.5 rounded-2xl bg-[#09221b] border border-emerald-800/60 text-xs space-y-2">
                  <div className="flex items-center justify-between border-b border-emerald-900/50 pb-1.5">
                    <span className="text-[10px] text-amber-300 font-mono font-bold">
                      Ayat al-Kursi (2:255) • ত্রৈভাষিক কুরআন
                    </span>
                    <span className="text-[9px] px-1.5 py-0.5 rounded bg-emerald-950 border border-emerald-800 text-emerald-300 font-mono">
                      Offline SQLite
                    </span>
                  </div>

                  <p className="font-arabic text-base text-amber-100 text-right leading-relaxed dir-rtl">
                    اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ
                  </p>

                  <div className="p-2 rounded-lg bg-[#051511] border border-emerald-900/40 text-[10px] text-amber-200/80 font-mono">
                    Allāhu lā ilāha illā Huwal-Ḥayyul-Qayyūm...
                  </div>

                  <div className="space-y-1.5 pt-1">
                    <div className="p-2 rounded-lg bg-[#071c16] border border-emerald-900/50">
                      <span className="text-[9px] font-mono text-emerald-400 font-bold block mb-0.5">
                        English (Sahih Intl)
                      </span>
                      <p className="text-[10px] text-emerald-100/90 leading-snug">
                        "Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence. Neither drowsiness overtakes Him nor sleep."
                      </p>
                    </div>

                    <div className="p-2 rounded-lg bg-[#08201a] border border-emerald-800/50">
                      <span className="text-[9px] font-mono text-amber-300 font-bold block mb-0.5">
                        বাংলা অনুবাদ (বায়ান ফাউন্ডেশন)
                      </span>
                      <p className="text-[10px] text-white leading-snug">
                        "আল্লাহ, তিনি ছাড়া কোন সত্য উপাস্য নেই; তিনি চিরঞ্জীব, সবকিছুর ধারক। তন্দ্রা বা ঘুম তাঁকে স্পর্শ করে না।"
                      </p>
                    </div>
                  </div>
                </div>

                {/* Micro-Sunnah Daily Checklist */}
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between px-1">
                    <span className="text-xs font-semibold text-amber-300 flex items-center gap-1.5">
                      <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                      Daily Micro-Sunnah Checklist
                    </span>
                    <span className="text-[10px] font-mono text-emerald-400">
                      {sunnahs.filter((s) => s.completed).length} / {sunnahs.length}
                    </span>
                  </div>

                  {showHabitGuideTip && (
                    <div className="p-2.5 rounded-xl bg-amber-500/15 border border-amber-400/40 text-[10px] text-amber-100 flex items-start justify-between gap-2">
                      <div>
                        <strong className="text-amber-300 block">First-Time Habit Tip:</strong>
                        <span>Tap any box below to log a Micro-Sunnah offline and build your streak.</span>
                      </div>
                      <button
                        onClick={() => {
                          setShowHabitGuideTip(false);
                          try {
                            localStorage.setItem('mizan_habit_tip_dismissed', 'true');
                          } catch {
                            // ignore
                          }
                        }}
                        className="text-amber-300 hover:text-white font-mono text-[9px] shrink-0"
                      >
                        Got it
                      </button>
                    </div>
                  )}

                  <div className="space-y-2">
                    {sunnahs.map((sunnah) => (
                      <div
                        key={sunnah.id}
                        onClick={() => toggleSunnah(sunnah.id)}
                        className={`p-2.5 rounded-xl border transition-all cursor-pointer flex items-start gap-2.5 ${
                          sunnah.completed
                            ? 'bg-emerald-950/40 border-emerald-800/40 opacity-80'
                            : 'bg-emerald-950/70 border-emerald-800/60 hover:border-amber-400/50'
                        }`}
                      >
                        <div
                          className={`mt-0.5 w-4 h-4 rounded-md flex items-center justify-center border transition-colors ${
                            sunnah.completed
                              ? 'bg-amber-400 border-amber-400 text-black'
                              : 'border-emerald-700 bg-emerald-950'
                          }`}
                        >
                          {sunnah.completed && <Check className="w-3 h-3 stroke-[3]" />}
                        </div>

                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <h4
                              className={`text-xs font-medium ${
                                sunnah.completed ? 'line-through text-emerald-300/60' : 'text-white'
                              }`}
                            >
                              {sunnah.title}
                            </h4>
                            <span className="text-[10px] font-mono text-amber-300/80">
                              {sunnah.durationMinutes}m
                            </span>
                          </div>
                          <p className="text-[10px] text-emerald-300/70 line-clamp-1 mt-0.5">
                            {sunnah.hadithReference}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* TAB 4: 24-HOUR CIRCADIAN PLANNER */}
            {activeTab === 'planner' && (
              <div className="space-y-3">
                <div
                  className="p-3 rounded-xl bg-emerald-950/60 border border-emerald-800/40"
                >
                  <span className="text-[10px] uppercase font-mono text-amber-300/90 font-medium">
                    Circadian Alignment
                  </span>
                  <h3 className="font-serif text-sm font-bold text-white mt-0.5">
                    Sunnah Circadian Architecture
                  </h3>
                  <p className="text-[11px] text-emerald-200/70 mt-1 leading-relaxed">
                    Synchronizes your biological clock with Islamic spiritual anchors (Fajr dawn, Qaylulah midday rest, Isha sunset).
                  </p>
                </div>

                <div className="space-y-2">
                  {INITIAL_CIRCADIAN_BLOCKS.map((block) => (
                    <div
                      key={block.id}
                      className="p-2.5 rounded-xl bg-[#09221b] border border-emerald-800/50 text-xs space-y-1"
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-[11px] font-semibold text-amber-300">
                          {block.startHour}:00 - {block.endHour}:00
                        </span>
                        <span
                          className="px-1.5 py-0.5 rounded text-[9px] font-bold uppercase tracking-wider"
                          style={{
                            backgroundColor: `${block.color}25`,
                            color: block.color,
                          }}
                        >
                          {block.category.replace('_', ' ')}
                        </span>
                      </div>
                      <h4 className="font-medium text-white text-xs">{block.title}</h4>
                      <p className="text-[10px] text-emerald-300/70 italic leading-snug">
                        {block.sunnahAnchor}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 5: ETHICAL AI COACH (MOTIVATIONAL INTERVIEWING) */}
            {activeTab === 'coach' && (
              <div className="space-y-3">
                <div
                  className="p-3 rounded-xl bg-emerald-950/60 border border-emerald-800/40"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-[10px] uppercase font-mono text-amber-300/90 font-medium">
                      Ethical Behavioral Coach
                    </span>
                    <span className="text-[9px] font-mono px-1.5 py-0.5 rounded bg-emerald-900/70 text-emerald-300 border border-emerald-700/50">
                      {loadGatewayConfig().provider} · {loadGatewayConfig().model}
                    </span>
                  </div>
                  <h3 className="font-serif text-sm font-bold text-white mt-0.5">
                    Motivational Interviewing (OARS)
                  </h3>
                  <p className="text-[11px] text-emerald-200/70 mt-1 leading-relaxed">
                    Zero accusations or guilt-tripping. Explores underlying psychological triggers and suggests 2-minute offline replacements.
                  </p>
                </div>

                {/* Prompt trigger selector */}
                <div className="space-y-1.5">
                  <label className="text-[10px] text-emerald-300/70 block">Select or edit what triggered the urge:</label>
                  <textarea
                    rows={2}
                    value={coachTrigger}
                    onChange={(e) => setCoachTrigger(e.target.value)}
                    className="w-full bg-[#0a201a] border border-emerald-800/60 rounded-xl p-2 text-xs text-white focus:outline-none focus:border-amber-400 resize-none"
                    placeholder="e.g. Procrastinating on hard task..."
                  />
                  <div className="flex flex-wrap gap-1.5 pt-0.5">
                    {[
                      'Late night boredom',
                      'Exhausted after work',
                      'Avoiding difficult task',
                    ].map((preset) => (
                      <button
                        key={preset}
                        onClick={() => setCoachTrigger(preset)}
                        className="px-2 py-0.5 rounded-full bg-emerald-950 border border-emerald-800/60 text-[10px] text-emerald-300 hover:text-white"
                      >
                        {preset}
                      </button>
                    ))}
                  </div>

                  <button
                    disabled={isCoachLoading}
                    onClick={handleAskCoach}
                    className="w-full mt-2 py-2 px-3 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-200 text-xs font-medium flex items-center justify-center gap-1.5 transition-colors disabled:opacity-50"
                  >
                    {isCoachLoading ? (
                      <>
                        <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                        <span>Reflecting with Empathy...</span>
                      </>
                    ) : (
                      <>
                        <Sparkles className="w-3.5 h-3.5 text-amber-400" />
                        <span>Seek Mindful Reflection</span>
                      </>
                    )}
                  </button>
                </div>

                {/* Coach Response Card */}
                {coachResponse && (
                  <motion.div
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="p-3 rounded-xl bg-[#081e18] border border-emerald-700/50 text-xs space-y-2.5"
                  >
                    <div className="flex items-center justify-between text-[10px] text-emerald-400 font-mono">
                      <span>Reflective Listening</span>
                      <span className="text-amber-300">{coachResponse.source}</span>
                    </div>

                    <p className="text-emerald-100/90 leading-relaxed italic">
                      "{coachResponse.empathy}"
                    </p>

                    <div className="p-2 rounded-lg bg-emerald-950/60 border border-emerald-800/40">
                      <span className="text-[10px] font-semibold text-amber-300 block mb-0.5">
                        Open Inquiry:
                      </span>
                      <p className="text-white text-xs">{coachResponse.inquiry}</p>
                    </div>

                    {coachResponse.offlineAlternatives && coachResponse.offlineAlternatives.length > 0 && (
                      <div className="space-y-1">
                        <span className="text-[10px] font-semibold text-emerald-300">
                          2-Minute Actionable Alternative:
                        </span>
                        {coachResponse.offlineAlternatives.map((alt, i) => (
                          <div key={i} className="p-2 rounded-lg bg-[#061814] border border-emerald-900/50">
                            <div className="flex items-center justify-between text-amber-200 font-medium text-xs">
                              <span>{alt.title}</span>
                              <span className="text-[10px] font-mono text-emerald-400">{alt.duration}</span>
                            </div>
                            <p className="text-[10px] text-emerald-300/70 mt-0.5">{alt.action}</p>
                          </div>
                        ))}
                      </div>
                    )}

                    <p className="text-[10px] text-amber-300/80 font-medium pt-1 border-t border-emerald-900/40">
                      ★ {coachResponse.affirmation}
                    </p>
                  </motion.div>
                )}
              </div>
            )}

            {/* TAB 6: PEER ACCOUNTABILITY (P2P CRYPTO PROTOCOL) */}
            {activeTab === 'peers' && (
              <div className="space-y-3">
                <div className="p-3 rounded-xl bg-emerald-950/60 border border-emerald-800/40">
                  <span className="text-[10px] uppercase font-mono text-amber-300/90 font-medium">
                    Anti-Shame Architecture
                  </span>
                  <h3 className="font-serif text-sm font-bold text-white mt-0.5">
                    P2P Cryptographic Ledger
                  </h3>
                  <p className="text-[11px] text-emerald-200/70 mt-1 leading-relaxed">
                    Zero public leaderboards or shaming. Daily habits generate Ed25519 zero-knowledge proof hashes shared peer-to-peer.
                  </p>
                </div>

                {/* My Daily Proof Hash */}
                <div className="p-3 rounded-xl bg-[#09221b] border border-emerald-800/50 space-y-1.5 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-emerald-300 font-medium">My Local Proof Hash</span>
                    <span className="text-[10px] font-mono text-emerald-400">Ed25519 Signed</span>
                  </div>
                  <div className="p-1.5 rounded bg-black/40 font-mono text-[10px] text-amber-300 truncate">
                    {myProofHash}
                  </div>
                  <button
                    onClick={handleGenerateProof}
                    className="w-full py-1.5 px-3 rounded-lg bg-emerald-800/50 hover:bg-emerald-700/60 border border-emerald-600/40 text-xs font-medium text-emerald-100 transition-colors flex items-center justify-center gap-1.5"
                  >
                    <RefreshCw className={`w-3 h-3 ${proofGenerated ? 'animate-spin' : ''}`} />
                    <span>{proofGenerated ? 'Hash Regenerated!' : 'Re-sign Today’s Commitment'}</span>
                  </button>
                </div>

                {/* Peer Network List */}
                <div className="space-y-2">
                  <span className="text-xs font-semibold text-amber-300">Trusted Accountability Companions</span>
                  {peers.map((peer) => (
                    <div
                      key={peer.id}
                      className="p-2.5 rounded-xl bg-emerald-950/50 border border-emerald-800/50 text-xs space-y-1.5"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <div className="w-7 h-7 rounded-full bg-emerald-900 border border-amber-400/40 flex items-center justify-center font-bold text-amber-300 text-xs">
                            {peer.alias[0]}
                          </div>
                          <div>
                            <h4 className="font-medium text-white">{peer.alias}</h4>
                            <span className="text-[10px] text-emerald-300/70 font-mono">
                              Sync {peer.lastSyncTimestamp}
                            </span>
                          </div>
                        </div>

                        <div className="flex items-center gap-1.5">
                          <span className="px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 text-[10px] font-mono font-bold">
                            {peer.streakDays}d Streak
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center justify-between pt-1 border-t border-emerald-900/40 text-[10px]">
                        <span className="text-emerald-400/80 font-mono truncate max-w-[170px]">
                          {peer.cryptographicSignature}
                        </span>
                        <button
                          onClick={() => handleEncouragePeer(peer.id)}
                          disabled={peer.encouragementSent}
                          className={`px-2 py-0.5 rounded-md font-medium transition-colors ${
                            peer.encouragementSent
                              ? 'bg-emerald-900/40 text-emerald-500 cursor-default'
                              : 'bg-emerald-800/50 hover:bg-emerald-700/50 text-emerald-200 border border-emerald-600/30'
                          }`}
                        >
                          {peer.encouragementSent ? '✓ Dua Sent' : 'Send Dua'}
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* TAB 7: PROFILE & OFFLINE AUTH */}
            {activeTab === 'profile' && (
              <div className="space-y-3">
                <ProfileAuthView
                  currentUser={user}
                  onUpdateUser={onUpdateUser}
                  onLogout={onLogout}
                  onOpenCodeFile={onOpenCodeFile}
                />
              </div>
            )}
          </div>

          {/* Bottom Tab Bar (Core Islamic Wellbeing & Identity Pillars) */}
          <div className="px-1.5 pt-2 border-t border-emerald-900/50 bg-[#051310] flex items-center justify-around text-center">
            {[
              { id: 'prayer', label: 'Salah', icon: Clock },
              { id: 'shield', label: 'Shield', icon: Shield },
              { id: 'quran', label: 'Quran', icon: BookOpen },
              { id: 'planner', label: '24h', icon: Calendar },
              { id: 'coach', label: 'Coach', icon: Sparkles },
              { id: 'profile', label: 'Profile', icon: User },
            ].map((tab) => {
              const Icon = tab.icon;
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id as any)}
                  className={`flex flex-col items-center py-1 px-1.5 rounded-xl transition-all ${
                    isActive ? 'text-amber-300 font-semibold' : 'text-emerald-400/60 hover:text-emerald-200'
                  }`}
                >
                  <Icon className={`w-4 h-4 ${isActive ? 'text-amber-400 scale-110' : ''}`} />
                  <span className="text-[9px] mt-0.5">{tab.label}</span>
                </button>
              );
            })}
          </div>

          {/* Simulated Home Indicator Bar */}
          <div className="w-24 h-1 bg-white/20 rounded-full mx-auto mt-2" />

          {/* Interactive OS Overlay Shield (Simulates WindowManager & ScreenTime) */}
          <OverlayShieldModal
            event={activeShieldEvent}
            onDismiss={() => setActiveShieldEvent(null)}
            onSelectAlternative={(title) => {
              setActiveShieldEvent(null);
              if (title.includes('Quran')) {
                setActiveTab('quran');
              } else {
                setActiveTab('quran');
              }
            }}
          />
        </div>
      </div>

      {/* Simulator Device Controls & Specs */}
      <div className="mt-3 flex items-center gap-3 text-xs text-emerald-300/80">
        <span className="flex items-center gap-1.5">
          <span className="w-2 h-2 rounded-full bg-emerald-400" />
          Offline-First Simulator
        </span>
        <span>•</span>
        <button
          onClick={() => onOpenCodeFile('android/app/src/main/kotlin/com/mizan/app/FocusOverlayService.kt')}
          className="text-amber-300 hover:underline flex items-center gap-1"
        >
          View Native Overlay Code
        </button>
      </div>
    </div>
  );
};

import React, { useState } from 'react';
import {
  Smartphone,
  FolderTree,
  Layers,
  Shield,
  Flame,
  Award,
  Sparkles,
  BookOpen,
  Compass,
  CheckCircle2,
  Clock,
  Heart,
  ExternalLink,
  Code2,
  User,
  Bot,
  Cpu,
  HelpCircle
} from 'lucide-react';
import { PhoneSimulator } from './components/PhoneSimulator';
import { ArchitectureExplorer } from './components/ArchitectureExplorer';
import { SystemArchitectureDiagram } from './components/SystemArchitectureDiagram';
import { StreaksAndRewardsView } from './components/StreaksAndRewardsView';
import { ProfileAuthView } from './components/ProfileAuthView';
import { MultilingualQuranView } from './components/MultilingualQuranView';
import { HolisticAIAgentView } from './components/HolisticAIAgentView';
import { InteractiveCompanionView } from './components/InteractiveCompanionView';
import { MultiAIGatewayView } from './components/MultiAIGatewayView';
import { OnboardingAssistantModal } from './components/OnboardingAssistantModal';
import { ProminentDisclosureModal } from './components/ProminentDisclosureModal';
import { UserProfile } from './types';
import { INITIAL_MICRO_SUNNAHS } from './data/mockData';

const DEFAULT_USER: UserProfile = {
  id: 'usr_default_1',
  email: 'tariq.ansari@mizan.app',
  displayName: 'Tariq Al-Ansari',
  avatarPreset: 'crescent',
  isAnonymous: false,
  createdAt: '2026-10-15T08:00:00.000Z',
  spiritualGoal: 'Preserving the five daily prayers with Khushu and 21 days of Reels-free focus',
  preferredMadhab: 'SHAFI',
  calculationMethod: 'MWL',
  biometricEnabled: true,
  storedPasswordHash: 'pbkdf2_sha256$100000$c9a10f...82e9',
  storedSalt: 'secure_csprng_salt_77a9',
};

export default function App() {
  const [activeMainTab, setActiveMainTab] = useState<
    'simulator' | 'gateway' | 'companion' | 'agent' | 'quran' | 'streaks' | 'profile' | 'explorer' | 'architecture' | 'constitution'
  >('simulator');

  const [currentUser, setCurrentUser] = useState<UserProfile | null>(() => {
    const saved = localStorage.getItem('mizan_active_user');
    return saved ? JSON.parse(saved) : DEFAULT_USER;
  });

  const [selectedFilePath, setSelectedFilePath] = useState<string>(
    'lib/features/auth/data/secure_auth_repository.dart'
  );
  const [showDisclosureModal, setShowDisclosureModal] = useState<boolean>(false);
  const [showOnboardingTour, setShowOnboardingTour] = useState<boolean>(false);
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState<boolean>(() => {
    try {
      return localStorage.getItem('mizan_onboarding_completed') === 'true';
    } catch {
      return false;
    }
  });

  const handleCompleteOnboarding = () => {
    setHasCompletedOnboarding(true);
    try {
      localStorage.setItem('mizan_onboarding_completed', 'true');
    } catch {
      // ignore
    }
  };

  React.useEffect(() => {
    const openTour = () => setShowOnboardingTour(true);
    const openDisclosure = () => setShowDisclosureModal(true);
    const navigateTab = (e: Event) => {
      const targetTab = (e as CustomEvent<string>).detail;
      if (targetTab) setActiveMainTab(targetTab as any);
    };
    window.addEventListener('mizan:open-onboarding', openTour);
    window.addEventListener('mizan:open-disclosure', openDisclosure);
    window.addEventListener('mizan:navigate-tab', navigateTab);
    return () => {
      window.removeEventListener('mizan:open-onboarding', openTour);
      window.removeEventListener('mizan:open-disclosure', openDisclosure);
      window.removeEventListener('mizan:navigate-tab', navigateTab);
    };
  }, []);

  const handleUpdateUser = (updated: UserProfile) => {
    setCurrentUser(updated);
    localStorage.setItem('mizan_active_user', JSON.stringify(updated));
  };

  const handleLogout = () => {
    setCurrentUser(null);
    localStorage.removeItem('mizan_active_user');
  };

  const handleOpenCodeFile = (path: string) => {
    setSelectedFilePath(path);
    setActiveMainTab('explorer');
  };

  return (
    <div className="min-h-screen bg-[#051210] text-[#e2e8f0] bg-islamic-pattern pb-16">
      {/* Top Banner & Architectural Identity */}
      <header className="border-b border-emerald-900/60 bg-[#061814]/90 backdrop-blur-md sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-3.5 flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-amber-500 via-amber-400 to-emerald-600 flex items-center justify-center shadow-lg shadow-amber-500/20 text-[#061814] font-bold text-xl font-arabic">
              م
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="font-title text-xl font-bold tracking-wide text-white">
                  Mīzān <span className="font-arabic text-amber-300 text-lg">ميزان</span>
                </h1>
                <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-400/40 text-amber-300 font-semibold">
                  Flutter Architecture
                </span>
                <button
                  onClick={() => setShowOnboardingTour(true)}
                  className="ml-1 py-1 px-2.5 rounded-full bg-gradient-to-r from-amber-500/30 to-emerald-600/40 hover:from-amber-500/40 hover:to-emerald-600/50 border border-amber-400/50 text-amber-300 text-[10px] font-semibold flex items-center gap-1.5 transition-all shadow-sm"
                  title="Launch Interactive Onboarding Tour"
                >
                  <HelpCircle className="w-3 h-3 text-amber-400" />
                  <span>Onboarding Tour &amp; Guide</span>
                </button>
              </div>
              <p className="text-xs text-emerald-300/80">
                Cross-Platform Islamic Habit Tracker &amp; Digital Wellbeing Framework
              </p>
            </div>
          </div>

          {/* Main Navigation Tabs */}
          <nav className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0">
            {[
              { id: 'simulator', label: 'Interactive App', icon: Smartphone },
              { id: 'gateway', label: 'Multi-AI Gateway (BYOK)', icon: Cpu },
              { id: 'companion', label: 'AI Floating Companion', icon: Sparkles },
              { id: 'agent', label: 'Al-Murshid AI Agent', icon: Bot },
              { id: 'quran', label: 'Quran & Sunnah (বাংলা/EN)', icon: BookOpen },
              { id: 'streaks', label: 'Habit Streaks & Badges', icon: Flame },
              { id: 'profile', label: 'Identity & Security', icon: User },
              { id: 'explorer', label: 'Source Code Explorer', icon: Code2 },
              { id: 'architecture', label: 'System Diagrams', icon: Layers },
              { id: 'constitution', label: 'Ethical Constitution', icon: Shield },
            ].map((tab) => {
              const Icon = tab.icon;
              const isActive = activeMainTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveMainTab(tab.id as any)}
                  className={`flex items-center gap-2 py-2 px-3.5 rounded-xl text-xs font-medium transition-all whitespace-nowrap ${
                    isActive
                      ? 'bg-gradient-to-r from-amber-500/25 to-emerald-800/40 text-amber-300 border border-amber-400/50 shadow-sm'
                      : 'text-emerald-300/70 hover:text-white hover:bg-emerald-950/60 border border-transparent'
                  }`}
                >
                  <Icon className={`w-3.5 h-3.5 ${isActive ? 'text-amber-400' : ''}`} />
                  <span>{tab.label}</span>
                </button>
              );
            })}
          </nav>
        </div>
      </header>

      {/* Main Container Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 pt-6 space-y-5">
        {/* Proactive First-Time User Onboarding Assistant Banner */}
        {!hasCompletedOnboarding && (
          <div className="p-4 rounded-2xl bg-gradient-to-r from-[#082920] via-[#0a362a] to-[#07211a] border border-amber-400/40 shadow-lg flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div className="flex items-start gap-3">
              <div className="w-9 h-9 rounded-xl bg-amber-500/20 border border-amber-400/40 flex items-center justify-center shrink-0">
                <Bot className="w-5 h-5 text-amber-300" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h2 className="font-serif text-sm font-bold text-white">
                    Welcome to Mīzān — Need a Quick Interactive Tour?
                  </h2>
                  <span className="text-[9px] font-mono px-1.5 py-0.5 rounded bg-amber-400 text-black font-bold">
                    FIRST VISIT
                  </span>
                </div>
                <p className="text-xs text-emerald-200/80 mt-0.5">
                  Our Onboarding AI Agent can walk you through app navigation, how to log daily Micro-Sunnahs, and how to configure your Multi-AI Gateway keys.
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2 shrink-0">
              <button
                onClick={handleCompleteOnboarding}
                className="py-1.5 px-3 rounded-xl border border-emerald-700/60 text-xs text-emerald-300 hover:text-white hover:bg-emerald-950/60 transition-colors"
              >
                Dismiss
              </button>
              <button
                onClick={() => setShowOnboardingTour(true)}
                className="py-1.5 px-3.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-black font-bold text-xs flex items-center gap-1.5 transition-colors shadow-md"
              >
                <Sparkles className="w-3.5 h-3.5" />
                <span>Start Interactive Guide</span>
              </button>
            </div>
          </div>
        )}

        {/* VIEW 1: INTERACTIVE MOBILE APP SIMULATOR */}
        {activeMainTab === 'simulator' && (
          <div className="space-y-6">
            <div className="flex flex-col lg:flex-row items-center lg:items-start justify-center gap-8">
              {/* Phone Device Viewport */}
              <div className="shrink-0">
                <PhoneSimulator
                  onShowProminentDisclosure={() => setShowDisclosureModal(true)}
                  onOpenCodeFile={handleOpenCodeFile}
                  onLaunchOnboarding={() => setShowOnboardingTour(true)}
                  user={currentUser}
                  onUpdateUser={handleUpdateUser}
                  onLogout={handleLogout}
                />
              </div>

              {/* Architectural Highlights & Interactive Controls Panel */}
              <div className="flex-1 max-w-2xl space-y-4">
                <div className="p-5 rounded-3xl bg-[#071d17] border border-emerald-800/60 shadow-xl space-y-3">
                  <span className="text-[10px] font-mono uppercase tracking-wider text-amber-300 font-bold">
                    Lead Mobile Framework Architecture
                  </span>
                  <h2 className="font-serif text-2xl font-bold text-white">
                    Offline-First Spiritual Routine &amp; Digital Wellbeing
                  </h2>
                  <p className="text-xs text-emerald-200/80 leading-relaxed">
                    Designed for zero network dependency, data sovereignty, and ethical mindfulness. Built using Flutter 3.x, Riverpod 2.x compile-safe state management, and memory-mapped Hive binary boxes.
                  </p>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
                    <div className="p-3 rounded-2xl bg-[#051511] border border-emerald-900/60">
                      <div className="flex items-center gap-2 text-amber-300 text-xs font-semibold mb-1">
                        <Clock className="w-4 h-4 text-amber-400" />
                        <span>Adhan Calculation Engine</span>
                      </div>
                      <p className="text-[11px] text-emerald-300/70 leading-snug">
                        Offline GPS calculation of solar coordinates with custom Madhab (Shafi/Hanafi) and Qibla direction.
                      </p>
                    </div>

                    <div className="p-3 rounded-2xl bg-[#051511] border border-emerald-900/60">
                      <div className="flex items-center gap-2 text-amber-300 text-xs font-semibold mb-1">
                        <Shield className="w-4 h-4 text-amber-400" />
                        <span>Short-Form Video Shield</span>
                      </div>
                      <p className="text-[11px] text-emerald-300/70 leading-snug">
                        Android AccessibilityService &amp; iOS ScreenTime detect Reels/Shorts with non-coercive 7-second pause.
                      </p>
                    </div>

                    <div className="p-3 rounded-2xl bg-[#051511] border border-emerald-900/60">
                      <div className="flex items-center gap-2 text-amber-300 text-xs font-semibold mb-1">
                        <Flame className="w-4 h-4 text-amber-400" />
                        <span>Ethical Streaks &amp; Rewards</span>
                      </div>
                      <p className="text-[11px] text-emerald-300/70 leading-snug">
                        Zero dark patterns, Istighfar grace days, and Islamic milestone badges rooted in authentic Hadith.
                      </p>
                    </div>

                    <div className="p-3 rounded-2xl bg-[#051511] border border-emerald-900/60">
                      <div className="flex items-center gap-2 text-amber-300 text-xs font-semibold mb-1">
                        <Sparkles className="w-4 h-4 text-amber-400" />
                        <span>Motivational AI Coaching</span>
                      </div>
                      <p className="text-[11px] text-emerald-300/70 leading-snug">
                        Non-judgmental OARS coaching exploring underlying triggers with 2-minute offline alternatives.
                      </p>
                    </div>
                  </div>
                </div>

                {/* Quick Inspection Buttons */}
                <div className="p-4 rounded-2xl bg-[#061814] border border-emerald-900/60 flex flex-wrap items-center justify-between gap-3 text-xs">
                  <span className="text-emerald-300/70">Jump to production code:</span>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() =>
                        handleOpenCodeFile(
                          'android/app/src/main/kotlin/com/mizan/app/ShortsBlockerAccessibilityService.kt'
                        )
                      }
                      className="py-1 px-2.5 rounded-lg bg-emerald-900/50 hover:bg-emerald-800/60 text-emerald-200 border border-emerald-700/50 transition-colors"
                    >
                      Android Shorts Blocker
                    </button>
                    <button
                      onClick={() =>
                        handleOpenCodeFile('ios/Runner/ScreenTimeBridge.swift')
                      }
                      className="py-1 px-2.5 rounded-lg bg-emerald-900/50 hover:bg-emerald-800/60 text-emerald-200 border border-emerald-700/50 transition-colors"
                    >
                      iOS ScreenTime Bridge
                    </button>
                    <button
                      onClick={() =>
                        handleOpenCodeFile(
                          'lib/features/streaks/presentation/providers/habit_streak_provider.dart'
                        )
                      }
                      className="py-1 px-2.5 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 border border-amber-400/40 transition-colors"
                    >
                      Habit Streaks Provider
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* VIEW 2: MULTI-AI GATEWAY (BYOK - GEMINI, OPENAI, CLAUDE, DEEPSEEK) */}
        {activeMainTab === 'gateway' && (
          <MultiAIGatewayView
            onOpenCodeFile={handleOpenCodeFile}
            onNavigateTab={(tab) => setActiveMainTab(tab as any)}
          />
        )}

        {/* VIEW 3: AL-MURSHID 24/7 AUTONOMOUS AI AGENT */}
        {activeMainTab === 'agent' && (
          <HolisticAIAgentView
            currentUser={currentUser}
            habits={INITIAL_MICRO_SUNNAHS}
            onOpenCodeFile={handleOpenCodeFile}
            onNavigateTab={(tab) => setActiveMainTab(tab as any)}
          />
        )}

        {/* VIEW 3: INTERACTIVE GEMINI AI COMPANION (FLOATING OVERLAY & SOUNDBOARD) */}
        {activeMainTab === 'companion' && (
          <InteractiveCompanionView
            onOpenCodeFile={handleOpenCodeFile}
            onNavigateTab={(tab) => setActiveMainTab(tab as any)}
          />
        )}

        {/* VIEW 4: MULTILINGUAL QURAN & SUNNAH (BANGLA & ENGLISH) */}
        {activeMainTab === 'quran' && (
          <MultilingualQuranView onOpenCodeFile={handleOpenCodeFile} />
        )}

        {/* VIEW 3: GAMIFIED HABIT STREAKS & REWARDS */}
        {activeMainTab === 'streaks' && (
          <StreaksAndRewardsView onOpenCodeFile={handleOpenCodeFile} />
        )}

        {/* VIEW 5: IDENTITY & SECURE OFFLINE AUTH */}
        {activeMainTab === 'profile' && (
          <ProfileAuthView
            currentUser={currentUser}
            onUpdateUser={handleUpdateUser}
            onLogout={handleLogout}
            onOpenCodeFile={handleOpenCodeFile}
          />
        )}

        {/* VIEW 3: LEAD ARCHITECT CODE EXPLORER */}
        {activeMainTab === 'explorer' && (
          <ArchitectureExplorer initialFilePath={selectedFilePath} />
        )}

        {/* VIEW 4: SYSTEM ARCHITECTURE DIAGRAMS */}
        {activeMainTab === 'architecture' && (
          <SystemArchitectureDiagram onOpenCodeFile={handleOpenCodeFile} />
        )}

        {/* VIEW 5: ETHICAL CONSTITUTION & STORE POLICIES */}
        {activeMainTab === 'constitution' && (
          <div className="space-y-6">
            <div className="p-6 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-4">
              <div className="flex items-center gap-3">
                <div className="p-3 rounded-2xl bg-amber-500/20 border border-amber-400/50 text-amber-300">
                  <Shield className="w-6 h-6" />
                </div>
                <div>
                  <span className="text-[10px] font-mono uppercase tracking-wider text-amber-300 font-bold">
                    The Mīzān Ethical Charter
                  </span>
                  <h2 className="font-serif text-2xl font-bold text-white">
                    The 7 Pillars of Ethical Digital Wellbeing
                  </h2>
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
                {[
                  {
                    num: '01',
                    title: 'Autonomy Over Hostage-Taking',
                    desc: 'Mīzān never traps the user in an inescapable screen or uses hostile countdown locks. Every shield includes a deliberate, mindful 7-second physiological breathing bypass.',
                  },
                  {
                    num: '02',
                    title: 'Zero Guilt or Shame Framing',
                    desc: 'Traditional blockers use shame-inducing notifications ("You failed again", "You wasted 2 hours"). Mīzān adopts Motivational Interviewing (OARS) to invite self-compassion and reflection.',
                  },
                  {
                    num: '03',
                    title: '100% Local Data Sovereignty',
                    desc: 'Your prayer times, habits, Quran bookmarks, and screen time statistics are saved in offline Hive binary boxes on your hardware. Zero telemetry. Zero remote servers.',
                  },
                  {
                    num: '04',
                    title: 'Compassionate "Istighfar Grace Days"',
                    desc: 'Habit streaks do not punish illness, travel, or emergencies. Two monthly grace tokens preserve streaks automatically, preventing the toxic all-or-nothing abandonment syndrome.',
                  },
                  {
                    num: '05',
                    title: 'Strict Prominent Disclosure',
                    desc: 'Under Google Play Accessibility API policies, Mīzān clearly explains in-app why the AccessibilityService is requested BEFORE navigating the user to OS settings.',
                  },
                  {
                    num: '06',
                    title: 'P2P Cryptographic Accountability',
                    desc: 'No public leaderboards or competitive rank humiliation. Accountability partners share zero-knowledge cryptographic hashes (Ed25519) that verify consistency without exposing granular private life.',
                  },
                  {
                    num: '07',
                    title: 'Actionable 2-Minute Physical Alternatives',
                    desc: 'Breaking a dopamine loop requires a tangible replacement. Every intervention presents immediately actionable micro-actions: cool wudu, 33x tasbih, or looking at the sky.',
                  },
                ].map((pillar) => (
                  <div
                    key={pillar.num}
                    className="p-4 rounded-2xl bg-[#09221b] border border-emerald-900/60 space-y-1.5"
                  >
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-xs font-bold text-amber-400">
                        {pillar.num}
                      </span>
                      <h4 className="font-serif font-bold text-sm text-white">
                        {pillar.title}
                      </h4>
                    </div>
                    <p className="text-xs text-emerald-200/80 leading-relaxed">
                      {pillar.desc}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* Google Play Review Checklist */}
            <div className="p-5 rounded-2xl bg-[#081e18] border border-emerald-800/50 space-y-3">
              <h3 className="font-serif text-base font-bold text-amber-300">
                Google Play &amp; Apple App Store Submission Guide
              </h3>
              <p className="text-xs text-emerald-200/80 leading-relaxed">
                To guarantee seamless store approval for Accessibility &amp; ScreenTime entitlements:
              </p>
              <ul className="text-xs text-emerald-200/70 space-y-1.5 list-disc pl-5">
                <li>
                  <strong>Android:</strong> Record a 30-second video showing the in-app Prominent Disclosure dialog appearing before opening Accessibility Settings. Submit with declaration: "Mīzān uses Accessibility API exclusively to detect short-form video URLs and view IDs for digital wellbeing overlays."
                </li>
                <li>
                  <strong>iOS:</strong> Submit the Apple FamilyControls entitlement request form highlighting the digital wellbeing use case. Ensure the app adheres to ManagedSettings guidelines without third-party tracking.
                </li>
              </ul>
            </div>
          </div>
        )}
      </main>

      {/* Prominent Disclosure Modal */}
      <ProminentDisclosureModal
        isOpen={showDisclosureModal}
        onClose={() => setShowDisclosureModal(false)}
      />

      {/* Interactive Onboarding Tour & AI Guidance Modal */}
      <OnboardingAssistantModal
        isOpen={showOnboardingTour}
        onClose={() => setShowOnboardingTour(false)}
        onCompleteTour={handleCompleteOnboarding}
        onNavigateTab={(tab) => setActiveMainTab(tab as any)}
        onOpenCodeFile={handleOpenCodeFile}
        onOpenDisclosure={() => setShowDisclosureModal(true)}
      />
    </div>
  );
}

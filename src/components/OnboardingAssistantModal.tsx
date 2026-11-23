import React, { useState, useEffect, useRef } from 'react';
import {
  Compass,
  CheckCircle2,
  HelpCircle,
  Sparkles,
  ChevronRight,
  ChevronLeft,
  X,
  Send,
  ExternalLink,
  Shield,
  Bot,
  MessageSquare,
  Code2,
  ArrowRight
} from 'lucide-react';
import { OnboardingStep } from '../types';
import { DEFAULT_ONBOARDING_STEPS, APP_HELP_TOPICS } from '../data/onboardingData';
import { loadGatewayConfig, getActiveGatewayHeaders } from '../utils/aiGatewayClient';

interface OnboardingAssistantModalProps {
  isOpen: boolean;
  onClose: () => void;
  onCompleteTour?: () => void;
  onNavigateTab: (tabId: string) => void;
  onOpenCodeFile: (path: string) => void;
  onOpenDisclosure?: () => void;
}

const FEATURE_TAB_LABELS: Record<string, { tabId: string; label: string }> = {
  simulator: { tabId: 'simulator', label: 'Open Interactive App' },
  salah: { tabId: 'simulator', label: 'Open Salah & Habits' },
  shield: { tabId: 'simulator', label: 'Open OS Video Shield' },
  planner: { tabId: 'simulator', label: 'Open 24h Planner' },
  streaks: { tabId: 'streaks', label: 'Open Habit Streaks & Badges' },
  companion: { tabId: 'companion', label: 'Open Floating Companion' },
  quran: { tabId: 'quran', label: 'Open Quran & Sunnah' },
  gateway: { tabId: 'gateway', label: 'Open Multi-AI Gateway' },
  agent: { tabId: 'agent', label: 'Open Al-Murshid Agent' },
  profile: { tabId: 'profile', label: 'Open Identity & Security' },
  architecture: { tabId: 'architecture', label: 'Open System Diagrams' },
};

export const OnboardingAssistantModal: React.FC<OnboardingAssistantModalProps> = ({
  isOpen,
  onClose,
  onCompleteTour,
  onNavigateTab,
  onOpenCodeFile,
  onOpenDisclosure,
}) => {
  const [activeMode, setActiveMode] = useState<'tour' | 'qa'>('tour');
  const [currentStepIndex, setCurrentStepIndex] = useState<number>(0);
  const [steps, setSteps] = useState<OnboardingStep[]>(DEFAULT_ONBOARDING_STEPS);
  const [syncLiveView, setSyncLiveView] = useState<boolean>(true);

  // Q&A State
  const [userQuery, setUserQuery] = useState<string>('');
  const [isAsking, setIsAsking] = useState<boolean>(false);
  const chatScrollRef = useRef<HTMLDivElement>(null);
  const [chatLog, setChatLog] = useState<{
    id: string;
    sender: 'user' | 'agent';
    text: string;
    targetFeature?: string;
    actionTip?: string;
    suggestedFollowUps?: string[];
    source?: string;
  }[]>([
    {
      id: 'welcome',
      sender: 'agent',
      text: 'As-salamu alaykum! I am your interactive onboarding guide. Ask me anything about how Mīzān works—from navigating the workspace, logging daily Micro-Sunnahs, and using Istighfar Grace Days, to configuring the Multi-AI Gateway (Gemini, OpenAI, Claude, DeepSeek).',
      actionTip: 'Select a question below or type your own.',
      suggestedFollowUps: [
        'How do I log a daily habit or Sunnah?',
        'How do I navigate between features?',
        'How do I set up the Multi-AI Gateway?',
      ],
    },
  ]);

  const currentStep = steps[currentStepIndex];

  useEffect(() => {
    if (chatScrollRef.current) {
      chatScrollRef.current.scrollTop = chatScrollRef.current.scrollHeight;
    }
  }, [chatLog, isAsking]);

  const markStepCompleted = (index: number) => {
    setSteps((prev) =>
      prev.map((s, i) => (i === index ? { ...s, completed: true } : s))
    );
  };

  const goToStep = (nextIndex: number) => {
    markStepCompleted(currentStepIndex);
    setCurrentStepIndex(nextIndex);
    if (syncLiveView && steps[nextIndex]) {
      onNavigateTab(steps[nextIndex].targetView);
    }
  };

  const handleNextStep = () => {
    if (currentStepIndex < steps.length - 1) {
      goToStep(currentStepIndex + 1);
    }
  };

  const handlePrevStep = () => {
    if (currentStepIndex > 0) {
      goToStep(currentStepIndex - 1);
    }
  };

  const handleFinishTour = () => {
    markStepCompleted(currentStepIndex);
    onCompleteTour?.();
    onClose();
  };

  const handleJumpToFeature = (targetView: string) => {
    const resolved = FEATURE_TAB_LABELS[targetView]?.tabId || targetView;
    onNavigateTab(resolved);
    onClose();
  };

  const handleSendQuery = async (queryText?: string) => {
    const text = queryText || userQuery;
    if (!text.trim() || isAsking) return;

    const userEntry = {
      id: `usr_${Date.now()}`,
      sender: 'user' as const,
      text: text.trim(),
    };

    setChatLog((prev) => [...prev, userEntry]);
    setUserQuery('');
    setIsAsking(true);

    const gateway = loadGatewayConfig();

    try {
      const res = await fetch('/api/onboarding/ask', {
        method: 'POST',
        headers: getActiveGatewayHeaders(),
        body: JSON.stringify({
          question: text.trim(),
          currentStep: currentStep?.title || 'General App Usage',
          provider: gateway.provider,
          model: gateway.model,
        }),
      });

      const data = await res.json();

      setChatLog((prev) => [
        ...prev,
        {
          id: `agent_${Date.now()}`,
          sender: 'agent' as const,
          text:
            data.answer ||
            'Mīzān empowers your spiritual consistency with complete offline autonomy.',
          targetFeature: data.targetFeature,
          actionTip: data.actionTip,
          suggestedFollowUps: data.suggestedFollowUps,
          source: data.source || `${gateway.provider} (${gateway.model})`,
        },
      ]);
    } catch {
      setChatLog((prev) => [
        ...prev,
        {
          id: `agent_${Date.now()}`,
          sender: 'agent' as const,
          text: 'Mīzān is built offline-first: habit data is saved to binary Hive boxes, prayer times are calculated from solar coordinates, and the complete Holy Quran is stored locally in SQLite with FTS5 search.',
          targetFeature: 'simulator',
          actionTip: 'Tap on any feature tab in the main navigation to explore it directly.',
        },
      ]);
    } finally {
      setIsAsking(false);
    }
  };

  if (!isOpen) return null;

  const gatewayCfg = loadGatewayConfig();

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-fade-in">
      <div className="relative w-full max-w-2xl bg-[#061814] rounded-3xl border border-emerald-800/80 shadow-2xl flex flex-col max-h-[88vh] overflow-hidden text-[#e2e8f0]">
        {/* Top Header */}
        <div className="p-4 sm:p-5 border-b border-emerald-900/60 bg-[#07201a] flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-tr from-amber-500 to-emerald-600 flex items-center justify-center text-black font-bold shadow-md shadow-amber-500/20">
              <Bot className="w-5 h-5 text-black" />
            </div>
            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <h3 className="font-serif text-lg font-bold text-white">
                  Interactive Onboarding Assistant
                </h3>
                <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-300 border border-amber-400/40 font-semibold">
                  Al-Murshid Guide
                </span>
              </div>
              <p className="text-xs text-emerald-300/80">
                Guided navigation, habit logging tutorial &amp; live Q&amp;A
              </p>
            </div>
          </div>

          <div className="flex items-center gap-1.5">
            <button
              onClick={() => {
                onClose();
                onOpenCodeFile('lib/features/onboarding/presentation/screens/interactive_onboarding_screen.dart');
              }}
              className="hidden sm:flex items-center gap-1 py-1.5 px-2.5 rounded-xl bg-emerald-950 hover:bg-emerald-900 text-[10px] font-mono text-emerald-300 border border-emerald-800/60"
              title="Inspect Flutter Onboarding Source Code"
            >
              <Code2 className="w-3 h-3 text-amber-400" />
              <span>Flutter Code</span>
            </button>
            <button
              onClick={onClose}
              className="p-2 rounded-xl text-emerald-400 hover:text-white hover:bg-emerald-950 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Mode Switcher Tabs */}
        <div className="px-5 pt-3 bg-[#051511] flex items-center justify-between gap-2 border-b border-emerald-900/40 text-xs flex-wrap">
          <div className="flex items-center gap-2">
            <button
              onClick={() => setActiveMode('tour')}
              className={`py-2 px-3.5 rounded-t-xl font-medium flex items-center gap-2 transition-all border-b-2 ${
                activeMode === 'tour'
                  ? 'border-amber-400 text-amber-300 bg-[#061e18]'
                  : 'border-transparent text-emerald-300/70 hover:text-white'
              }`}
            >
              <Compass className="w-3.5 h-3.5" />
              <span>Interactive Guided Tour ({currentStepIndex + 1}/{steps.length})</span>
            </button>

            <button
              onClick={() => setActiveMode('qa')}
              className={`py-2 px-3.5 rounded-t-xl font-medium flex items-center gap-2 transition-all border-b-2 ${
                activeMode === 'qa'
                  ? 'border-amber-400 text-amber-300 bg-[#061e18]'
                  : 'border-transparent text-emerald-300/70 hover:text-white'
              }`}
            >
              <MessageSquare className="w-3.5 h-3.5" />
              <span>Ask Al-Murshid Q&amp;A</span>
            </button>
          </div>

          {activeMode === 'tour' && (
            <label className="flex items-center gap-1.5 pb-2 text-[11px] text-emerald-300/80 cursor-pointer">
              <input
                type="checkbox"
                checked={syncLiveView}
                onChange={(e) => setSyncLiveView(e.target.checked)}
                className="accent-amber-400"
              />
              <span>Auto-sync background view</span>
            </label>
          )}
        </div>

        {/* Content Body */}
        <div className="flex-1 overflow-y-auto p-5 space-y-4">
          {/* MODE 1: STEP-BY-STEP INTERACTIVE TOUR */}
          {activeMode === 'tour' && (
            <div className="space-y-4">
              {/* Progress Indicator Bar */}
              <div className="space-y-1.5">
                <div className="flex items-center justify-between text-xs text-emerald-300/70 font-mono">
                  <span>STEP {currentStepIndex + 1} OF {steps.length}</span>
                  <span className="text-amber-300 font-semibold">{currentStep.title}</span>
                </div>
                <div className="w-full h-1.5 bg-emerald-950 rounded-full overflow-hidden flex">
                  {steps.map((_, i) => (
                    <div
                      key={i}
                      className={`flex-1 h-full transition-all duration-300 ${
                        i <= currentStepIndex ? 'bg-amber-400' : 'bg-emerald-900/50'
                      } ${i < steps.length - 1 ? 'border-r border-[#061814]' : ''}`}
                    />
                  ))}
                </div>
              </div>

              {/* Step Card Details */}
              <div className="p-5 rounded-2xl bg-[#07241d] border border-emerald-800/60 shadow-lg space-y-3">
                <div className="flex items-start justify-between">
                  <div>
                    <span className="text-[10px] font-mono text-amber-300 uppercase tracking-wider font-bold">
                      Feature Spotlight
                    </span>
                    <h4 className="font-serif text-xl font-bold text-white mt-0.5">
                      {currentStep.title}
                    </h4>
                    <p className="text-xs text-emerald-300/90 font-medium">
                      {currentStep.subtitle}
                    </p>
                  </div>
                  <div className="w-10 h-10 rounded-xl bg-black/40 border border-emerald-700/50 flex items-center justify-center text-lg">
                    {currentStepIndex === 0 && '🕋'}
                    {currentStepIndex === 1 && '🛡️'}
                    {currentStepIndex === 2 && '🔥'}
                    {currentStepIndex === 3 && '✨'}
                    {currentStepIndex === 4 && '📖'}
                    {currentStepIndex === 5 && '⚡'}
                  </div>
                </div>

                <p className="text-xs text-emerald-100/85 leading-relaxed pt-1">
                  {currentStep.explanation}
                </p>

                {/* Direct Action Link */}
                <div className="pt-2 border-t border-emerald-800/50 flex flex-wrap items-center justify-between gap-2">
                  <span className="text-[11px] text-emerald-300/70">Ready to try this in the app?</span>
                  <div className="flex items-center gap-2">
                    {currentStep.targetFeature === 'accessibility_shield' && onOpenDisclosure && (
                      <button
                        onClick={() => {
                          onClose();
                          onOpenDisclosure();
                        }}
                        className="py-1.5 px-3 rounded-xl bg-emerald-900/70 hover:bg-emerald-800 text-emerald-100 border border-emerald-700/60 font-semibold text-xs flex items-center gap-1.5 transition-colors whitespace-nowrap"
                      >
                        <Shield className="w-3 h-3 text-amber-400" />
                        <span>Accessibility Disclosure</span>
                      </button>
                    )}
                    <button
                      onClick={() => handleJumpToFeature(currentStep.targetView)}
                      className="py-1.5 px-3 rounded-xl bg-amber-500 hover:bg-amber-400 text-black font-bold text-xs flex items-center gap-1.5 transition-colors shadow-md shadow-amber-500/20 whitespace-nowrap"
                    >
                      <span>{currentStep.actionLabel}</span>
                      <ExternalLink className="w-3 h-3" />
                    </button>
                  </div>
                </div>
              </div>

              {/* Tour Navigation Controls */}
              <div className="flex items-center justify-between pt-2">
                <button
                  onClick={handlePrevStep}
                  disabled={currentStepIndex === 0}
                  className="py-2 px-3.5 rounded-xl border border-emerald-800/60 text-xs text-emerald-300 disabled:opacity-30 disabled:cursor-not-allowed hover:bg-emerald-950 flex items-center gap-1"
                >
                  <ChevronLeft className="w-4 h-4" />
                  <span>Previous</span>
                </button>

                <div className="flex items-center gap-1.5">
                  {steps.map((st, idx) => (
                    <button
                      key={st.id}
                      onClick={() => goToStep(idx)}
                      title={st.title}
                      className={`w-2.5 h-2.5 rounded-full transition-all ${
                        idx === currentStepIndex
                          ? 'bg-amber-400 scale-125'
                          : st.completed
                          ? 'bg-emerald-500'
                          : 'bg-emerald-900 hover:bg-emerald-700'
                      }`}
                    />
                  ))}
                </div>

                {currentStepIndex < steps.length - 1 ? (
                  <button
                    onClick={handleNextStep}
                    className="py-2 px-4 rounded-xl bg-emerald-800 hover:bg-emerald-700 text-emerald-100 text-xs font-semibold flex items-center gap-1 shadow-md"
                  >
                    <span>Next Pillar</span>
                    <ChevronRight className="w-4 h-4" />
                  </button>
                ) : (
                  <button
                    onClick={handleFinishTour}
                    className="py-2 px-4 rounded-xl bg-gradient-to-r from-emerald-500 to-amber-500 text-black text-xs font-bold flex items-center gap-1 shadow-md"
                  >
                    <CheckCircle2 className="w-4 h-4" />
                    <span>Complete Tour!</span>
                  </button>
                )}
              </div>
            </div>
          )}

          {/* MODE 2: INTERACTIVE ONBOARDING Q&A ASSISTANT */}
          {activeMode === 'qa' && (
            <div className="space-y-4">
              {/* Active Multi-AI Gateway Strip & Help Topics */}
              <div className="flex flex-wrap items-center justify-between gap-2 pb-2 border-b border-emerald-900/50 text-[11px]">
                <span className="text-emerald-300/80 font-mono">
                  Gateway Route: <strong className="text-amber-300">{gatewayCfg.provider} · {gatewayCfg.model}</strong>
                </span>
                <div className="flex items-center gap-2">
                  {onOpenDisclosure && (
                    <button
                      onClick={() => {
                        onClose();
                        onOpenDisclosure();
                      }}
                      className="text-emerald-300 hover:text-amber-300 underline font-medium"
                    >
                      Accessibility Disclosure
                    </button>
                  )}
                  <button
                    onClick={() => handleJumpToFeature('gateway')}
                    className="text-amber-300 hover:underline font-medium"
                  >
                    Switch AI Provider
                  </button>
                </div>
              </div>

              {/* Preset Help Topics Carousel */}
              <div className="space-y-1.5">
                <span className="text-[10px] font-mono text-amber-300 uppercase font-semibold">
                  Popular First-Time User Inquiries
                </span>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
                  {APP_HELP_TOPICS.slice(0, 4).map((topic) => (
                    <button
                      key={topic.id}
                      onClick={() => handleSendQuery(topic.question)}
                      className="p-2.5 rounded-xl bg-[#07241d]/80 hover:bg-[#083027] border border-emerald-800/60 text-left transition-all text-[11px] text-emerald-200 hover:text-white flex items-start gap-2"
                    >
                      <HelpCircle className="w-3.5 h-3.5 text-amber-400 shrink-0 mt-0.5" />
                      <span className="line-clamp-2">{topic.question}</span>
                    </button>
                  ))}
                </div>
              </div>

              {/* Chat Dialogue History */}
              <div
                ref={chatScrollRef}
                className="space-y-3 p-3 rounded-2xl bg-[#040e0c] border border-emerald-900/80 max-h-[260px] overflow-y-auto"
              >
                {chatLog.map((msg) => {
                  const targetInfo = msg.targetFeature ? FEATURE_TAB_LABELS[msg.targetFeature] : undefined;
                  return (
                    <div
                      key={msg.id}
                      className={`flex flex-col ${
                        msg.sender === 'user' ? 'items-end' : 'items-start'
                      }`}
                    >
                      <div
                        className={`max-w-[88%] p-3 rounded-2xl text-xs leading-relaxed space-y-2 ${
                          msg.sender === 'user'
                            ? 'bg-emerald-800 text-white rounded-tr-none'
                            : 'bg-[#07251e] border border-emerald-800/60 text-emerald-100 rounded-tl-none shadow-md'
                        }`}
                      >
                        <p className="whitespace-pre-wrap">{msg.text}</p>

                        {msg.actionTip && (
                          <div className="pt-1.5 border-t border-emerald-700/40 text-[10px] text-amber-300">
                            💡 {msg.actionTip}
                          </div>
                        )}

                        {targetInfo && (
                          <button
                            onClick={() => handleJumpToFeature(targetInfo.tabId)}
                            className="inline-flex items-center gap-1.5 py-1 px-2.5 rounded-lg bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-300 text-[10px] font-semibold transition-colors"
                          >
                            <span>{targetInfo.label}</span>
                            <ArrowRight className="w-3 h-3" />
                          </button>
                        )}

                        {msg.suggestedFollowUps && msg.suggestedFollowUps.length > 0 && (
                          <div className="flex flex-wrap gap-1 pt-1">
                            {msg.suggestedFollowUps.map((q, idx) => (
                              <button
                                key={idx}
                                onClick={() => handleSendQuery(q)}
                                className="px-2 py-0.5 rounded-full bg-emerald-950/90 hover:bg-emerald-900 border border-emerald-700/50 text-[10px] text-emerald-200 transition-colors text-left"
                              >
                                {q}
                              </button>
                            ))}
                          </div>
                        )}

                        {msg.source && (
                          <div className="text-[9px] font-mono text-emerald-400/60 text-right">
                            {msg.source}
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
                {isAsking && (
                  <div className="flex items-center gap-2 text-xs text-amber-300/80 p-2">
                    <Sparkles className="w-4 h-4 animate-spin text-amber-400" />
                    <span>Al-Murshid is composing guidance...</span>
                  </div>
                )}
              </div>

              {/* Input Form */}
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={userQuery}
                  onChange={(e) => setUserQuery(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') handleSendQuery();
                  }}
                  placeholder="Ask any question about navigation, logging habits, or AI setup..."
                  className="flex-1 py-2.5 px-3.5 rounded-xl bg-[#051310] border border-emerald-800/60 text-xs text-white placeholder-emerald-500/50 focus:outline-none focus:border-amber-400"
                />
                <button
                  onClick={() => handleSendQuery()}
                  disabled={!userQuery.trim() || isAsking}
                  className="p-2.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-black font-bold disabled:opacity-40 transition-colors shadow-md"
                >
                  <Send className="w-4 h-4" />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

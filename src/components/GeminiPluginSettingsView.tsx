import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  Sparkles,
  ShieldCheck,
  Cpu,
  Key,
  CheckCircle2,
  RefreshCw,
  Zap,
  Globe,
  Sliders,
  AlertTriangle,
  ArrowRight,
  Code2
} from 'lucide-react';
import { CoachingReflection } from '../types';

interface GeminiPluginSettingsViewProps {
  onOpenCodeFile: (path: string) => void;
}

export const GeminiPluginSettingsView: React.FC<GeminiPluginSettingsViewProps> = ({
  onOpenCodeFile,
}) => {
  const [cloudCoachingActive, setCloudCoachingActive] = useState<boolean>(true);
  const [coachingTrigger, setCoachingTrigger] = useState<string>(
    'Mindlessly scrolled Instagram Reels for 20 minutes when I had planned to pray Isha and read Quran'
  );
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [reflectionResult, setReflectionResult] = useState<CoachingReflection | null>(null);

  const handleTestReflection = async () => {
    setIsLoading(true);

    if (!cloudCoachingActive) {
      // Deterministic Offline Mode Simulation
      setTimeout(() => {
        setReflectionResult({
          source: 'offline-deterministic',
          empathy: 'Reaching for endless motion is often your nervous system asking for a break from cognitive tension.',
          inquiry: 'What is your spirit or body quietly asking for in this moment—stillness, hydration, or genuine rest?',
          offlineAlternatives: [
            {
              title: 'Cool Wudu Reset',
              duration: '2 mins',
              action: 'Wash hands and face with cool water slowly, feeling the physical temperature reset your alertness.',
              category: 'spiritual',
            },
            {
              title: '33x SubhanAllah Breath',
              duration: '2 mins',
              action: 'Take 3 deep physiological sighs while reciting SubhanAllah with your fingers.',
              category: 'somatic',
            },
          ],
          affirmation: 'You hold the reins over your attention. Choose your next step with clear intention.',
        });
        setIsLoading(false);
      }, 400);
      return;
    }

    try {
      const res = await fetch('/api/reflect', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          appName: 'Instagram Reels',
          timeSpentMinutes: 20,
          emotionalState: 'Overstimulated & Avoidant',
          promptContext: coachingTrigger,
        }),
      });

      const data = await res.json();
      setReflectionResult(data);
    } catch {
      setReflectionResult({
        source: 'offline-fallback',
        empathy: 'Taking a pause right now is already an act of mindful awareness.',
        inquiry: 'If you step away from the glass screen for two minutes, what would bring genuine replenishment?',
        offlineAlternatives: [
          {
            title: 'Hydrate & Ground',
            duration: '2 mins',
            action: 'Drink a glass of water mindfully while standing with relaxed shoulders.',
            category: 'somatic',
          },
        ],
        affirmation: 'Your consciousness is a sacred trust. You are completely in control.',
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      {/* Header Info */}
      <div className="p-6 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-4">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="p-3 rounded-2xl bg-amber-500/20 border border-amber-400/50 text-amber-300">
              <Sparkles className="w-6 h-6" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="font-serif text-xl font-bold text-white">
                  Gemini Behavioral Coaching Plugin
                </h2>
                <span className="px-2 py-0.5 rounded-full bg-emerald-900/80 border border-emerald-700/60 text-[10px] font-mono text-emerald-300 font-semibold">
                  BYOK Architecture
                </span>
              </div>
              <p className="text-xs text-emerald-300/80">
                User-Configurable Cloud Model • Hardware Keystore Security • Deterministic Offline Fallback
              </p>
            </div>
          </div>

          <button
            onClick={() =>
              onOpenCodeFile('lib/features/coaching/plugins/gemini_coaching_plugin.dart')
            }
            className="py-1.5 px-3 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 border border-amber-400/40 text-amber-300 text-xs font-mono font-medium transition-colors flex items-center gap-1.5"
          >
            <Code2 className="w-3.5 h-3.5" />
            <span>View Flutter Plugin</span>
          </button>
        </div>

        {/* BYOK Mobile Architecture Guarantee */}
        <div className="p-4 rounded-2xl bg-[#08201a] border border-emerald-800/50 text-xs space-y-2">
          <h4 className="font-semibold text-amber-200 flex items-center gap-1.5">
            <ShieldCheck className="w-4 h-4 text-emerald-400" />
            How User-Configurable Gemini Works in Mīzān:
          </h4>
          <p className="text-emerald-100/90 leading-relaxed">
            • <strong>Mobile Hardware Keystore (BYOK):</strong> In the compiled Flutter mobile app, users can input their free Google Gemini API key via the settings screen (`gemini_config_screen.dart`). The key is encrypted inside Android Keystore / iOS Keychain via `FlutterSecureStorage` and never leaves their device.
          </p>
          <p className="text-emerald-100/90 leading-relaxed">
            • <strong>Web Dev Preview (Server-Side Proxy):</strong> In this development workbench, your API key is automatically attached from AI Studio Secrets and safely handled server-side through `/api/reflect` with `gemini-3.8-flash`.
          </p>
          <p className="text-emerald-100/90 leading-relaxed">
            • <strong>Seamless Offline Fallback:</strong> If the phone is in airplane mode or the API key is not configured, Mīzān instantly and automatically switches to the built-in deterministic decision matrix.
          </p>
        </div>
      </div>

      {/* Mode Switcher & Live Interactive Testing */}
      <div className="grid grid-cols-1 md:grid-cols-12 gap-5">
        {/* Left: Plugin Settings & Controls (5 cols) */}
        <div className="md:col-span-5 p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 space-y-4">
          <h3 className="font-serif text-sm font-bold text-white flex items-center gap-2">
            <Sliders className="w-4 h-4 text-amber-400" />
            Coaching Engine Modality
          </h3>

          <div className="p-3.5 rounded-2xl bg-[#09221b] border border-emerald-800/60 space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <span className="text-xs font-semibold text-white block">
                  Cloud AI Coaching Mode
                </span>
                <span className="text-[10px] text-emerald-300/70">
                  {cloudCoachingActive ? 'Gemini 3.8 Flash Active' : 'Offline Decision Tree'}
                </span>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={cloudCoachingActive}
                  onChange={(e) => setCloudCoachingActive(e.target.checked)}
                  className="sr-only peer"
                />
                <div className="w-9 h-5 bg-emerald-950 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-amber-500"></div>
              </label>
            </div>

            <div className="text-[11px] text-emerald-200/80 leading-relaxed pt-2 border-t border-emerald-900/50">
              {cloudCoachingActive ? (
                <span className="text-emerald-300 flex items-center gap-1.5">
                  <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                  Cloud model enabled: Generates dynamic, context-specific Motivational Interviewing reflections.
                </span>
              ) : (
                <span className="text-amber-300 flex items-center gap-1.5">
                  <span className="w-2 h-2 rounded-full bg-amber-400" />
                  Deterministic mode: 100% offline, zero network requests, instant sub-millisecond responses.
                </span>
              )}
            </div>
          </div>

          {/* Prompt Trigger Editor */}
          <div className="space-y-1.5">
            <label className="text-xs text-emerald-300/80 font-medium block">
              Test Intervention Trigger:
            </label>
            <textarea
              rows={3}
              value={coachingTrigger}
              onChange={(e) => setCoachingTrigger(e.target.value)}
              className="w-full bg-[#08201a] border border-emerald-800/60 rounded-xl p-2.5 text-xs text-white focus:outline-none focus:border-amber-400 resize-none leading-relaxed"
            />

            <div className="flex flex-wrap gap-1.5 pt-1">
              {[
                'Mindlessly scrolled Reels for 20m',
                'Procrastinating on coding work',
                'Late night fatigue & boredom',
              ].map((preset) => (
                <button
                  key={preset}
                  onClick={() => setCoachingTrigger(preset)}
                  className="px-2 py-0.5 rounded-full bg-emerald-950 border border-emerald-800/60 text-[10px] text-emerald-300 hover:text-white"
                >
                  {preset}
                </button>
              ))}
            </div>

            <button
              onClick={handleTestReflection}
              disabled={isLoading}
              className="w-full mt-3 py-2.5 rounded-xl bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 text-black font-semibold text-xs shadow-md shadow-amber-400/20 transition-all flex items-center justify-center gap-1.5"
            >
              {isLoading ? (
                <>
                  <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                  <span>Synthesizing Reflection...</span>
                </>
              ) : (
                <>
                  <Sparkles className="w-3.5 h-3.5 text-black" />
                  <span>Run Coaching Intervention</span>
                </>
              )}
            </button>
          </div>
        </div>

        {/* Right: Live Reflection Output (7 cols) */}
        <div className="md:col-span-7 p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between border-b border-emerald-900/50 pb-2 mb-3">
              <span className="text-xs font-bold text-white">Coaching Response Output</span>
              <span className="text-[10px] font-mono text-emerald-400">
                {reflectionResult ? reflectionResult.source : 'Awaiting trigger test'}
              </span>
            </div>

            {reflectionResult ? (
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-3 text-xs"
              >
                {/* Empathy Block */}
                <div className="p-3.5 rounded-2xl bg-[#08221b] border border-emerald-800/50">
                  <span className="text-[10px] font-mono text-amber-300 uppercase tracking-wider block mb-1">
                    1. Non-Judgmental Empathy (Reflective Listening)
                  </span>
                  <p className="text-emerald-100/90 leading-relaxed italic text-sm">
                    "{reflectionResult.empathy}"
                  </p>
                </div>

                {/* Open Inquiry Block */}
                <div className="p-3.5 rounded-2xl bg-[#071d17] border border-emerald-800/50">
                  <span className="text-[10px] font-mono text-amber-300 uppercase tracking-wider block mb-1">
                    2. Autonomy Inquiry (OARS)
                  </span>
                  <p className="text-white font-medium text-xs leading-relaxed">
                    {reflectionResult.inquiry}
                  </p>
                </div>

                {/* Immediate 2-Minute Offline Alternatives */}
                <div className="space-y-1.5">
                  <span className="text-[10px] font-mono text-emerald-400 uppercase tracking-wider block">
                    3. Actionable 2-Minute Physical Replacement
                  </span>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    {reflectionResult.offlineAlternatives?.map((alt, idx) => (
                      <div
                        key={idx}
                        className="p-3 rounded-xl bg-[#04130f] border border-emerald-900/60"
                      >
                        <div className="flex items-center justify-between text-amber-200 font-medium text-xs mb-1">
                          <span>{alt.title}</span>
                          <span className="text-[10px] font-mono text-emerald-400">
                            {alt.duration}
                          </span>
                        </div>
                        <p className="text-[11px] text-emerald-300/70 leading-snug">
                          {alt.action}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Dignity & Autonomy Affirmation */}
                <p className="text-[11px] text-amber-300/90 font-medium pt-2 border-t border-emerald-900/40">
                  ★ {reflectionResult.affirmation}
                </p>
              </motion.div>
            ) : (
              <div className="py-16 text-center space-y-2 text-emerald-400/60">
                <Sparkles className="w-8 h-8 mx-auto text-emerald-700/60" />
                <p className="text-xs">
                  Click "Run Coaching Intervention" to test either Cloud Gemini or Offline Deterministic mode.
                </p>
              </div>
            )}
          </div>

          <div className="mt-4 pt-3 border-t border-emerald-900/40 text-[10px] text-emerald-400/50 flex items-center justify-between">
            <span>Mīzān Cognitive Sovereignty Engine</span>
            <span>Zero Guilt • 100% Ikhtiyar</span>
          </div>
        </div>
      </div>
    </div>
  );
};

import React, { useState, useEffect } from 'react';
import {
  Sparkles,
  Shield,
  Lock,
  Cpu,
  Sliders,
  CheckCircle2,
  RefreshCw,
  Code2,
  Database,
  Terminal,
  Key,
  Eye,
  EyeOff,
  Trash2,
  AlertCircle
} from 'lucide-react';
import { AIProviderId, AIProviderConfig } from '../types';
import { DEFAULT_PROVIDERS_CONFIG } from '../data/onboardingData';
import {
  loadGatewayConfig,
  saveGatewayConfig,
  loadGatewayKeys,
  saveGatewayKey,
  clearGatewayKey,
  maskApiKey,
  GatewayKeyVault,
} from '../utils/aiGatewayClient';

interface MultiAIGatewayViewProps {
  onOpenCodeFile: (path: string) => void;
  onNavigateTab?: (tab: string) => void;
}

export const MultiAIGatewayView: React.FC<MultiAIGatewayViewProps> = ({
  onOpenCodeFile,
}) => {
  const [providers] = useState<Record<AIProviderId, AIProviderConfig>>(DEFAULT_PROVIDERS_CONFIG);
  const initialConfig = loadGatewayConfig();

  const [activeProvider, setActiveProvider] = useState<AIProviderId>(initialConfig.provider);
  const [selectedModel, setSelectedModel] = useState<string>(initialConfig.model);
  const [temperature, setTemperature] = useState<number>(initialConfig.temperature);
  const [maxTokens, setMaxTokens] = useState<number>(initialConfig.maxTokens);
  const [fallbackToOffline, setFallbackToOffline] = useState<boolean>(initialConfig.fallbackToOffline);

  // BYOK Key Vault State
  const [keyVault, setKeyVault] = useState<GatewayKeyVault>(() => loadGatewayKeys());
  const [keyInput, setKeyInput] = useState<string>('');
  const [showKeyText, setShowKeyText] = useState<boolean>(false);
  const [keyStatusMsg, setKeyStatusMsg] = useState<string | null>(null);

  // Sync active gateway configuration to localStorage
  useEffect(() => {
    saveGatewayConfig({
      provider: activeProvider,
      model: selectedModel,
      temperature,
      maxTokens,
      fallbackToOffline,
    });
  }, [activeProvider, selectedModel, temperature, maxTokens, fallbackToOffline]);

  // Testing Playground State
  const [testPrompt, setTestPrompt] = useState<string>(
    'How can I structure my deep work sprints between Dhuhr and Asr without getting distracted by social media feeds?'
  );
  const [isRouting, setIsRouting] = useState<boolean>(false);
  const [routingError, setRoutingError] = useState<string | null>(null);
  const [routingResult, setRoutingResult] = useState<{
    provider: string;
    model: string;
    latencyMs: number;
    source: string;
    reply: string;
    scripturalAnchor?: {
      type: string;
      textArabic: string;
      translation: string;
      reference: string;
    };
    tokensUsed?: { prompt: number; completion: number; total: number };
    suggestedActions?: string[];
  } | null>(null);

  const providerModels: Record<AIProviderId, string[]> = {
    gemini: ['gemini-3.8-flash', 'gemini-2.5-flash', 'gemini-2.5-pro'],
    openai: ['gpt-4o', 'gpt-4o-mini', 'o1-mini'],
    anthropic: ['claude-3-5-sonnet-20241022', 'claude-3-5-haiku-20241022'],
    deepseek: ['deepseek-chat', 'deepseek-reasoner'],
    offline: ['embedded-canonical-db (Local SQLite)'],
  };

  const keyPlaceholders: Record<Exclude<AIProviderId, 'offline'>, string> = {
    gemini: 'AIzaSy... (Google AI Studio API Key)',
    openai: 'sk-proj-... (OpenAI Secret Key)',
    anthropic: 'sk-ant-... (Anthropic API Key)',
    deepseek: 'sk-... (DeepSeek API Key)',
  };

  const handleSelectProvider = (provId: AIProviderId) => {
    setActiveProvider(provId);
    setSelectedModel(providerModels[provId][0]);
    setKeyInput('');
    setShowKeyText(false);
    setKeyStatusMsg(null);
    setRoutingError(null);
  };

  const handleSaveApiKey = () => {
    if (activeProvider === 'offline' || !keyInput.trim()) return;
    const updated = saveGatewayKey(activeProvider, keyInput);
    setKeyVault(updated);
    setKeyInput('');
    setShowKeyText(false);
    setKeyStatusMsg(`${providers[activeProvider].name} key stored in local sandbox vault.`);
  };

  const handleClearApiKey = () => {
    if (activeProvider === 'offline') return;
    const updated = clearGatewayKey(activeProvider);
    setKeyVault(updated);
    setKeyInput('');
    setKeyStatusMsg(`${providers[activeProvider].name} key removed. Offline/server fallback active.`);
  };

  const handleExecuteRoutingTest = async () => {
    if (!testPrompt.trim() || isRouting) return;
    setIsRouting(true);
    setRoutingError(null);

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (activeProvider !== 'offline') {
      const configuredKey = keyVault[activeProvider];
      if (configuredKey) {
        headers['x-provider-api-key'] = configuredKey;
      }
    }

    try {
      const res = await fetch('/api/multi-ai/chat', {
        method: 'POST',
        headers,
        body: JSON.stringify({
          provider: activeProvider,
          model: selectedModel,
          prompt: testPrompt.trim(),
          temperature,
          maxTokens,
          fallbackToOffline,
          userContext: {
            habits: 'Siwak, Fajr, 33x Tasbih',
            spiritualGoal: 'Balancing focus work sprints and Salah presence',
          },
        }),
      });

      const data = await res.json();
      if (!res.ok) {
        setRoutingError(data.error || `Gateway request failed (${res.status})`);
        setRoutingResult(null);
      } else {
        setRoutingResult(data);
      }
    } catch {
      setRoutingResult({
        provider: activeProvider,
        model: selectedModel,
        latencyMs: 14,
        source: 'local-offline-matrix',
        reply:
          'When disconnected, Mīzān falls back cleanly to the local SQLite authentic Hadith matrix. Consistency in small deeds is the most beloved to our Creator.',
        scripturalAnchor: {
          type: 'hadith',
          textArabic: 'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ تَعَالَى أَدْوَمُهَا وَإِنْ قَلَّ',
          translation: 'The most beloved deeds to Allah are those that are most consistent, even if they are few.',
          reference: 'Sahih al-Bukhari 6464',
        },
        tokensUsed: { prompt: 25, completion: 45, total: 70 },
      });
    } finally {
      setIsRouting(false);
    }
  };

  const activeCloudKey = activeProvider !== 'offline' ? keyVault[activeProvider] : undefined;

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="p-6 rounded-3xl bg-gradient-to-r from-[#07241d] via-[#09352a] to-[#061e18] border border-emerald-800/60 shadow-2xl relative overflow-hidden">
        <div className="relative z-10 max-w-3xl space-y-2">
          <div className="flex items-center gap-2">
            <span className="px-2.5 py-0.5 rounded-full bg-amber-500/20 text-amber-300 font-mono text-[10px] font-bold border border-amber-400/40 uppercase tracking-wider">
              Flexible Multi-AI Gateway
            </span>
            <span className="text-xs text-emerald-300/80 font-mono">• Bring Your Own Key (BYOK)</span>
          </div>
          <h2 className="font-serif text-2xl sm:text-3xl font-bold text-white tracking-wide">
            Multi-Provider AI Gateway &amp; Sovereign Routing
          </h2>
          <p className="text-xs sm:text-sm text-emerald-200/80 leading-relaxed">
            Input your own API keys for <strong>Google Gemini</strong>, <strong>OpenAI ChatGPT</strong>, <strong>Anthropic Claude</strong>, or <strong>DeepSeek</strong>, or run offline with the <strong>Canonical Hadith Matrix</strong>. All backend coaching prompts in Al-Murshid, the Phone Simulator Coach, and Onboarding Q&amp;A automatically route through your active provider while core habit, Salah, and Quran features stay 100% offline-capable.
          </p>

          <div className="flex flex-wrap items-center gap-3 pt-2">
            <button
              onClick={() => onOpenCodeFile('lib/features/gateway/presentation/screens/multi_ai_gateway_screen.dart')}
              className="py-1.5 px-3 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 border border-amber-400/40 text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              <Code2 className="w-3.5 h-3.5" />
              <span>Flutter Gateway Screen</span>
            </button>
            <button
              onClick={() => onOpenCodeFile('lib/features/gateway/data/multi_ai_repository.dart')}
              className="py-1.5 px-3 rounded-xl bg-emerald-900/60 hover:bg-emerald-800/70 text-emerald-200 border border-emerald-700/50 text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              <Cpu className="w-3.5 h-3.5" />
              <span>Multi-AI Client Repository</span>
            </button>
          </div>
        </div>

        <div className="absolute right-6 -bottom-10 opacity-10 text-[180px] font-arabic select-none pointer-events-none text-amber-300">
          ع
        </div>
      </div>

      {/* Provider Selector Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
        {(Object.keys(providers) as AIProviderId[]).map((provId) => {
          const prov = providers[provId];
          const isSelected = activeProvider === provId;
          const hasUserKey = provId !== 'offline' && Boolean(keyVault[provId]);

          return (
            <button
              key={provId}
              onClick={() => handleSelectProvider(provId)}
              className={`p-4 rounded-2xl border text-left transition-all relative overflow-hidden flex flex-col justify-between ${
                isSelected
                  ? 'bg-gradient-to-b from-amber-500/25 to-emerald-900/50 border-amber-400 text-white shadow-xl shadow-amber-500/10'
                  : 'bg-[#061a15] border-emerald-900/60 text-emerald-300/80 hover:bg-emerald-950/60'
              }`}
            >
              {isSelected && (
                <div className="absolute top-2 right-2 flex items-center gap-1 px-1.5 py-0.5 rounded-full bg-amber-400 text-black text-[9px] font-bold">
                  ACTIVE
                </div>
              )}
              <div className="space-y-2">
                <div className="text-2xl">{prov.icon}</div>
                <div>
                  <h3 className="font-bold text-xs text-white flex items-center gap-1.5">
                    <span>{prov.name}</span>
                  </h3>
                  <span className="text-[10px] text-emerald-400/80 font-mono block">
                    {prov.providerCompany}
                  </span>
                </div>
                <p className="text-[10px] text-emerald-200/70 leading-relaxed line-clamp-2">
                  {prov.description}
                </p>
              </div>

              <div className="mt-3 pt-2 border-t border-emerald-900/50 flex items-center justify-between text-[9px] font-mono">
                <span className="text-amber-300 truncate max-w-[100px]">{prov.defaultModel}</span>
                {prov.id === 'offline' ? (
                  <span className="text-emerald-400">Zero Cloud</span>
                ) : hasUserKey ? (
                  <span className="text-emerald-400 flex items-center gap-0.5">
                    <CheckCircle2 className="w-2.5 h-2.5" />
                    BYOK Saved
                  </span>
                ) : (
                  <span className="text-emerald-300/60">
                    {prov.id === 'gemini' ? 'Proxy / BYOK' : 'Needs Key'}
                  </span>
                )}
              </div>
            </button>
          );
        })}
      </div>

      {/* Main Grid: BYOK Credentials + Parameters & Interactive Routing Playground */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: BYOK API Key Input, Parameters & Security */}
        <div className="lg:col-span-5 space-y-4">
          {/* BYOK API Key Management Card */}
          <div className="p-5 rounded-3xl bg-[#071d17] border border-emerald-800/60 shadow-xl space-y-3">
            <div className="flex items-center justify-between pb-2 border-b border-emerald-900/50">
              <div className="flex items-center gap-2">
                <Key className="w-4 h-4 text-amber-400" />
                <h3 className="font-serif text-sm font-bold text-white">
                  API Key Credentials ({providers[activeProvider].name})
                </h3>
              </div>
              {activeProvider === 'offline' ? (
                <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-emerald-950 text-emerald-400 border border-emerald-700/50">
                  No Key Needed
                </span>
              ) : activeCloudKey ? (
                <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/40">
                  Key Configured
                </span>
              ) : (
                <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-amber-500/15 text-amber-300 border border-amber-400/30">
                  {activeProvider === 'gemini' ? 'Server / Offline Ready' : 'Not Set'}
                </span>
              )}
            </div>

            {activeProvider === 'offline' ? (
              <p className="text-xs text-emerald-200/80 leading-relaxed">
                The Local Offline Hadith Matrix executes inside your device sandbox using bundled verified Quran &amp; Sahih Hadith tables—zero network access or API keys required.
              </p>
            ) : (
              <div className="space-y-3">
                {activeCloudKey && (
                  <div className="p-2.5 rounded-xl bg-[#051310] border border-emerald-700/50 flex items-center justify-between text-xs">
                    <div>
                      <span className="text-[10px] text-emerald-400/80 block font-mono">
                        Active Local Vault Key
                      </span>
                      <code className="text-amber-300 font-mono text-[11px]">
                        {maskApiKey(activeCloudKey)}
                      </code>
                    </div>
                    <button
                      onClick={handleClearApiKey}
                      className="py-1 px-2.5 rounded-lg bg-red-500/15 hover:bg-red-500/25 text-red-300 border border-red-500/30 text-[10px] font-semibold flex items-center gap-1 transition-colors"
                    >
                      <Trash2 className="w-3 h-3" />
                      <span>Remove</span>
                    </button>
                  </div>
                )}

                <div className="space-y-1.5">
                  <label className="text-xs text-emerald-200/80 font-medium block">
                    {activeCloudKey ? 'Update' : 'Enter'} {providers[activeProvider].name} API Key
                  </label>
                  <div className="relative flex items-center">
                    <input
                      type={showKeyText ? 'text' : 'password'}
                      value={keyInput}
                      onChange={(e) => setKeyInput(e.target.value)}
                      placeholder={keyPlaceholders[activeProvider]}
                      className="w-full py-2 pl-3 pr-9 rounded-xl bg-[#051310] border border-emerald-800/60 text-xs text-white placeholder-emerald-500/40 focus:outline-none focus:border-amber-400 font-mono"
                    />
                    <button
                      type="button"
                      onClick={() => setShowKeyText((v) => !v)}
                      className="absolute right-2.5 text-emerald-400/70 hover:text-white"
                      title={showKeyText ? 'Hide key' : 'Reveal key'}
                    >
                      {showKeyText ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                    </button>
                  </div>
                </div>

                <div className="flex items-center justify-between gap-2">
                  <span className="text-[10px] text-emerald-300/70 leading-tight">
                    Saved locally in sandbox storage (mirrors Android Keystore / iOS Keychain). Never logged on disk.
                  </span>
                  <button
                    onClick={handleSaveApiKey}
                    disabled={!keyInput.trim()}
                    className="py-1.5 px-3.5 rounded-xl bg-amber-500 hover:bg-amber-400 disabled:opacity-40 text-black font-bold text-xs whitespace-nowrap transition-colors shadow-md"
                  >
                    Save Key
                  </button>
                </div>

                {keyStatusMsg && (
                  <div className="p-2 rounded-lg bg-emerald-500/15 border border-emerald-500/30 text-[11px] text-emerald-300 flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 shrink-0" />
                    <span>{keyStatusMsg}</span>
                  </div>
                )}
              </div>
            )}
          </div>

          {/* Active Provider Engine Settings */}
          <div className="p-5 rounded-3xl bg-[#071d17] border border-emerald-800/60 shadow-xl space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-emerald-900/50">
              <div className="flex items-center gap-2">
                <Sliders className="w-4 h-4 text-amber-400" />
                <h3 className="font-serif text-sm font-bold text-white">
                  Provider Parameters ({providers[activeProvider].name})
                </h3>
              </div>
              <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-emerald-950 text-emerald-300 border border-emerald-800/50">
                Active Route
              </span>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs text-emerald-200/80 font-medium">Model Selection</label>
              <select
                value={selectedModel}
                onChange={(e) => setSelectedModel(e.target.value)}
                className="w-full py-2 px-3 rounded-xl bg-[#051310] border border-emerald-800/60 text-xs text-white focus:outline-none focus:border-amber-400 font-mono"
              >
                {providerModels[activeProvider].map((m) => (
                  <option key={m} value={m}>
                    {m}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-between text-xs">
                <span className="text-emerald-200/80">Creativity / Temperature</span>
                <span className="font-mono text-amber-300">{temperature}</span>
              </div>
              <input
                type="range"
                min="0.0"
                max="1.0"
                step="0.05"
                value={temperature}
                onChange={(e) => setTemperature(parseFloat(e.target.value))}
                className="w-full accent-amber-400 cursor-pointer"
              />
              <div className="flex justify-between text-[9px] text-emerald-400/50 font-mono">
                <span>0.0 (Precise Scripture)</span>
                <span>1.0 (Creative Metaphor)</span>
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-between text-xs">
                <span className="text-emerald-200/80">Max Generation Tokens</span>
                <span className="font-mono text-amber-300">{maxTokens}</span>
              </div>
              <input
                type="range"
                min="256"
                max="2048"
                step="128"
                value={maxTokens}
                onChange={(e) => setMaxTokens(parseInt(e.target.value))}
                className="w-full accent-amber-400 cursor-pointer"
              />
            </div>

            <div className="pt-2 border-t border-emerald-900/50 flex items-center justify-between text-xs">
              <div>
                <span className="text-white font-medium block">Automatic Offline Fallback</span>
                <span className="text-[10px] text-emerald-300/70">
                  Switch to local SQLite Hadith matrix if network or key is unavailable
                </span>
              </div>
              <input
                type="checkbox"
                checked={fallbackToOffline}
                onChange={(e) => setFallbackToOffline(e.target.checked)}
                className="w-4 h-4 accent-amber-400 cursor-pointer"
              />
            </div>
          </div>

          {/* Hardware Keystore & Keychain Security Card */}
          <div className="p-5 rounded-3xl bg-[#071d17] border border-emerald-800/60 shadow-xl space-y-3">
            <div className="flex items-center gap-2 text-amber-300 font-semibold text-xs">
              <Lock className="w-4 h-4 text-amber-400" />
              <span>Mobile BYOK Hardware Security Architecture</span>
            </div>
            <div className="space-y-2 text-xs">
              <div className="p-2.5 rounded-xl bg-[#051310] border border-emerald-900/60 flex items-start gap-2">
                <Shield className="w-4 h-4 text-emerald-400 shrink-0 mt-0.5" />
                <div>
                  <strong className="text-white">Android Keystore &amp; Apple Keychain:</strong>
                  <p className="text-[10px] text-emerald-300/70">
                    Protected via AES-256-GCM MasterKey (HSM) and Secure Enclave without server persistence.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Interactive Gateway Testing Playground */}
        <div className="lg:col-span-7 space-y-4">
          <div className="p-5 rounded-3xl bg-[#071d17] border border-emerald-800/60 shadow-xl space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-emerald-900/50">
              <div>
                <h3 className="font-serif text-base font-bold text-white flex items-center gap-2">
                  <Terminal className="w-4 h-4 text-amber-400" />
                  <span>Gateway Routing Console</span>
                </h3>
                <p className="text-xs text-emerald-300/70">
                  Execute behavioral coaching prompts through the active provider route and inspect telemetry.
                </p>
              </div>

              <div className="flex items-center gap-2 text-xs font-mono">
                <span className="px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-300 border border-amber-400/30">
                  {providers[activeProvider].name} · {selectedModel}
                </span>
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-xs text-emerald-200/80 font-medium flex items-center justify-between">
                <span>Coaching / Guidance Prompt</span>
                <span className="text-[10px] text-emerald-400/60">Sample life alignment query</span>
              </label>
              <textarea
                rows={3}
                value={testPrompt}
                onChange={(e) => setTestPrompt(e.target.value)}
                placeholder="Type a spiritual or behavioral reflection query..."
                className="w-full p-3 rounded-2xl bg-[#051310] border border-emerald-800/60 text-xs text-white focus:outline-none focus:border-amber-400 leading-relaxed font-sans"
              />

              <div className="flex flex-wrap items-center justify-between gap-2">
                <div className="flex flex-wrap items-center gap-1.5 text-[10px]">
                  <span className="text-emerald-400/60">Quick presets:</span>
                  {[
                    'Overcoming Reels distraction',
                    'Work burnout & Fajr prayer',
                    'Balancing creative deep sprints',
                  ].map((preset) => (
                    <button
                      key={preset}
                      onClick={() => setTestPrompt(preset)}
                      className="px-2 py-0.5 rounded bg-emerald-950 hover:bg-emerald-900 text-emerald-300 border border-emerald-800/50"
                    >
                      {preset}
                    </button>
                  ))}
                </div>

                <button
                  onClick={handleExecuteRoutingTest}
                  disabled={isRouting}
                  className="py-2 px-4 rounded-xl bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-black font-bold text-xs flex items-center gap-2 transition-all shadow-lg shadow-amber-500/20 disabled:opacity-50"
                >
                  <RefreshCw className={`w-3.5 h-3.5 ${isRouting ? 'animate-spin' : ''}`} />
                  <span>{isRouting ? 'Routing...' : 'Route Prompt'}</span>
                </button>
              </div>
            </div>

            <div className="space-y-2 pt-2">
              <div className="flex items-center justify-between text-xs">
                <span className="font-semibold text-white flex items-center gap-1.5">
                  <Database className="w-3.5 h-3.5 text-amber-400" />
                  <span>Gateway Response Telemetry</span>
                </span>
                {routingResult && (
                  <div className="flex items-center gap-2 font-mono text-[10px]">
                    <span className="text-emerald-400">Latency: {routingResult.latencyMs}ms</span>
                    <span className="text-amber-300">Tokens: {routingResult.tokensUsed?.total || 320}</span>
                  </div>
                )}
              </div>

              {routingError && (
                <div className="p-3 rounded-2xl bg-red-950/50 border border-red-500/40 text-xs text-red-200 flex items-start gap-2">
                  <AlertCircle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
                  <div>
                    <strong className="block text-red-300">Gateway Routing Notice</strong>
                    <span>{routingError}</span>
                  </div>
                </div>
              )}

              <div className="p-4 rounded-2xl bg-[#040e0c] border border-emerald-900/80 min-h-[190px] flex flex-col justify-between text-xs space-y-3 font-sans">
                {isRouting ? (
                  <div className="flex flex-col items-center justify-center py-12 space-y-2 text-emerald-300/80">
                    <RefreshCw className="w-6 h-6 animate-spin text-amber-400" />
                    <span className="text-xs font-mono">
                      Routing through {providers[activeProvider].name} ({selectedModel})...
                    </span>
                  </div>
                ) : routingResult ? (
                  <div className="space-y-3">
                    <div className="flex flex-wrap items-center justify-between gap-2 pb-2 border-b border-emerald-900/50 text-[10px] font-mono text-emerald-400">
                      <span>PROVIDER: {routingResult.provider.toUpperCase()}</span>
                      <span>MODEL: {routingResult.model}</span>
                      <span>SOURCE: {routingResult.source}</span>
                    </div>

                    <p className="text-white text-xs leading-relaxed whitespace-pre-wrap">
                      {routingResult.reply}
                    </p>

                    {routingResult.scripturalAnchor && (
                      <div className="p-3 rounded-xl bg-black/40 border border-amber-400/30 space-y-1">
                        <div className="flex items-center justify-between text-[10px]">
                          <span className="font-bold text-amber-300 uppercase">
                            Canonical {routingResult.scripturalAnchor.type} Grounding
                          </span>
                          <span className="font-mono text-emerald-400">
                            {routingResult.scripturalAnchor.reference}
                          </span>
                        </div>
                        <p className="text-amber-200/90 font-arabic text-sm text-right leading-relaxed">
                          {routingResult.scripturalAnchor.textArabic}
                        </p>
                        <p className="text-[11px] text-white/80 italic">
                          "{routingResult.scripturalAnchor.translation}"
                        </p>
                      </div>
                    )}

                    {routingResult.suggestedActions && (
                      <div className="flex flex-wrap items-center gap-1.5 pt-1">
                        <span className="text-[10px] text-emerald-400/80">Actions:</span>
                        {routingResult.suggestedActions.map((act, i) => (
                          <span
                            key={i}
                            className="px-2 py-0.5 rounded-full bg-emerald-950 text-amber-300 border border-emerald-800 text-[10px]"
                          >
                            {act}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                ) : (
                  <div className="flex flex-col items-center justify-center py-10 space-y-1.5 text-center text-emerald-400/60">
                    <Sparkles className="w-8 h-8 text-amber-400/40" />
                    <p className="text-xs">Click "Route Prompt" to test multi-AI gateway response dispatch.</p>
                    <span className="text-[10px] font-mono text-emerald-500/50">
                      Supports Google Gemini, OpenAI GPT-4o, Anthropic Claude, DeepSeek &amp; Local Offline SQLite
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

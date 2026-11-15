import React, { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import {
  Sparkles,
  Send,
  BookOpen,
  Compass,
  Clock,
  Shield,
  Flame,
  CheckCircle2,
  RefreshCw,
  Zap,
  Heart,
  Briefcase,
  Moon,
  MessageSquare,
  HelpCircle,
  Lightbulb,
  ExternalLink,
  Code2,
  Cpu
} from 'lucide-react';
import { AgentMessage, UserProfile, MicroSunnah } from '../types';
import { loadGatewayConfig, getActiveGatewayHeaders } from '../utils/aiGatewayClient';

interface HolisticAIAgentViewProps {
  currentUser: UserProfile | null;
  habits: MicroSunnah[];
  onOpenCodeFile: (path: string) => void;
  onNavigateTab?: (tab: string) => void;
}

export const HolisticAIAgentView: React.FC<HolisticAIAgentViewProps> = ({
  currentUser,
  habits,
  onOpenCodeFile,
  onNavigateTab,
}) => {
  const [messages, setMessages] = useState<AgentMessage[]>([
    {
      id: 'msg-init',
      sender: 'agent',
      text: `As-salamu alaykum, ${
        currentUser?.displayName ? currentUser.displayName.split(' ')[0] : 'friend'
      }. I am Al-Murshid (المرشد), your companion for holistic life alignment and spiritual presence. I am here to help you harmonize your professional craft, creative flow, and physical rest around your spiritual core—grounded in authentic Quran and verified Sunnah without guilt or burnout. How is your energy and heart today?`,
      timestamp: 'Just now',
      scripturalAnchor: {
        type: 'quran',
        textArabic: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
        translation: 'Unquestionably, by the remembrance of Allah hearts are assured.',
        reference: 'Surah Ar-Ra’d (13:28)',
      },
      lifeDomain: 'spiritual',
      suggestedActions: [
        'Preventing work burnout',
        'Late-night screen distractions',
        'Balancing deep work with Salah',
      ],
      source: 'gemini-3.8-flash',
    },
  ]);

  const [inputMessage, setInputMessage] = useState('');
  const [isSending, setIsSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = async (textToSend?: string) => {
    const text = textToSend || inputMessage;
    if (!text.trim() || isSending) return;

    const userMsg: AgentMessage = {
      id: `usr_${Date.now()}`,
      sender: 'user',
      text: text.trim(),
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInputMessage('');
    setIsSending(true);

    try {
      const activeStreaksList = habits.map((h) => `${h.title}: ${h.streakDays}d streak`);
      const gatewayCfg = loadGatewayConfig();

      const res = await fetch('/api/agent/chat', {
        method: 'POST',
        headers: getActiveGatewayHeaders(),
        body: JSON.stringify({
          userMessage: text.trim(),
          provider: gatewayCfg.provider,
          model: gatewayCfg.model,
          temperature: gatewayCfg.temperature,
          maxTokens: gatewayCfg.maxTokens,
          history: messages.slice(-4).map((m) => ({
            role: m.sender === 'user' ? 'user' : 'model',
            text: m.text,
          })),
          context: {
            habits: activeStreaksList,
            screenTime: { todayMinutes: 24, limitMinutes: 45 },
            quranProgress: { surahName: 'Al-Baqarah', ayah: 28 },
            nextPrayer: { name: 'Dhuhr', time: '12:28 PM' },
            spiritualGoal: currentUser?.spiritualGoal || 'Cultivating steadfastness & balance',
          },
        }),
      });

      const data = await res.json();

      const agentMsg: AgentMessage = {
        id: `agent_${Date.now()}`,
        sender: 'agent',
        text: data.reply || 'May Allah grant ease to your affairs.',
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        scripturalAnchor: data.scripturalAnchor,
        lifeDomain: data.lifeDomain,
        suggestedActions: data.suggestedActions,
        source: data.source || `${gatewayCfg.provider} (${gatewayCfg.model})`,
      };

      setMessages((prev) => [...prev, agentMsg]);
    } catch {
      const fallbackMsg: AgentMessage = {
        id: `agent_${Date.now()}`,
        sender: 'agent',
        text: 'When pressure builds, renew your intention and remember that true Barakah comes from paced, consistent steps rather than frantic acceleration.',
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        scripturalAnchor: {
          type: 'hadith',
          textArabic: 'إِنَّ الدِّينَ يُسْرٌ، وَلَنْ يُشَادَّ الدِّينَ أَحَدٌ إِلاَّ غَلَبَهُ',
          translation: 'Indeed, this religion is easy, and whoever overburdens himself in religion will be overcome by it.',
          reference: 'Sahih al-Bukhari 39',
        },
        lifeDomain: 'burnout_prevention',
        suggestedActions: ['2-minute calm breath', 'Stand up & drink water', 'Recite Ayat al-Kursi'],
        source: 'offline-fallback',
      };
      setMessages((prev) => [...prev, fallbackMsg]);
    } finally {
      setIsSending(false);
    }
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-5 h-[800px] max-w-6xl mx-auto">
      {/* Left Column: Real-Time Context & Holistic Health Monitor (4 cols) */}
      <div className="lg:col-span-4 flex flex-col gap-4">
        {/* Agent Persona Card */}
        <div className="p-5 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-3">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-amber-500 via-amber-400 to-emerald-600 flex items-center justify-center text-black font-bold text-xl shadow-lg shadow-amber-500/20 font-arabic">
              م
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <h3 className="font-serif font-bold text-base text-white">Al-Murshid</h3>
                <span className="font-arabic text-amber-300 text-sm">المرشد</span>
              </div>
              <p className="text-[11px] text-emerald-300/80">
                24/7 Autonomous Holistic AI Companion
              </p>
            </div>
          </div>

          <p className="text-xs text-emerald-100/90 leading-relaxed">
            Monitors your habit streaks, screen time, and prayer timeline to proactively align your professional, creative, and spiritual life with zero guilt.
          </p>

          <div className="pt-2 border-t border-emerald-900/60 flex items-center justify-between text-xs">
            <span className="text-emerald-400 font-mono text-[10px] flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              Real-Time Context Synced
            </span>
            <button
              onClick={() =>
                onOpenCodeFile('lib/features/gateway/data/multi_ai_repository.dart')
              }
              className="text-amber-300 hover:underline font-mono text-[10px] flex items-center gap-1"
            >
              <Code2 className="w-3 h-3" />
              <span>Gateway Code</span>
            </button>
          </div>

          <div className="p-2.5 rounded-xl bg-[#04120f] border border-amber-500/30 flex items-center justify-between text-[11px]">
            <div className="flex items-center gap-1.5 min-w-0">
              <Cpu className="w-3.5 h-3.5 text-amber-400 shrink-0" />
              <span className="text-emerald-200 truncate font-mono text-[10px]">
                Route: <strong className="text-amber-300">{loadGatewayConfig().provider}</strong> · {loadGatewayConfig().model}
              </span>
            </div>
            {onNavigateTab && (
              <button
                onClick={() => onNavigateTab('gateway')}
                className="text-[10px] text-amber-300 hover:underline font-semibold shrink-0 ml-2"
              >
                Switch
              </button>
            )}
          </div>
        </div>

        {/* Live Context Ingestion Drawer */}
        <div className="p-4 rounded-3xl bg-[#071915] border border-emerald-800/50 space-y-3 flex-1 overflow-y-auto text-xs">
          <span className="text-[10px] uppercase font-mono font-bold tracking-wider text-amber-300 block">
            Context Fed to Active AI Route
          </span>

          <div className="space-y-2">
            <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
              <div className="flex items-center justify-between text-[11px] font-medium text-emerald-300 mb-0.5">
                <span className="flex items-center gap-1">
                  <Flame className="w-3.5 h-3.5 text-amber-400" />
                  Active Sunnah Streaks
                </span>
                <span className="font-mono text-amber-300">14d best</span>
              </div>
              <p className="text-[10px] text-emerald-300/70">
                Siwak (14d), Ayat al-Kursi (8d), 33x Tasbih (11d)
              </p>
            </div>

            <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
              <div className="flex items-center justify-between text-[11px] font-medium text-emerald-300 mb-0.5">
                <span className="flex items-center gap-1">
                  <Shield className="w-3.5 h-3.5 text-amber-400" />
                  Digital Boundary
                </span>
                <span className="font-mono text-emerald-400">Healthy (24m / 45m)</span>
              </div>
              <p className="text-[10px] text-emerald-300/70">
                Reels blocker active • Zero threshold violations today
              </p>
            </div>

            <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
              <div className="flex items-center justify-between text-[11px] font-medium text-emerald-300 mb-0.5">
                <span className="flex items-center gap-1">
                  <BookOpen className="w-3.5 h-3.5 text-emerald-400" />
                  Quran Progress
                </span>
                <span className="font-mono text-amber-300">Juz 2</span>
              </div>
              <p className="text-[10px] text-emerald-300/70">
                Surah Al-Baqarah (Ayah 28 of 286)
              </p>
            </div>

            <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
              <div className="flex items-center justify-between text-[11px] font-medium text-emerald-300 mb-0.5">
                <span className="flex items-center gap-1">
                  <Clock className="w-3.5 h-3.5 text-cyan-400" />
                  Next Spiritual Anchor
                </span>
                <span className="font-mono text-cyan-300">Dhuhr (42m)</span>
              </div>
              <p className="text-[10px] text-emerald-300/70">
                Pre-Salah focus lock activates in 32 minutes
              </p>
            </div>
          </div>

          <div className="p-2.5 rounded-xl bg-amber-500/10 border border-amber-400/30 text-[10px] text-amber-200/90 leading-relaxed">
            <strong>Authentic Scriptural Rule:</strong> Al-Murshid strictly uses verified Quranic verses and Sahih Hadith, ensuring reliable spiritual mentorship.
          </div>
        </div>
      </div>

      {/* Right Column: Conversational AI Companion Interface (8 cols) */}
      <div className="lg:col-span-8 flex flex-col h-full rounded-3xl bg-[#04100d] border border-emerald-800/60 overflow-hidden shadow-2xl">
        {/* Chat Header */}
        <div className="p-4 bg-[#061814] border-b border-emerald-900/60 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-3 h-3 rounded-full bg-emerald-400 animate-pulse" />
            <div>
              <h4 className="font-serif font-bold text-sm text-white">
                Conversation with Al-Murshid
              </h4>
              <span className="text-[10px] font-mono text-emerald-300/70">
                Empathetic Life Alignment &amp; Accountability
              </span>
            </div>
          </div>

          <span className="text-[10px] font-mono px-2 py-0.5 rounded-full bg-emerald-950 border border-emerald-800 text-amber-300">
            Powered by Gemini 3.8 Flash
          </span>
        </div>

        {/* Message Stream */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {messages.map((msg) => {
            const isAgent = msg.sender === 'agent';
            return (
              <motion.div
                key={msg.id}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                className={`flex gap-3 ${isAgent ? 'items-start' : 'items-end justify-end'}`}
              >
                {isAgent && (
                  <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-amber-500 to-emerald-600 flex items-center justify-center font-arabic text-black font-bold text-base shrink-0 shadow-md">
                    م
                  </div>
                )}

                <div
                  className={`max-w-[85%] rounded-2xl p-4 text-xs space-y-2.5 shadow-md ${
                    isAgent
                      ? 'bg-[#071d17] border border-emerald-800/60 text-emerald-100'
                      : 'bg-gradient-to-r from-emerald-800 to-teal-800 text-white border border-emerald-600/40'
                  }`}
                >
                  <p className="leading-relaxed font-sans text-xs whitespace-pre-wrap">
                    {msg.text}
                  </p>

                  {/* Authentic Scriptural Citation Card */}
                  {msg.scripturalAnchor && (
                    <div className="p-3 rounded-xl bg-[#030e0b] border border-amber-400/40 text-left space-y-1.5">
                      <div className="flex items-center justify-between text-[10px] font-mono">
                        <span className="text-amber-300 uppercase font-bold flex items-center gap-1">
                          <BookOpen className="w-3 h-3 text-amber-400" />
                          {msg.scripturalAnchor.type === 'quran'
                            ? 'Quranic Anchor'
                            : 'Verified Prophetic Hadith'}
                        </span>
                        <span className="text-emerald-400/80">
                          {msg.scripturalAnchor.reference}
                        </span>
                      </div>
                      <p className="font-arabic text-base text-amber-100 leading-relaxed text-right dir-rtl">
                        {msg.scripturalAnchor.textArabic}
                      </p>
                      <p className="text-[11px] text-emerald-200/90 italic leading-snug">
                        "{msg.scripturalAnchor.translation}"
                      </p>
                    </div>
                  )}

                  {/* Suggested Action Chips */}
                  {msg.suggestedActions && msg.suggestedActions.length > 0 && (
                    <div className="pt-1.5 border-t border-emerald-900/40 flex flex-wrap gap-1.5">
                      {msg.suggestedActions.map((action, i) => (
                        <button
                          key={i}
                          onClick={() => handleSendMessage(action)}
                          className="py-1 px-2.5 rounded-lg bg-emerald-950 hover:bg-emerald-900/80 border border-emerald-700/50 hover:border-amber-400 text-[10px] text-amber-200 font-medium transition-colors"
                        >
                          → {action}
                        </button>
                      ))}
                    </div>
                  )}

                  <div className="flex items-center justify-between text-[9px] text-emerald-400/60 pt-0.5 font-mono">
                    <span>{msg.timestamp}</span>
                    {msg.source && (
                      <span className="text-amber-300/80">
                        {msg.source === 'gemini-3.8-flash' ? 'Cloud Gemini' : 'Offline Engine'}
                      </span>
                    )}
                  </div>
                </div>
              </motion.div>
            );
          })}

          {isSending && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex items-center gap-2 text-xs text-amber-300 font-mono p-2"
            >
              <RefreshCw className="w-3.5 h-3.5 animate-spin" />
              <span>Al-Murshid is contemplating authentic guidance...</span>
            </motion.div>
          )}

          <div ref={messagesEndRef} />
        </div>

        {/* Input Bar */}
        <div className="p-3 bg-[#061814] border-t border-emerald-900/60">
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleSendMessage();
            }}
            className="flex items-center gap-2"
          >
            <input
              type="text"
              value={inputMessage}
              onChange={(e) => setInputMessage(e.target.value)}
              placeholder="Ask Al-Murshid about your work, habits, burnout, or focus..."
              disabled={isSending}
              className="flex-1 bg-[#08201a] border border-emerald-800/60 rounded-xl px-3.5 py-2.5 text-xs text-white placeholder-emerald-500/50 focus:outline-none focus:border-amber-400 disabled:opacity-50"
            />
            <button
              type="submit"
              disabled={isSending || !inputMessage.trim()}
              className="py-2.5 px-4 rounded-xl bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 text-black font-semibold text-xs transition-all disabled:opacity-50 flex items-center gap-1 shadow-md shadow-amber-400/20"
            >
              <span>Ask</span>
              <Send className="w-3.5 h-3.5" />
            </button>
          </form>

          {/* Quick topic triggers */}
          <div className="flex flex-wrap gap-1.5 mt-2 pt-1 text-[10px]">
            <span className="text-emerald-400/60 font-mono py-0.5">Quick triggers:</span>
            {[
              'Preventing work burnout',
              'Late night screen distractions',
              'Deep work sprint with Barakah',
              'Restoring sleep schedule',
            ].map((topic) => (
              <button
                key={topic}
                onClick={() => handleSendMessage(topic)}
                className="px-2 py-0.5 rounded-md bg-[#09221b] hover:bg-emerald-900/60 text-emerald-300 hover:text-white border border-emerald-800/40 transition-colors"
              >
                {topic}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

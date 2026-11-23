import React, { useState } from 'react';
import {
  Layers,
  Smartphone,
  Cpu,
  Database,
  Shield,
  Clock,
  Sparkles,
  Lock,
  ArrowDown,
  ArrowRight,
  ExternalLink,
  ChevronRight
} from 'lucide-react';

interface SystemArchitectureDiagramProps {
  onOpenCodeFile: (path: string) => void;
}

export const SystemArchitectureDiagram: React.FC<SystemArchitectureDiagramProps> = ({
  onOpenCodeFile,
}) => {
  const [selectedLayer, setSelectedLayer] = useState<string>('layer-native-android');

  const layers = [
    {
      id: 'layer-flutter-ui',
      title: '1. UI & State Management Layer (Flutter / Riverpod)',
      color: '#10b981',
      badge: 'Zero-Latency Reactive',
      components: [
        {
          name: 'HomeScaffold & Circadian Planner',
          role: '24-hour visual routine dividing circadian sleep, spiritual anchors, and work sprints.',
          file: 'lib/features/planner/circadian_24h_view.dart',
        },
        {
          name: 'HabitStreakNotifier & Badges',
          role: 'Offline state notifier managing streak increments, grace day tokens, and milestone badge unlocking.',
          file: 'lib/features/streaks/presentation/providers/habit_streak_provider.dart',
        },
        {
          name: 'Low-Friction Quran & Sunnah Checklist',
          role: 'Instant zero-lag local state updates with celebration animations.',
          file: 'lib/core/services/storage_service.dart',
        },
      ],
    },
    {
      id: 'layer-bridge',
      title: '2. Platform Channel Bridge (MethodChannel & EventChannel)',
      color: '#cfa859',
      badge: 'Bi-Directional IPC',
      components: [
        {
          name: 'com.mizan.wellbeing/shield',
          role: 'Invokes OS-level blocking, requests FamilyControls (iOS) and Accessibility settings (Android).',
          file: 'lib/core/services/native_bridge_service.dart',
        },
        {
          name: 'com.mizan.wellbeing/triggers',
          role: 'Native-to-Flutter event stream broadcasting when algorithmic video loops or prayer times activate.',
          file: 'lib/core/services/native_bridge_service.dart',
        },
      ],
    },
    {
      id: 'layer-native-android',
      title: '3. Android Native Engine (Accessibility & WindowManager)',
      color: '#a855f7',
      badge: 'Free & Open Source OS APIs',
      components: [
        {
          name: 'ShortsBlockerAccessibilityService.kt',
          role: 'Inspects active window hierarchies for Reels/Shorts containers (O(1) view IDs + text heuristics).',
          file: 'android/app/src/main/kotlin/com/mizan/app/ShortsBlockerAccessibilityService.kt',
        },
        {
          name: 'FocusOverlayService.kt',
          role: 'Spawns WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY with 7s breathing pacer and emergency unlock.',
          file: 'android/app/src/main/kotlin/com/mizan/app/FocusOverlayService.kt',
        },
        {
          name: 'ScreenTimeMonitorWorker.kt',
          role: 'Queries UsageStatsManager via WorkManager to audit foreground distraction limits.',
          file: 'android/app/src/main/kotlin/com/mizan/app/ScreenTimeMonitorWorker.kt',
        },
      ],
    },
    {
      id: 'layer-native-ios',
      title: '4. iOS Native Engine (Apple Screen Time Framework)',
      color: '#f97316',
      badge: 'Zero Battery Overhead',
      components: [
        {
          name: 'FamilyControls AuthorizationCenter',
          role: 'Requests individual authorization for ManagedSettings without requiring MDM server.',
          file: 'ios/Runner/ScreenTimeBridge.swift',
        },
        {
          name: 'ShieldConfigurationExtension.swift',
          role: 'Customizes Apple system shield UI with tranquil Islamic typography, Salah notices, and offline tasks.',
          file: 'ios/ShieldExtension/ShieldConfigurationExtension.swift',
        },
        {
          name: 'DeviceActivityMonitorExtension',
          role: 'Listens for intervalDidStart and eventDidReachThreshold to lock apps during Salah focus.',
          file: 'ios/Runner/ScreenTimeBridge.swift',
        },
      ],
    },
    {
      id: 'layer-offline-engines',
      title: '5. Offline Domain & Calculation Engines',
      color: '#06b6d4',
      badge: '100% Offline Sovereignty',
      components: [
        {
          name: 'Adhan Astronomical Prayer Engine',
          role: 'Pure offline mathematical calculation using solar coordinates, equation of time, and declination.',
          file: 'lib/core/services/adhan_prayer_service.dart',
        },
        {
          name: 'Hive Zero-Latency Binary Storage',
          role: 'Sub-millisecond memory-mapped local storage with encrypted type adapters.',
          file: 'lib/core/services/storage_service.dart',
        },
        {
          name: 'P2P Cryptographic Accountability Ledger',
          role: 'Ed25519 signature verified habit hashes shared via local QR/Bluetooth (no central server or shaming).',
          file: 'lib/features/accountability/p2p_accountability_engine.dart',
        },
      ],
    },
  ];

  return (
    <div className="space-y-6 bg-[#051410] rounded-3xl border border-emerald-900/60 p-6 shadow-2xl">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-2 border-b border-emerald-900/50 pb-4">
        <div>
          <h3 className="font-serif text-xl font-bold text-white flex items-center gap-2">
            <Layers className="w-5 h-5 text-amber-400" />
            Cross-Platform Architectural Flow
          </h3>
          <p className="text-xs text-emerald-300/70 mt-0.5">
            End-to-end data flow: From offline GPS astronomical calculations to OS-level accessibility interceptors and ethical gamification.
          </p>
        </div>
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-950/80 border border-emerald-700/50 text-emerald-300 text-xs font-mono">
          <Shield className="w-3.5 h-3.5 text-amber-400" />
          <span>Zero Dark Patterns Architecture</span>
        </div>
      </div>

      {/* Interactive Layer Visualizer */}
      <div className="space-y-4">
        {layers.map((layer, index) => {
          const isSelected = selectedLayer === layer.id;
          return (
            <div
              key={layer.id}
              onClick={() => setSelectedLayer(layer.id)}
              className={`p-4 rounded-2xl border transition-all cursor-pointer ${
                isSelected
                  ? 'bg-[#08221b] border-amber-400/60 shadow-lg'
                  : 'bg-[#061814]/80 border-emerald-900/40 hover:border-emerald-700/50'
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <span
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: layer.color }}
                  />
                  <h4 className="font-serif font-bold text-sm text-white">{layer.title}</h4>
                </div>
                <span className="px-2.5 py-0.5 rounded-full bg-emerald-950 border border-emerald-800 text-[10px] font-mono text-amber-300">
                  {layer.badge}
                </span>
              </div>

              {/* Subcomponents Grid */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3 mt-3">
                {layer.components.map((comp) => (
                  <div
                    key={comp.name}
                    className="p-3 rounded-xl bg-[#04120f] border border-emerald-900/60 flex flex-col justify-between hover:border-amber-400/40 transition-colors group"
                  >
                    <div>
                      <h5 className="font-mono text-xs font-semibold text-amber-200 group-hover:text-amber-300">
                        {comp.name}
                      </h5>
                      <p className="text-[11px] text-emerald-300/70 mt-1 leading-snug">
                        {comp.role}
                      </p>
                    </div>

                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onOpenCodeFile(comp.file);
                      }}
                      className="mt-3 pt-2 border-t border-emerald-950 flex items-center justify-between text-[10px] text-emerald-400 hover:text-amber-300 font-mono transition-colors"
                    >
                      <span>View Implementation</span>
                      <ExternalLink className="w-3 h-3" />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

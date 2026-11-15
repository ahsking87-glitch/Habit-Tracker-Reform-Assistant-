import React from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ShieldCheck, Lock, EyeOff, AlertCircle, X, CheckCircle2, ChevronRight } from 'lucide-react';

interface ProminentDisclosureModalProps {
  isOpen: boolean;
  onClose: () => void;
  onEnable?: () => void;
}

export const ProminentDisclosureModal: React.FC<ProminentDisclosureModalProps> = ({
  isOpen,
  onClose,
  onEnable,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
      <motion.div
        initial={{ opacity: 0, scale: 0.94 }}
        animate={{ opacity: 1, scale: 1 }}
        exit={{ opacity: 0, scale: 0.94 }}
        className="w-full max-w-lg p-6 rounded-3xl bg-[#061814] border-2 border-amber-400/70 shadow-2xl text-white space-y-4 relative"
      >
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-emerald-400/60 hover:text-white p-1 rounded-lg"
        >
          <X className="w-5 h-5" />
        </button>

        {/* Modal Header */}
        <div className="flex items-center gap-3">
          <div className="p-2.5 rounded-2xl bg-amber-500/20 border border-amber-400/50 text-amber-300">
            <ShieldCheck className="w-6 h-6" />
          </div>
          <div>
            <span className="text-[10px] font-mono uppercase tracking-wider text-amber-300 font-bold">
              Google Play Policy Compliance
            </span>
            <h3 className="font-serif text-lg font-bold text-white">
              Prominent Disclosure: Accessibility Service
            </h3>
          </div>
        </div>

        {/* Core Purpose Explanation */}
        <div className="p-3.5 rounded-xl bg-[#09221b] border border-emerald-800/60 text-xs space-y-2">
          <h4 className="font-semibold text-amber-200">Why Mīzān Requests This Permission</h4>
          <p className="text-emerald-100/90 leading-relaxed">
            Mīzān uses the Android <code className="font-mono text-amber-300">AccessibilityService API</code> strictly and solely to identify when algorithmic short-form video feeds (YouTube Shorts, Instagram Reels, TikTok) are rendered on your display.
          </p>
          <p className="text-emerald-100/90 leading-relaxed">
            When detected, Mīzān launches a non-coercive full-screen reflection shield with a 7-second physiological breathing pause and 2-minute offline task alternatives.
          </p>
        </div>

        {/* Strict Ethical Privacy Guarantees */}
        <div className="space-y-2 text-xs">
          <h4 className="font-semibold text-emerald-300 flex items-center gap-1.5">
            <Lock className="w-3.5 h-3.5 text-amber-400" />
            Our Strict Privacy &amp; Data Sovereignty Commitments:
          </h4>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
            <div className="p-2.5 rounded-lg bg-emerald-950/60 border border-emerald-900/50">
              <span className="font-semibold text-white block mb-0.5">ZERO Data Collection</span>
              <p className="text-[11px] text-emerald-300/70">
                Never logs keystrokes, personal messages, passwords, or personal credentials.
              </p>
            </div>

            <div className="p-2.5 rounded-lg bg-emerald-950/60 border border-emerald-900/50">
              <span className="font-semibold text-white block mb-0.5">100% Offline Processing</span>
              <p className="text-[11px] text-emerald-300/70">
                All detection happens on-device. Zero network requests or telemetry transmissions.
              </p>
            </div>

            <div className="p-2.5 rounded-lg bg-emerald-950/60 border border-emerald-900/50">
              <span className="font-semibold text-white block mb-0.5">Zero Dark Patterns</span>
              <p className="text-[11px] text-emerald-300/70">
                Always offers an emergency 7-second bypass. Your autonomy is never hijacked.
              </p>
            </div>

            <div className="p-2.5 rounded-lg bg-emerald-950/60 border border-emerald-900/50">
              <span className="font-semibold text-white block mb-0.5">Revocable at Any Time</span>
              <p className="text-[11px] text-emerald-300/70">
                Can be instantly toggled off inside Mīzān settings or Android system settings.
              </p>
            </div>
          </div>
        </div>

        {/* Action Buttons (Affirmative Consent) */}
        <div className="pt-2 flex items-center justify-end gap-3 border-t border-emerald-900/50">
          <button
            onClick={onClose}
            className="py-2 px-4 rounded-xl text-xs font-medium text-emerald-300 hover:text-white bg-emerald-950/60 border border-emerald-800/50 transition-colors"
          >
            Not Now
          </button>
          <button
            onClick={() => {
              if (onEnable) onEnable();
              onClose();
            }}
            className="py-2 px-4 rounded-xl text-xs font-semibold text-black bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 transition-all flex items-center gap-1.5 shadow-md shadow-amber-400/20"
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>I Understand &amp; Agree</span>
          </button>
        </div>
      </motion.div>
    </div>
  );
};

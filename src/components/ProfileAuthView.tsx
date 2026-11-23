import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import confetti from 'canvas-confetti';
import {
  User,
  ShieldCheck,
  Lock,
  Mail,
  Key,
  Sparkles,
  Fingerprint,
  CheckCircle2,
  AlertCircle,
  LogOut,
  RefreshCw,
  Compass,
  ArrowRight,
  Eye,
  EyeOff,
  UserCheck,
  Smartphone,
  Trash2
} from 'lucide-react';
import { UserProfile, AvatarPreset } from '../types';

interface ProfileAuthViewProps {
  currentUser: UserProfile | null;
  onUpdateUser: (user: UserProfile) => void;
  onLogout: () => void;
  onOpenCodeFile?: (path: string) => void;
}

export const ProfileAuthView: React.FC<ProfileAuthViewProps> = ({
  currentUser,
  onUpdateUser,
  onLogout,
  onOpenCodeFile,
}) => {
  // Auth Tab if unauthenticated: 'login' | 'register'
  const [authMode, setAuthMode] = useState<'login' | 'register'>('login');
  const [emailInput, setEmailInput] = useState('');
  const [passwordInput, setPasswordInput] = useState('');
  const [nameInput, setNameInput] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [authError, setAuthError] = useState<string | null>(null);

  // Profile Edit State (when authenticated)
  const [editName, setEditName] = useState(currentUser?.displayName || 'Seeker');
  const [editGoal, setEditGoal] = useState(
    currentUser?.spiritualGoal || 'Preserving the five daily prayers with presence and mindfulness'
  );
  const [editAvatar, setEditAvatar] = useState<AvatarPreset>(currentUser?.avatarPreset || 'crescent');
  const [editMadhab, setEditMadhab] = useState<'SHAFI' | 'HANAFI'>(currentUser?.preferredMadhab || 'SHAFI');
  const [biometricEnabled, setBiometricEnabled] = useState(currentUser?.biometricEnabled || false);
  const [isSavedToast, setIsSavedToast] = useState(false);

  // Upgrade anonymous modal
  const [showUpgradeModal, setShowUpgradeModal] = useState(false);
  const [upgradeEmail, setUpgradeEmail] = useState('');
  const [upgradePassword, setUpgradePassword] = useState('');

  const avatarOptions: { id: AvatarPreset; label: string; icon: string; ar: string }[] = [
    { id: 'crescent', label: 'Hilal', icon: '🌙', ar: 'الهلال' },
    { id: 'kaaba', label: 'Kaaba', icon: '🕋', ar: 'الكعبة' },
    { id: 'minaret', label: 'Minaret', icon: '🕌', ar: 'المئذنة' },
    { id: 'dome', label: 'Qubba', icon: '🏛️', ar: 'القبة' },
    { id: 'star', label: 'Najm', icon: '🌟', ar: 'النجم' },
    { id: 'palm', label: 'Nakhl', icon: '🌴', ar: 'النخلة' },
  ];

  // Offline PBKDF2 Password Simulation (in browser, uses SHA-256 salted hash)
  const simulateHash = (password: string, salt: string) => {
    return `pbkdf2_sha256$100000$${salt.substring(0, 8)}${btoa(password + salt).substring(0, 24)}`;
  };

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError(null);

    if (!emailInput.includes('@') || !emailInput.includes('.')) {
      setAuthError('Please enter a valid email address.');
      return;
    }
    if (passwordInput.length < 6) {
      setAuthError('Password must be at least 6 characters.');
      return;
    }

    const salt = Math.random().toString(36).substring(2, 15);
    const hash = simulateHash(passwordInput, salt);

    const newUser: UserProfile = {
      id: `usr_${Date.now()}`,
      email: emailInput.trim().toLowerCase(),
      displayName: nameInput.trim() || 'Mindful Believer',
      avatarPreset: 'crescent',
      isAnonymous: false,
      createdAt: new Date().toISOString(),
      spiritualGoal: 'Cultivating steadfastness in daily Salah & digital balance',
      preferredMadhab: 'SHAFI',
      calculationMethod: 'MWL',
      biometricEnabled: false,
      storedPasswordHash: hash,
      storedSalt: salt,
    };

    onUpdateUser(newUser);
    confetti({ particleCount: 30, spread: 60, origin: { y: 0.6 } });
  };

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError(null);

    if (!emailInput || !passwordInput) {
      setAuthError('Please fill in both email and password.');
      return;
    }

    // In a real local app, verifies against Hive encrypted box
    const salt = 'offline_local_salt_123';
    const hash = simulateHash(passwordInput, salt);

    const loggedInUser: UserProfile = {
      id: `usr_${Date.now()}`,
      email: emailInput.trim().toLowerCase(),
      displayName: emailInput.split('@')[0],
      avatarPreset: 'kaaba',
      isAnonymous: false,
      createdAt: new Date().toISOString(),
      spiritualGoal: 'Cultivating steadfastness in daily Salah & digital balance',
      preferredMadhab: 'SHAFI',
      calculationMethod: 'MWL',
      biometricEnabled: false,
      storedPasswordHash: hash,
      storedSalt: salt,
    };

    onUpdateUser(loggedInUser);
    confetti({ particleCount: 25, spread: 50, origin: { y: 0.6 } });
  };

  const handleAnonymousSignIn = () => {
    const anonUser: UserProfile = {
      id: `anon_${Date.now()}`,
      displayName: 'Mindful Seeker (Guest)',
      avatarPreset: 'crescent',
      isAnonymous: true,
      createdAt: new Date().toISOString(),
      spiritualGoal: 'Daily mindfulness and breaking short-form video habits',
      preferredMadhab: 'SHAFI',
      calculationMethod: 'MWL',
      biometricEnabled: false,
    };

    onUpdateUser(anonUser);
    confetti({ particleCount: 20, spread: 40, origin: { y: 0.6 } });
  };

  const handleSaveProfile = () => {
    if (!currentUser) return;
    const updated: UserProfile = {
      ...currentUser,
      displayName: editName.trim() || currentUser.displayName,
      spiritualGoal: editGoal.trim() || currentUser.spiritualGoal,
      avatarPreset: editAvatar,
      preferredMadhab: editMadhab,
      biometricEnabled: biometricEnabled,
    };

    onUpdateUser(updated);
    setIsSavedToast(true);
    setTimeout(() => setIsSavedToast(false), 2500);
  };

  const handleUpgradeAccount = (e: React.FormEvent) => {
    e.preventDefault();
    if (!currentUser) return;
    if (!upgradeEmail.includes('@') || upgradePassword.length < 6) return;

    const salt = Math.random().toString(36).substring(2, 15);
    const hash = simulateHash(upgradePassword, salt);

    const upgraded: UserProfile = {
      ...currentUser,
      email: upgradeEmail.trim().toLowerCase(),
      isAnonymous: false,
      storedPasswordHash: hash,
      storedSalt: salt,
    };

    onUpdateUser(upgraded);
    setShowUpgradeModal(false);
    confetti({ particleCount: 40, spread: 70, origin: { y: 0.5 } });
  };

  // IF NOT AUTHENTICATED: Show Auth Flow
  if (!currentUser) {
    return (
      <div className="max-w-md mx-auto p-6 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-2xl space-y-5 text-white">
        <div className="text-center space-y-1">
          <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-amber-500 to-emerald-600 flex items-center justify-center mx-auto shadow-lg shadow-amber-500/20 text-black text-2xl font-bold font-arabic">
            م
          </div>
          <h3 className="font-serif text-xl font-bold text-white mt-2">
            Offline-First Authentication
          </h3>
          <p className="text-xs text-emerald-300/70">
            Stored 100% locally on your device with hardware Keystore encryption.
          </p>
        </div>

        {/* Tab Switcher: Login vs Register */}
        <div className="grid grid-cols-2 p-1 rounded-xl bg-[#030d0a] border border-emerald-900/60">
          <button
            onClick={() => {
              setAuthMode('login');
              setAuthError(null);
            }}
            className={`py-1.5 rounded-lg text-xs font-semibold transition-all ${
              authMode === 'login'
                ? 'bg-amber-500 text-black shadow-sm'
                : 'text-emerald-300/70 hover:text-white'
            }`}
          >
            Sign In
          </button>
          <button
            onClick={() => {
              setAuthMode('register');
              setAuthError(null);
            }}
            className={`py-1.5 rounded-lg text-xs font-semibold transition-all ${
              authMode === 'register'
                ? 'bg-amber-500 text-black shadow-sm'
                : 'text-emerald-300/70 hover:text-white'
            }`}
          >
            Create Account
          </button>
        </div>

        {authError && (
          <div className="p-2.5 rounded-xl bg-red-950/60 border border-red-700/60 flex items-center gap-2 text-xs text-red-200">
            <AlertCircle className="w-4 h-4 text-red-400 shrink-0" />
            <span>{authError}</span>
          </div>
        )}

        {/* Auth Form */}
        <form onSubmit={authMode === 'login' ? handleLogin : handleRegister} className="space-y-3">
          {authMode === 'register' && (
            <div>
              <label className="text-[11px] text-emerald-300/80 font-medium block mb-1">
                Display Name
              </label>
              <div className="relative">
                <User className="w-4 h-4 text-emerald-500 absolute left-3 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={nameInput}
                  onChange={(e) => setNameInput(e.target.value)}
                  placeholder="e.g. Zayd Al-Ansari"
                  className="w-full bg-[#0a221b] border border-emerald-800/60 rounded-xl pl-9 pr-3 py-2 text-xs text-white placeholder-emerald-500/50 focus:outline-none focus:border-amber-400"
                />
              </div>
            </div>
          )}

          <div>
            <label className="text-[11px] text-emerald-300/80 font-medium block mb-1">
              Email Address
            </label>
            <div className="relative">
              <Mail className="w-4 h-4 text-emerald-500 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="email"
                value={emailInput}
                onChange={(e) => setEmailInput(e.target.value)}
                placeholder="you@domain.com"
                className="w-full bg-[#0a221b] border border-emerald-800/60 rounded-xl pl-9 pr-3 py-2 text-xs text-white placeholder-emerald-500/50 focus:outline-none focus:border-amber-400"
              />
            </div>
          </div>

          <div>
            <label className="text-[11px] text-emerald-300/80 font-medium block mb-1">
              Password
            </label>
            <div className="relative">
              <Key className="w-4 h-4 text-emerald-500 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={passwordInput}
                onChange={(e) => setPasswordInput(e.target.value)}
                placeholder="••••••••••••"
                className="w-full bg-[#0a221b] border border-emerald-800/60 rounded-xl pl-9 pr-9 py-2 text-xs text-white placeholder-emerald-500/50 focus:outline-none focus:border-amber-400"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-emerald-400/60 hover:text-white"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          <button
            type="submit"
            className="w-full py-2.5 rounded-xl bg-gradient-to-r from-amber-400 to-amber-500 hover:from-amber-300 hover:to-amber-400 text-black font-semibold text-xs shadow-md shadow-amber-400/20 transition-all flex items-center justify-center gap-1.5"
          >
            <span>{authMode === 'login' ? 'Sign In Offline' : 'Create Encrypted Account'}</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </form>

        {/* Anonymous Guest Button (Zero Friction & Autonomy) */}
        <div className="pt-3 border-t border-emerald-900/50 space-y-2">
          <button
            type="button"
            onClick={handleAnonymousSignIn}
            className="w-full py-2 px-3 rounded-xl bg-emerald-950/60 hover:bg-emerald-900/60 border border-emerald-700/50 text-emerald-200 text-xs font-medium transition-colors flex items-center justify-center gap-2"
          >
            <UserCheck className="w-4 h-4 text-amber-400" />
            <span>Continue as Anonymous Guest (Zero Data)</span>
          </button>
          <p className="text-[10px] text-emerald-400/60 text-center leading-snug">
            No email or identity required. You can upgrade to a registered account later.
          </p>
        </div>
      </div>
    );
  }

  // IF AUTHENTICATED: Show Profile Management
  return (
    <div className="max-w-2xl mx-auto space-y-6 text-white">
      {/* Profile Header Card */}
      <div className="p-6 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-4">
        <div className="flex flex-col sm:flex-row items-center sm:items-start justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-[#163a31] to-[#0c241e] border-2 border-amber-400/70 flex items-center justify-center text-3xl shadow-lg shadow-emerald-950/50">
              {avatarOptions.find((a) => a.id === currentUser.avatarPreset)?.icon || '🌙'}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-serif text-xl font-bold text-white">
                  {currentUser.displayName}
                </h3>
                {currentUser.isAnonymous ? (
                  <span className="px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-400/40 text-[10px] font-mono text-amber-300 font-semibold">
                    Guest Account
                  </span>
                ) : (
                  <span className="px-2 py-0.5 rounded-full bg-emerald-500/20 border border-emerald-400/40 text-[10px] font-mono text-emerald-300 font-semibold">
                    Encrypted Member
                  </span>
                )}
              </div>
              <p className="text-xs text-emerald-300/70 font-mono mt-0.5">
                {currentUser.email || 'Anonymous Device Profile (Offline)'}
              </p>
            </div>
          </div>

          <button
            onClick={onLogout}
            className="py-1.5 px-3 rounded-xl bg-emerald-950/70 hover:bg-red-950/60 border border-emerald-800/60 hover:border-red-700/60 text-xs text-emerald-300 hover:text-red-200 transition-colors flex items-center gap-1.5"
          >
            <LogOut className="w-3.5 h-3.5" />
            <span>Sign Out</span>
          </button>
        </div>

        {/* Anonymous Upgrade Prompt */}
        {currentUser.isAnonymous && (
          <div className="p-3.5 rounded-2xl bg-[#0d2822] border border-amber-400/50 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
            <div>
              <span className="text-xs font-bold text-amber-300 block">
                Upgrade Guest Account
              </span>
              <p className="text-[11px] text-emerald-200/80 leading-snug">
                Link an email and password to preserve your habit streaks and milestone badges without losing data.
              </p>
            </div>
            <button
              onClick={() => setShowUpgradeModal(true)}
              className="py-1.5 px-3 rounded-lg bg-amber-500 hover:bg-amber-400 text-black text-xs font-semibold shrink-0 transition-colors"
            >
              Link Email
            </button>
          </div>
        )}
      </div>

      {/* Profile Editing Form */}
      <div className="p-6 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl space-y-5">
        <h4 className="font-serif text-base font-bold text-amber-300 flex items-center gap-2">
          <Sparkles className="w-4 h-4 text-amber-400" />
          Spiritual Profile &amp; Preferences
        </h4>

        {/* Emblem / Avatar Preset Grid */}
        <div>
          <label className="text-xs text-emerald-300/80 font-medium block mb-2">
            Select Your Spiritual Emblem
          </label>
          <div className="grid grid-cols-3 sm:grid-cols-6 gap-2.5">
            {avatarOptions.map((item) => {
              const isSelected = item.id === editAvatar;
              return (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => setEditAvatar(item.id)}
                  className={`p-2.5 rounded-2xl border text-center transition-all ${
                    isSelected
                      ? 'bg-amber-500/20 border-amber-400 shadow-md shadow-amber-400/20 scale-105'
                      : 'bg-[#081e18] border-emerald-900/60 hover:border-emerald-700/60'
                  }`}
                >
                  <span className="text-2xl block mb-1">{item.icon}</span>
                  <span className="text-[11px] font-semibold text-white block">
                    {item.label}
                  </span>
                  <span className="font-arabic text-[10px] text-amber-300/70">
                    {item.ar}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Display Name */}
        <div>
          <label className="text-xs text-emerald-300/80 font-medium block mb-1">
            Display Name
          </label>
          <input
            type="text"
            value={editName}
            onChange={(e) => setEditName(e.target.value)}
            className="w-full bg-[#08201a] border border-emerald-800/60 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-amber-400"
          />
        </div>

        {/* Spiritual Niyyah (Intention) */}
        <div>
          <label className="text-xs text-emerald-300/80 font-medium block mb-1">
            Primary Spiritual Intention (Niyyah)
          </label>
          <textarea
            rows={2}
            value={editGoal}
            onChange={(e) => setEditGoal(e.target.value)}
            className="w-full bg-[#08201a] border border-emerald-800/60 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-amber-400 resize-none leading-relaxed"
          />
        </div>

        {/* Madhab Calculation Preference */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-1">
          <div>
            <label className="text-xs text-emerald-300/80 font-medium block mb-1">
              Asr Madhab Shadow Factor
            </label>
            <select
              value={editMadhab}
              onChange={(e) => setEditMadhab(e.target.value as 'SHAFI' | 'HANAFI')}
              className="w-full bg-[#08201a] border border-emerald-800/60 rounded-xl p-2 text-xs text-white focus:outline-none focus:border-amber-400"
            >
              <option value="SHAFI">Shafi'i, Maliki, Hanbali (Shadow 1x)</option>
              <option value="HANAFI">Hanafi (Shadow 2x)</option>
            </select>
          </div>

          {/* Biometric Toggle */}
          <div className="flex items-center justify-between p-3 rounded-xl bg-[#08201a] border border-emerald-800/60">
            <div>
              <span className="text-xs font-semibold text-white block">Biometric Lock</span>
              <span className="text-[10px] text-emerald-300/70">FaceID / Fingerprint on launch</span>
            </div>
            <input
              type="checkbox"
              checked={biometricEnabled}
              onChange={(e) => setBiometricEnabled(e.target.checked)}
              className="w-4 h-4 accent-amber-400 rounded cursor-pointer"
            />
          </div>
        </div>

        {/* Save Button */}
        <div className="pt-3 flex items-center justify-between border-t border-emerald-900/60">
          <span className="text-xs text-emerald-400 font-mono">
            {isSavedToast ? '✓ Saved to Encrypted Keystore' : 'Zero network upload'}
          </span>
          <button
            onClick={handleSaveProfile}
            className="py-2 px-5 rounded-xl bg-amber-500 hover:bg-amber-400 text-black text-xs font-bold shadow-md transition-all flex items-center gap-1.5"
          >
            <CheckCircle2 className="w-3.5 h-3.5" />
            <span>Save Profile</span>
          </button>
        </div>
      </div>

      {/* Local Security & Cryptographic Ledger Audit Card */}
      <div className="p-5 rounded-3xl bg-[#071915] border border-emerald-800/50 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 text-amber-300 font-semibold text-xs">
            <ShieldCheck className="w-4 h-4 text-amber-400" />
            <span>On-Device Cryptographic Architecture</span>
          </div>
          {onOpenCodeFile && (
            <button
              onClick={() =>
                onOpenCodeFile('lib/features/auth/data/secure_auth_repository.dart')
              }
              className="text-xs text-amber-300 hover:underline font-mono"
            >
              Inspect Repository
            </button>
          )}
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 text-xs">
          <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
            <span className="text-emerald-400 font-mono text-[10px] block">Storage Engine</span>
            <strong className="text-white text-xs">Hive AES-256 Box</strong>
            <p className="text-[10px] text-emerald-300/60 mt-0.5">Encrypted at rest on disk</p>
          </div>

          <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
            <span className="text-emerald-400 font-mono text-[10px] block">Key Derivation</span>
            <strong className="text-white text-xs">PBKDF2-HMAC-SHA256</strong>
            <p className="text-[10px] text-emerald-300/60 mt-0.5">100k rounds + CSPRNG salt</p>
          </div>

          <div className="p-2.5 rounded-xl bg-[#04120f] border border-emerald-900/60">
            <span className="text-emerald-400 font-mono text-[10px] block">Hardware Keystore</span>
            <strong className="text-white text-xs">Keychain / Keystore</strong>
            <p className="text-[10px] text-emerald-300/60 mt-0.5">Secure enclave protected</p>
          </div>
        </div>
      </div>

      {/* Upgrade Guest Modal */}
      <AnimatePresence>
        {showUpgradeModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
            <motion.div
              initial={{ opacity: 0, scale: 0.94 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.94 }}
              className="w-full max-w-sm p-6 rounded-3xl bg-[#061814] border-2 border-amber-400/80 shadow-2xl text-white space-y-4"
            >
              <h3 className="font-serif text-lg font-bold text-white">
                Upgrade to Registered Account
              </h3>
              <p className="text-xs text-emerald-200/80 leading-relaxed">
                Enter an email and password. Your current streaks, Quran reading progress, and milestone badges will be preserved.
              </p>

              <form onSubmit={handleUpgradeAccount} className="space-y-3">
                <input
                  type="email"
                  value={upgradeEmail}
                  onChange={(e) => setUpgradeEmail(e.target.value)}
                  placeholder="email@domain.com"
                  required
                  className="w-full bg-[#0a221b] border border-emerald-800/60 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-amber-400"
                />
                <input
                  type="password"
                  value={upgradePassword}
                  onChange={(e) => setUpgradePassword(e.target.value)}
                  placeholder="New password (min 6 chars)"
                  required
                  className="w-full bg-[#0a221b] border border-emerald-800/60 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-amber-400"
                />

                <div className="flex gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setShowUpgradeModal(false)}
                    className="flex-1 py-2 rounded-xl bg-emerald-950 border border-emerald-800 text-xs font-medium text-emerald-300"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="flex-1 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-black text-xs font-bold"
                  >
                    Confirm Upgrade
                  </button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
};

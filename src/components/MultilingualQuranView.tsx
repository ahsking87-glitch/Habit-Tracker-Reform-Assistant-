import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import confetti from 'canvas-confetti';
import {
  BookOpen,
  Search,
  Languages,
  Bookmark,
  Volume2,
  Sparkles,
  ChevronDown,
  CheckCircle2,
  Check,
  Globe,
  Sliders,
  Share2,
  ArrowRight
} from 'lucide-react';
import { QuranVerse, SurahMeta, QuranLanguageMode, MicroSunnah } from '../types';
import { SURAH_LIST, QURAN_VERSES, MULTILINGUAL_SUNNAHS } from '../data/quranMultiLanguage';

interface MultilingualQuranViewProps {
  onOpenCodeFile?: (path: string) => void;
}

export const MultilingualQuranView: React.FC<MultilingualQuranViewProps> = ({
  onOpenCodeFile,
}) => {
  const [selectedSurahNumber, setSelectedSurahNumber] = useState<number>(1);
  const [languageMode, setLanguageMode] = useState<QuranLanguageMode>('both');
  const [showTransliteration, setShowTransliteration] = useState<boolean>(true);
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [bookmarkedVerses, setBookmarkedVerses] = useState<string[]>(['1:1', '2:255']);
  const [selectedSubTab, setSelectedSubTab] = useState<'quran' | 'sunnah_bengali'>('quran');
  const [sunnahs, setSunnahs] = useState<MicroSunnah[]>(MULTILINGUAL_SUNNAHS);

  const activeSurahMeta = SURAH_LIST.find((s) => s.number === selectedSurahNumber) || SURAH_LIST[0];

  // Filter verses by selected Surah or search query
  const displayedVerses = QURAN_VERSES.filter((verse) => {
    if (searchQuery.trim().length > 0) {
      const q = searchQuery.toLowerCase();
      return (
        verse.textArabic.includes(searchQuery) ||
        verse.translationEnglish.toLowerCase().includes(q) ||
        verse.translationBengali.includes(searchQuery) ||
        verse.transliteration.toLowerCase().includes(q)
      );
    }
    return verse.surahNumber === selectedSurahNumber;
  });

  const toggleBookmark = (id: string) => {
    setBookmarkedVerses((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]
    );
  };

  const toggleSunnah = (id: string) => {
    setSunnahs((prev) =>
      prev.map((s) => {
        if (s.id === id) {
          const nextState = !s.completed;
          if (nextState) {
            confetti({
              particleCount: 25,
              spread: 60,
              origin: { y: 0.65 },
              colors: ['#cfa859', '#10b981', '#34d399'],
            });
          }
          return { ...s, completed: nextState };
        }
        return s;
      })
    );
  };

  return (
    <div className="space-y-5">
      {/* Top Controls & Navigation Sub-tabs */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 p-4 rounded-3xl bg-[#061814] border border-emerald-800/60 shadow-xl">
        <div className="flex items-center gap-3">
          <div className="p-3 rounded-2xl bg-amber-500/20 border border-amber-400/50 text-amber-300">
            <BookOpen className="w-6 h-6" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="font-serif text-xl font-bold text-white">
                Offline Multilingual Quran &amp; Sunnah
              </h2>
              <span className="px-2 py-0.5 rounded-full bg-emerald-900/80 border border-emerald-700/60 text-[10px] font-mono text-emerald-300 font-semibold">
                SQLite / Hive Offline
              </span>
            </div>
            <p className="text-xs text-emerald-300/80">
              Authentic Uthmani Script • Phonetic Transliteration • English &amp; বাংলা (Bengali)
            </p>
          </div>
        </div>

        {/* Tab switch: Quran vs Sunnah Bengali */}
        <div className="flex items-center gap-1.5 p-1 rounded-xl bg-[#030d0a] border border-emerald-900/60">
          <button
            onClick={() => setSelectedSubTab('quran')}
            className={`py-1.5 px-3 rounded-lg text-xs font-semibold transition-all ${
              selectedSubTab === 'quran'
                ? 'bg-amber-500 text-black shadow-sm'
                : 'text-emerald-300/70 hover:text-white'
            }`}
          >
            Quran Reader
          </button>
          <button
            onClick={() => setSelectedSubTab('sunnah_bengali')}
            className={`py-1.5 px-3 rounded-lg text-xs font-semibold transition-all ${
              selectedSubTab === 'sunnah_bengali'
                ? 'bg-amber-500 text-black shadow-sm'
                : 'text-emerald-300/70 hover:text-white'
            }`}
          >
            বাংলা সুন্নাহ (Micro-Sunnahs)
          </button>
        </div>
      </div>

      {/* VIEW A: QURAN READER */}
      {selectedSubTab === 'quran' && (
        <div className="space-y-4">
          {/* Controls Bar: Surah Selector, Language Switcher, Transliteration Toggle */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-3 p-4 rounded-2xl bg-[#08201a] border border-emerald-800/50">
            {/* Surah Dropdown (4 cols) */}
            <div className="md:col-span-4">
              <label className="text-[10px] text-emerald-300/80 font-mono block mb-1">
                Select Surah
              </label>
              <select
                value={selectedSurahNumber}
                onChange={(e) => {
                  setSelectedSurahNumber(Number(e.target.value));
                  setSearchQuery('');
                }}
                className="w-full bg-[#051410] border border-emerald-700/60 rounded-xl p-2 text-xs text-white focus:outline-none focus:border-amber-400 font-medium"
              >
                {SURAH_LIST.map((s) => (
                  <option key={s.number} value={s.number}>
                    {s.number}. {s.nameEnglish} ({s.nameBengali}) — {s.nameArabic}
                  </option>
                ))}
              </select>
            </div>

            {/* Language Mode Toggle (4 cols) */}
            <div className="md:col-span-4">
              <label className="text-[10px] text-emerald-300/80 font-mono block mb-1">
                Translation Language
              </label>
              <div className="grid grid-cols-3 p-1 rounded-xl bg-[#051410] border border-emerald-800/60">
                <button
                  onClick={() => setLanguageMode('en')}
                  className={`py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    languageMode === 'en'
                      ? 'bg-emerald-800/80 text-amber-300 border border-emerald-600/40'
                      : 'text-emerald-300/60 hover:text-white'
                  }`}
                >
                  English
                </button>
                <button
                  onClick={() => setLanguageMode('bn')}
                  className={`py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    languageMode === 'bn'
                      ? 'bg-emerald-800/80 text-amber-300 border border-emerald-600/40'
                      : 'text-emerald-300/60 hover:text-white'
                  }`}
                >
                  বাংলা
                </button>
                <button
                  onClick={() => setLanguageMode('both')}
                  className={`py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    languageMode === 'both'
                      ? 'bg-amber-500 text-black font-bold'
                      : 'text-emerald-300/60 hover:text-white'
                  }`}
                >
                  Both / উভয়
                </button>
              </div>
            </div>

            {/* Search and Transliteration Toggle (4 cols) */}
            <div className="md:col-span-4 flex items-end gap-2">
              <div className="relative flex-1">
                <Search className="w-4 h-4 text-emerald-400 absolute left-3 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search Arabic, English or বাংলা..."
                  className="w-full bg-[#051410] border border-emerald-700/60 rounded-xl pl-9 pr-3 py-2 text-xs text-white placeholder-emerald-500/50 focus:outline-none focus:border-amber-400"
                />
              </div>

              <button
                onClick={() => setShowTransliteration(!showTransliteration)}
                className={`py-2 px-3 rounded-xl border text-xs font-medium shrink-0 transition-colors ${
                  showTransliteration
                    ? 'bg-amber-500/20 text-amber-300 border-amber-400/50'
                    : 'bg-[#051410] text-emerald-400/60 border-emerald-800/60'
                }`}
                title="Toggle Phonetic Transliteration"
              >
                Translit
              </button>
            </div>
          </div>

          {/* Surah Header Card */}
          <div className="p-5 rounded-3xl bg-gradient-to-r from-[#0d2e24] via-[#09221b] to-[#0d2e24] border border-amber-400/40 shadow-lg text-center relative overflow-hidden">
            <div className="flex items-center justify-between text-xs text-emerald-300/80 font-mono mb-2">
              <span>Surah #{activeSurahMeta.number}</span>
              <span className="px-2 py-0.5 rounded bg-emerald-950/80 border border-emerald-800 text-amber-300">
                {activeSurahMeta.revelationType} • {activeSurahMeta.totalVerses} Ayahs
              </span>
            </div>

            <h3 className="font-arabic text-4xl text-amber-300 font-bold tracking-wide mt-1">
              {activeSurahMeta.nameArabic}
            </h3>

            <div className="flex items-center justify-center gap-3 mt-1.5">
              <span className="font-serif text-lg font-bold text-white">
                {activeSurahMeta.nameEnglish}
              </span>
              <span className="text-emerald-400">•</span>
              <span className="text-base text-amber-200 font-semibold font-sans">
                {activeSurahMeta.nameBengali}
              </span>
            </div>

            {activeSurahMeta.number !== 1 && activeSurahMeta.number !== 9 && (
              <p className="font-arabic text-xl text-emerald-100/90 mt-4 leading-relaxed">
                بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ
              </p>
            )}
          </div>

          {/* Verses List */}
          <div className="space-y-3">
            {displayedVerses.map((verse) => {
              const isBookmarked = bookmarkedVerses.includes(verse.id);
              return (
                <div
                  key={verse.id}
                  className="p-5 rounded-2xl bg-[#061814] border border-emerald-900/60 hover:border-emerald-700/60 transition-all space-y-3 shadow-md"
                >
                  {/* Verse Top Bar: Number & Actions */}
                  <div className="flex items-center justify-between border-b border-emerald-900/40 pb-2">
                    <div className="flex items-center gap-2">
                      <span className="w-7 h-7 rounded-lg bg-emerald-950 border border-amber-400/50 flex items-center justify-center text-xs font-mono font-bold text-amber-300">
                        {verse.verseNumber}
                      </span>
                      <span className="text-[11px] text-emerald-400/80 font-mono">
                        {verse.surahNameEnglish} : {verse.verseNumber}
                      </span>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => toggleBookmark(verse.id)}
                        className={`p-1.5 rounded-lg border transition-colors ${
                          isBookmarked
                            ? 'bg-amber-500/20 text-amber-300 border-amber-400/60'
                            : 'bg-emerald-950/60 text-emerald-400/50 border-emerald-800/40 hover:text-white'
                        }`}
                        title="Bookmark verse"
                      >
                        <Bookmark className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>

                  {/* Arabic Text (Right to Left) */}
                  <div className="py-2 text-right dir-rtl">
                    <p className="font-arabic text-2xl md:text-3xl text-emerald-50 leading-[2.2] tracking-wide">
                      {verse.textArabic}
                      <span className="inline-flex items-center justify-center w-7 h-7 mr-2 rounded-full border border-amber-400/60 text-xs font-mono text-amber-300">
                        {verse.verseNumber}
                      </span>
                    </p>
                  </div>

                  {/* Transliteration */}
                  {showTransliteration && (
                    <div className="p-2.5 rounded-xl bg-[#08201a] border border-emerald-900/50 text-xs text-amber-200/90 font-mono leading-relaxed">
                      <span className="text-[10px] uppercase tracking-wider text-emerald-400/70 block mb-0.5 font-sans">
                        Transliteration
                      </span>
                      {verse.transliteration}
                    </div>
                  )}

                  {/* Translations Container */}
                  <div className="space-y-2 pt-1">
                    {/* English Translation */}
                    {(languageMode === 'en' || languageMode === 'both') && (
                      <div className="p-3 rounded-xl bg-[#071d17] border border-emerald-900/50">
                        <span className="text-[10px] font-mono font-bold text-emerald-400 uppercase tracking-wider block mb-0.5">
                          English (Sahih International)
                        </span>
                        <p className="text-xs text-emerald-100/90 leading-relaxed font-sans">
                          {verse.translationEnglish}
                        </p>
                      </div>
                    )}

                    {/* Bengali Translation */}
                    {(languageMode === 'bn' || languageMode === 'both') && (
                      <div className="p-3 rounded-xl bg-[#09241d] border border-emerald-800/50">
                        <span className="text-[10px] font-mono font-bold text-amber-300 uppercase tracking-wider block mb-0.5">
                          বাংলা অনুবাদ (মুহিউদ্দীন খান ও বায়ান ফাউন্ডেশন)
                        </span>
                        <p className="text-xs text-white leading-relaxed font-sans">
                          {verse.translationBengali}
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* VIEW B: BENGALI MICRO-SUNNAHS & CONTEXTUAL GUIDANCE */}
      {selectedSubTab === 'sunnah_bengali' && (
        <div className="space-y-4">
          <div className="p-4 rounded-2xl bg-[#08221b] border border-emerald-800/50 space-y-1">
            <h3 className="font-serif text-base font-bold text-white flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-amber-400" />
              দৈনিক মাইক্রো-সুন্নাহ ও প্রাসঙ্গিক নির্দেশনা (Bengali Contextual Guidance)
            </h3>
            <p className="text-xs text-emerald-200/80">
              হাদিসের আলোকে দৈনন্দিন সুন্নাহসমূহ এবং এর বৈজ্ঞানিক ও আত্মিক উপকারিতা।
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {sunnahs.map((item) => (
              <div
                key={item.id}
                className={`p-4 rounded-2xl border transition-all ${
                  item.completed
                    ? 'bg-[#0a271f] border-emerald-700/60 shadow-md'
                    : 'bg-[#061814] border-emerald-900/60 hover:border-emerald-700/50'
                }`}
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-start gap-3">
                    <button
                      onClick={() => toggleSunnah(item.id)}
                      className={`mt-1 w-6 h-6 rounded-lg flex items-center justify-center border transition-all ${
                        item.completed
                          ? 'bg-amber-400 border-amber-400 text-black shadow-md'
                          : 'border-emerald-700 bg-emerald-950 hover:border-amber-400'
                      }`}
                    >
                      {item.completed && <Check className="w-4 h-4 stroke-[3]" />}
                    </button>
                    <div>
                      <h4 className="font-semibold text-sm text-white">
                        {item.titleBengali || item.title}
                      </h4>
                      <span className="font-arabic text-xs text-amber-300/80 block mt-0.5">
                        {item.arabicTitle}
                      </span>
                    </div>
                  </div>

                  <span className="px-2 py-0.5 rounded-full bg-amber-500/15 border border-amber-400/30 text-[10px] font-mono text-amber-300 font-bold shrink-0">
                    {item.durationMinutes} মি.
                  </span>
                </div>

                {/* Hadith citation in Bengali */}
                <div className="mt-3 p-2.5 rounded-xl bg-[#030e0b] border border-emerald-950 text-xs space-y-1">
                  <p className="text-emerald-300/90 italic">
                    "{item.hadithReferenceBengali || item.hadithReference}"
                  </p>
                </div>

                {/* Contextual Guidance */}
                <div className="mt-2.5 pt-2 border-t border-emerald-900/40 text-xs text-emerald-200/80 leading-relaxed">
                  <strong className="text-amber-300/90 font-medium block mb-0.5">
                    ব্যবহারিক নির্দেশনা:
                  </strong>
                  {item.contextualGuidanceBengali || item.benefitBengali || item.benefit}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

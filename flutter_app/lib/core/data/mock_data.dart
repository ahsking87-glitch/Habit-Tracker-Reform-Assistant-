import '../models/mizan_models.dart';

final String _todayDate = DateTime.now().toIso8601String().split('T').first;

final List<MicroSunnah> initialMicroSunnahs = [
  MicroSunnah(
    id: 'sunnah-1',
    title: 'Siwak / Oral Purification',
    titleBengali: 'মিসওয়াক ব্যবহার ও মুখ পরিশুদ্ধকরণ',
    arabicTitle: 'السواك مطهرة للفم مرضاة للرب',
    category: 'hygiene',
    durationMinutes: 1,
    hadithReference:
        'Sahih al-Bukhari 887: "Siwak is a purification for the mouth and pleasing to the Lord."',
    hadithReferenceBengali:
        'সহীহ বুখারী ৮৮৭: "মিসওয়াক মুখের পবিত্রতা এবং রবের সন্তুষ্টি অর্জনের মাধ্যম।"',
    completed: true,
    benefit:
        'Revives dental hygiene before prayer and cleanses breath with mindful intention.',
    benefitBengali:
        'নামাজের পূর্বে দাঁতের সুরক্ষা বজায় রাখে এবং সচেতন নিয়তের সাথে মুখ সুবাসিত করে।',
    contextualGuidanceEnglish:
        'Use gentle, horizontal brushstrokes from the right side. Recommended before ablution, prayer, and waking from sleep.',
    contextualGuidanceBengali:
        'ডান দিক থেকে শুরু করে মৃদু ও অনুভূমিকভাবে মিসওয়াক করুন। ওজু, নামাজ এবং ঘুম থেকে ওঠার পর এটি সুন্নাহ।',
    streakDays: 14,
    longestStreak: 19,
    lastCompletedDate: _todayDate,
  ),
  MicroSunnah(
    id: 'sunnah-2',
    title: 'Ayat al-Kursi After Obligatory Prayer',
    titleBengali: 'ফরজ নামাজের পর আয়াতুল কুরসী পাঠ',
    arabicTitle: 'آية الكرسي دبر كل صلاة مكتوبة',
    category: 'prayer',
    durationMinutes: 2,
    hadithReference:
        'Sunan an-Nasa’i 9848: "Whoever recites Ayat al-Kursi after every prescribed prayer, nothing stands between him and Paradise except death."',
    hadithReferenceBengali:
        'সুনান আন-নাসায়ী ৯৮৪৮: "যে ব্যক্তি প্রতি ফরজ নামাজের পর আয়াতুল কুরসী পাঠ করবে, তার জান্নাতে প্রবেশের পথে মৃত্যু ছাড়া আর কোনো বাধা থাকবে না।"',
    completed: true,
    benefit:
        'Anchors spiritual protection and mental stillness immediately following Salah.',
    benefitBengali:
        'নামাজের পরপরই আত্মিক নিরাপত্তা ও গভীর মানসিক প্রশান্তি স্থাপন করে।',
    contextualGuidanceEnglish:
        'Recite calmly before standing up to leave the prayer mat. Contemplate Allah’s absolute sovereignty and knowledge.',
    contextualGuidanceBengali:
        'জায়নামাজ থেকে ওঠার আগে স্থির হৃদয়ে পাঠ করুন। আল্লাহর সার্বভৌমত্ব ও পরম জ্ঞানের ওপর গভীর তাদাব্বুর (চিন্তাভাবনা) করুন।',
    streakDays: 8,
    longestStreak: 12,
    lastCompletedDate: _todayDate,
  ),
  const MicroSunnah(
    id: 'sunnah-3',
    title: 'The Prophetic Smile (Tabassum)',
    titleBengali: 'মুচকি হাসি দিয়ে সাক্ষাৎ (তাবাসসুম)',
    arabicTitle: 'تبسمك في وجه أخيك صدقة',
    category: 'social',
    durationMinutes: 1,
    hadithReference:
        'Jami` at-Tirmidhi 1956: "Your smiling in the face of your brother is charity for you."',
    hadithReferenceBengali:
        'জামে তিরমিযী ১৯৫৬: "তোমার ভাইয়ের মুখের দিকে তাকিয়ে মুচকি হাসাও তোমার জন্য একটি সাদাকাহ।"',
    completed: false,
    benefit:
        'Instantly breaks social anxiety, releases endorphins, and elevates companionship.',
    benefitBengali:
        'সামাজিক জড়তা দূর করে, আত্মিক সৌহার্দ্য সৃষ্টি করে এবং ভালোবাসার বার্তা ছড়ায়।',
    contextualGuidanceEnglish:
        'Give a warm, genuine smile to family members or colleagues upon entering a room.',
    contextualGuidanceBengali:
        'ঘরে বা কর্মক্ষেত্রে প্রবেশের সময় পরিবার ও সহকর্মীদের সাথে আনন্দচিত্তে মুচকি হেসে সালাম দিন।',
    streakDays: 6,
    longestStreak: 10,
  ),
  const MicroSunnah(
    id: 'sunnah-4',
    title: 'The 33 Beads Adhkar (Tasbih, Tahmid, Takbir)',
    titleBengali: '৩৩ বার তাসবীহ, তাহমীদ ও তাকবীর পাঠ',
    arabicTitle: 'التسبيح والتحميد والتكبير ثلاث وثلاثون',
    category: 'prayer',
    durationMinutes: 2,
    hadithReference:
        'Sahih Muslim 597: "SubhanAllah (33x), Al-Hamdulillah (33x), Allahu Akbar (33x), completed with La ilaha illallah."',
    hadithReferenceBengali:
        'সহীহ মুসলিম ৫৯৭: "সুবহানাল্লাহ ৩৩ বার, আলহামদুলিল্লাহ ৩৩ বার, আল্লাহু আকবার ৩৩ বার এবং শেষে কালেমা তায়্যিবা একবার।"',
    completed: false,
    benefit:
        'Neurological grounding through rhythmic breathing and remembrance.',
    benefitBengali:
        'তালবদ্ধ শ্বাস-প্রশ্বাস এবং আল্লাহর জিকিরের মাধ্যমে স্নায়বিক প্রশান্তি লাভ।',
    contextualGuidanceEnglish:
        'Count with the knuckles of your right hand. Focus on meaning of glorification with each breath.',
    contextualGuidanceBengali:
        'ডান হাতের আঙুলের গিঁট দিয়ে গণনা করুন। প্রতিটি তাসবীহের অর্থের গভীরতায় হৃদয় নিমগ্ন করুন।',
    streakDays: 11,
    longestStreak: 15,
  ),
  const MicroSunnah(
    id: 'sunnah-5',
    title: 'Sleep on the Right Side with Wudu',
    titleBengali: 'ওজুসহ ডান কাতে শয়ন করা',
    arabicTitle: 'الاضطجاع على الشق الأيمن على طهارة',
    category: 'night',
    durationMinutes: 2,
    hadithReference:
        'Sahih al-Bukhari 247: "When you go to bed, perform ablution as for prayer, then lie down on your right side."',
    hadithReferenceBengali:
        'সহীহ বুখারী ২৪৭: "যখন তুমি ঘুমাতে যাবে, নামাজের ওজুর ন্যায় ওজু করবে এবং ডান কাতে শোবে।"',
    completed: false,
    benefit:
        'Optimal physiological posture for heart circulation and peaceful sleep transition.',
    benefitBengali:
        'হৃদযন্ত্র ও পরিপাকতন্ত্রের জন্য বৈজ্ঞানিকভাবে প্রমাণিত এবং শান্তিপূর্ণ ঘুমের নিশ্চয়তা।',
    contextualGuidanceEnglish:
        'Place right hand under right cheek and recite the evening protection prayers and Surah Al-Mulk.',
    contextualGuidanceBengali:
        'ডান হাত ডান গালের নিচে রেখে শোবার দোয়া এবং সূরা আল-মুলক পাঠ করে ঘুমান।',
    streakDays: 4,
    longestStreak: 7,
  ),
  const MicroSunnah(
    id: 'sunnah-6',
    title: 'Qaylulah (20-Minute Midday Rest)',
    titleBengali: 'কায়লুলাহ (দুপুরের সামান্য বিশ্রাম)',
    arabicTitle: 'القيلولة فإن الشياطين لا تقيل',
    category: 'morning',
    durationMinutes: 20,
    hadithReference:
        'Al-Mu’jam al-Awsat 28: "Take a midday nap, for the devils do not nap."',
    hadithReferenceBengali:
        'আল-মুজামুল আওসাত ২৮: "তোমরা দুপুরে কিছুটা সময় কায়লুলাহ (বিশ্রাম) নাও, কারণ শয়তানরা বিশ্রাম নেয় না।"',
    completed: false,
    benefit:
        'Circadian neuro-restoration that restores cognitive bandwidth for afternoon work.',
    benefitBengali:
        'দুপুরবেলার ক্লান্তি কাটিয়ে অপরাহ্নের জন্য স্নায়ুবিক শক্তি পুনরুজ্জীবিত করে।',
    contextualGuidanceEnglish:
        'Keep between 15-25 minutes before or after Dhuhr to prevent sleep inertia.',
    contextualGuidanceBengali:
        'জোহরের নামাজের আগে বা পরে ১৫-২৫ মিনিটের হালকা তন্দ্রা নিন, যেন আলস্য না আসে।',
    streakDays: 2,
    longestStreak: 5,
  ),
];

const List<MilestoneBadge> initialMilestoneBadges = [
  MilestoneBadge(
    id: 'badge-bidayah',
    name: 'Bidayah (The Beginning)',
    arabicName: 'بداية مباركة',
    description:
        'Maintained consistency for 3 consecutive days. The journey of Istiqamah commences.',
    icon: 'Moon',
    tier: 'bronze',
    requiredDays: 3,
    unlocked: true,
    unlockedAt: '4 days ago',
    virtueQuote: 'Small, repeated actions shape the vessel of character.',
    hadithReference:
        'Sahih al-Bukhari 6464: "The deeds most loved by Allah are those done regularly, even if small."',
  ),
  MilestoneBadge(
    id: 'badge-istiqamah',
    name: 'Sahib al-Istiqamah',
    arabicName: 'صاحب الاستقامة',
    description:
        'Achieved a 7-day unbroken habit cycle. Neural pathways of discipline are solidifying.',
    icon: 'Sparkles',
    tier: 'silver',
    requiredDays: 7,
    unlocked: true,
    unlockedAt: 'Yesterday',
    virtueQuote:
        'Steadfastness in small routines produces monumental inner tranquility.',
    hadithReference:
        'Sahih Muslim 38: "Say: I believe in Allah, and then remain steadfast."',
  ),
  MilestoneBadge(
    id: 'badge-noor-fajr',
    name: 'Noor al-Fajr (Dawn Light)',
    arabicName: 'نور الفجر',
    description:
        'Conquered 14 consecutive mornings of Fajr anchor & morning Sunnahs.',
    icon: 'Sun',
    tier: 'silver',
    requiredDays: 14,
    unlocked: true,
    unlockedAt: 'Today',
    virtueQuote: 'He who conquers his morning conquers the day with Barakah.',
    hadithReference:
        'Sunan Abi Dawud 561: "Give glad tidings of complete light on the Day of Resurrection."',
  ),
  MilestoneBadge(
    id: 'badge-taqwa-shield',
    name: 'Shield of Taqwa',
    arabicName: 'درع التقوى',
    description:
        'Maintained 21 days within healthy digital boundaries and short-form video freedom.',
    icon: 'Shield',
    tier: 'gold',
    requiredDays: 21,
    unlocked: false,
    virtueQuote:
        'True freedom is mastery over what captures your gaze and attention.',
    hadithReference:
        'Sahih al-Bukhari 6114: "The strong believer is the one who controls himself during impulses."',
  ),
  MilestoneBadge(
    id: 'badge-ar-rukn',
    name: 'Ar-Rukn (The Pillar)',
    arabicName: 'الركن الركين',
    description:
        'Completed 30 days of consistent Quran reflection and micro-Sunnahs.',
    icon: 'Flame',
    tier: 'gold',
    requiredDays: 30,
    unlocked: false,
    virtueQuote:
        'A whole month of spiritual anchor: the habit is now part of your identity.',
    hadithReference:
        'Al-Adab al-Mufrad: "Steadfastness over a month purifies the intention and stabilizes the heart."',
  ),
  MilestoneBadge(
    id: 'badge-mizan-dhahabi',
    name: 'Al-Mīzān Al-Dhahabi',
    arabicName: 'الميزان الذهبي',
    description:
        'The Golden 40 Days: Full circadian harmony, Salah lock presence, and digital balance.',
    icon: 'Crown',
    tier: 'emerald',
    requiredDays: 40,
    unlocked: false,
    virtueQuote: 'Forty days transforms a practice into spiritual second nature.',
    hadithReference:
        'Jami` at-Tirmidhi 241: "Whoever perseveres for forty days... shall be recorded free of duplicity."',
  ),
];

const List<CircadianBlock> initialCircadianBlocks = [
  CircadianBlock(
    id: 'circ-1',
    title: 'Qiyam al-Layl & Suhur Window',
    category: 'spiritual',
    startHour: 4,
    endHour: 5,
    colorHex: 0xFF3B82F6,
    sunnahAnchor: 'Last third of the night—intimate Dua and Tahajjud.',
    description:
        'Pre-dawn tranquility when cognitive clarity is at its highest spiritual peak.',
  ),
  CircadianBlock(
    id: 'circ-2',
    title: 'Fajr & Barakah Dawn Sprint',
    category: 'spiritual',
    startHour: 5,
    endHour: 7,
    colorHex: 0xFFF59E0B,
    sunnahAnchor: '"O Allah, bless my Ummah in their early mornings." (Tirmidhi)',
    description:
        'Reciting Quran, morning Adhkar, and light stretching. Zero screens or notifications.',
  ),
  CircadianBlock(
    id: 'circ-3',
    title: 'Deep Work Sprint I (High Cognitive Load)',
    category: 'deep_work',
    startHour: 8,
    endHour: 12,
    colorHex: 0xFF10B981,
    sunnahAnchor: 'Working with Ihsan (mastery and supreme conscientiousness).',
    description:
        'Complex problem solving, coding, writing. High phone friction enabled.',
  ),
  CircadianBlock(
    id: 'circ-4',
    title: 'Dhuhr Prayer & Qaylulah (Power Nap)',
    category: 'sleep',
    startHour: 12.5,
    endHour: 14,
    colorHex: 0xFF06B6D4,
    sunnahAnchor:
        'Congregational Dhuhr followed by 20-min sunnah restorative nap.',
    description: 'Physical reboot preventing afternoon burnout.',
  ),
  CircadianBlock(
    id: 'circ-5',
    title: 'Deep Work Sprint II & Collaboration',
    category: 'light_work',
    startHour: 14,
    endHour: 16.5,
    colorHex: 0xFF14B8A6,
    sunnahAnchor: 'Delivering promises and completing contracts before sunset.',
    description: 'Meetings, execution, administrative closure before Asr.',
  ),
  CircadianBlock(
    id: 'circ-6',
    title: 'Asr, Kinship & Nature Walk',
    category: 'family',
    startHour: 16.5,
    endHour: 18,
    colorHex: 0xFFD97706,
    sunnahAnchor:
        'Preserving the Middle Prayer (Salat al-Wusta) & visiting family.',
    description:
        'Time outside in daylight, physical movement, evening remembrance.',
  ),
  CircadianBlock(
    id: 'circ-7',
    title: 'Maghrib, Dinner & Halal Leisure',
    category: 'halal_leisure',
    startHour: 18,
    endHour: 20.5,
    colorHex: 0xFF8B5CF6,
    sunnahAnchor:
        'Communal warm meal with gratitude, uplifting books, family play.',
    description: 'Guilt-free relaxation, hobbies, and mindful entertainment.',
  ),
  CircadianBlock(
    id: 'circ-8',
    title: 'Isha & Melatonin Winddown',
    category: 'sleep',
    startHour: 20.5,
    endHour: 23,
    colorHex: 0xFF6366F1,
    sunnahAnchor: 'Disliking conversation after Isha prayer; Surah Al-Mulk.',
    description: 'All devices outside bedroom. Dim amber lighting and wudu.',
  ),
];

const List<PeerAccountabilityNode> initialPeerNodes = [
  PeerAccountabilityNode(
    id: 'peer-1',
    alias: 'Zayd M.',
    avatarSeed: 'Zayd',
    streakDays: 42,
    lastSyncTimestamp: '12 mins ago',
    cryptographicSignature: 'ed25519_sig:9f83a04b12c8e76da41793bf0...',
    status: 'synced',
    encouragementSent: false,
  ),
  PeerAccountabilityNode(
    id: 'peer-2',
    alias: 'Maryam K.',
    avatarSeed: 'Maryam',
    streakDays: 29,
    lastSyncTimestamp: '35 mins ago',
    cryptographicSignature: 'ed25519_sig:3e117b889ac44ff1289de61...',
    status: 'active',
    encouragementSent: true,
  ),
  PeerAccountabilityNode(
    id: 'peer-3',
    alias: 'Bilal R.',
    avatarSeed: 'Bilal',
    streakDays: 14,
    lastSyncTimestamp: '2 hours ago',
    cryptographicSignature: 'ed25519_sig:a72e81699f012bce1583002...',
    status: 'active',
    encouragementSent: false,
  ),
];

const List<AIProviderMeta> aiProvidersCatalog = [
  AIProviderMeta(
    id: AIProviderId.gemini,
    name: 'Google Gemini',
    providerCompany: 'Google DeepMind',
    defaultModel: 'gemini-3.8-flash',
    availableModels: ['gemini-3.8-flash', 'gemini-2.5-pro', 'gemini-2.0-flash'],
    endpointUrl: 'https://generativelanguage.googleapis.com/v1beta/models',
    description:
        'Fast, highly capable multimodal model with strong multilingual fluency in Arabic and Bengali.',
    icon: '✨',
    requiresKey: true,
    keyPlaceholder: 'AIzaSy...',
    supportsStreaming: true,
    supportsJsonMode: true,
  ),
  AIProviderMeta(
    id: AIProviderId.openai,
    name: 'OpenAI ChatGPT',
    providerCompany: 'OpenAI',
    defaultModel: 'gpt-4o',
    availableModels: ['gpt-4o', 'gpt-4o-mini', 'o3-mini'],
    endpointUrl: 'https://api.openai.com/v1/chat/completions',
    description:
        'Flagship reasoning model with high empathy, structured JSON output, and rapid execution.',
    icon: '🟢',
    requiresKey: true,
    keyPlaceholder: 'sk-proj-...',
    supportsStreaming: true,
    supportsJsonMode: true,
  ),
  AIProviderMeta(
    id: AIProviderId.anthropic,
    name: 'Anthropic Claude',
    providerCompany: 'Anthropic',
    defaultModel: 'claude-3-5-sonnet-20241022',
    availableModels: [
      'claude-3-5-sonnet-20241022',
      'claude-3-5-haiku-20241022',
      'claude-3-7-sonnet-latest',
    ],
    endpointUrl: 'https://api.anthropic.com/v1/messages',
    description:
        'Constitutional AI architecture with deep nuance, ethical self-reflection, and clear prose.',
    icon: '🟠',
    requiresKey: true,
    keyPlaceholder: 'sk-ant-api03-...',
    supportsStreaming: true,
    supportsJsonMode: false,
  ),
  AIProviderMeta(
    id: AIProviderId.deepseek,
    name: 'DeepSeek AI',
    providerCompany: 'DeepSeek',
    defaultModel: 'deepseek-chat',
    availableModels: ['deepseek-chat', 'deepseek-reasoner'],
    endpointUrl: 'https://api.deepseek.com/chat/completions',
    description:
        'Cost-efficient, powerful open-weights model with excellent logical chain-of-thought.',
    icon: '🔵',
    requiresKey: true,
    keyPlaceholder: 'sk-...',
    supportsStreaming: true,
    supportsJsonMode: true,
  ),
  AIProviderMeta(
    id: AIProviderId.offline,
    name: 'Local Offline Hadith Matrix',
    providerCompany: 'Mīzān Sovereign Core',
    defaultModel: 'embedded-canonical-db',
    availableModels: ['embedded-canonical-db'],
    endpointUrl: 'local://sqlite-memory',
    description:
        '100% private, zero-latency local matrix containing verified Quranic verses and Sahih Hadiths.',
    icon: '🛡️',
    requiresKey: false,
    keyPlaceholder: 'No key needed (100% offline)',
    supportsStreaming: false,
    supportsJsonMode: true,
  ),
];

class AvatarOption {
  final String id;
  final String icon;
  final String label;
  final String desc;
  const AvatarOption(this.id, this.icon, this.label, this.desc);
}

const List<AvatarOption> avatarEmblemOptions = [
  AvatarOption('crescent', '🌙', 'Al-Hilal', 'Crescent light of guidance'),
  AvatarOption('mosque', '🕌', 'Al-Masjid', 'Sanctuary of steadfastness'),
  AvatarOption('lantern', '🏮', 'Al-Misbah', 'Illuminated heart & knowledge'),
  AvatarOption('compass', '🧭', 'Al-Qiblah', 'Focused direction & balance'),
  AvatarOption('quran', '📖', 'Al-Furqan', 'Wisdom of eternal revelation'),
  AvatarOption('olive', '🌿', 'Az-Zaytun', 'Blessed growth & vitality'),
];

List<PersonalGoal> buildStarterPersonalGoals() {
  final now = DateTime.now();
  final today = now.toIso8601String().split('T').first;
  final yesterday =
      now.subtract(const Duration(days: 1)).toIso8601String().split('T').first;
  final twoDaysAgo =
      now.subtract(const Duration(days: 2)).toIso8601String().split('T').first;
  final nextWeek =
      now.add(const Duration(days: 10)).toIso8601String().split('T').first;
  final stamp = now.toIso8601String();

  return [
    PersonalGoal(
      id: 'goal-quran-hifz',
      title: 'Tadabbur & Memorization: Surah Al-Mulk',
      description:
          'Read with Bengali/English meaning and memorize 3 Ayahs each night before sleep.',
      category: GoalCategory.spiritual,
      targetUnits: 30,
      completedUnits: 12,
      unitLabel: 'ayahs',
      cadence: GoalCadence.daily,
      scheduledSlot: 'After Isha',
      scheduledTime: '21:15',
      scheduledDays: const [1, 2, 3, 4, 5, 6, 7],
      targetDate: nextWeek,
      reminderEnabled: true,
      completedLogs: [twoDaysAgo, yesterday, today],
      createdAt: stamp,
      updatedAt: stamp,
    ),
    PersonalGoal(
      id: 'goal-flutter-learning',
      title: 'Deep Learning: Offline-First Systems & Riverpod',
      description:
          'Complete focused hands-on architecture modules during peak morning Barakah hours.',
      category: GoalCategory.learning,
      targetUnits: 12,
      completedUnits: 7,
      unitLabel: 'modules',
      cadence: GoalCadence.weekdays,
      scheduledSlot: 'Morning Sprint',
      scheduledTime: '08:30',
      scheduledDays: const [1, 2, 3, 4, 5],
      targetDate: nextWeek,
      reminderEnabled: true,
      completedLogs: [twoDaysAgo, yesterday],
      createdAt: stamp,
      updatedAt: stamp,
    ),
    PersonalGoal(
      id: 'goal-evening-walk',
      title: 'Asr Horizon Walk & Screen-Free Decompression',
      description:
          'Step outside without short-form video feeds for 20 minutes of daylight movement.',
      category: GoalCategory.wellness,
      targetUnits: 7,
      completedUnits: 4,
      unitLabel: 'walks',
      cadence: GoalCadence.daily,
      scheduledSlot: 'After Asr',
      scheduledTime: '17:00',
      scheduledDays: const [1, 2, 3, 4, 5, 6, 7],
      reminderEnabled: false,
      completedLogs: [yesterday],
      createdAt: stamp,
      updatedAt: stamp,
    ),
    PersonalGoal(
      id: 'goal-weekly-review',
      title: 'Weekly Task & Niyyah Alignment Audit',
      description:
          'Declutter inbox, organize priority tasks, and renew weekly intentions.',
      category: GoalCategory.task,
      targetUnits: 4,
      completedUnits: 2,
      unitLabel: 'checkpoints',
      cadence: GoalCadence.customDays,
      scheduledSlot: 'After Dhuhr',
      scheduledTime: '14:00',
      scheduledDays: const [1, 4],
      reminderEnabled: true,
      completedLogs: [twoDaysAgo],
      createdAt: stamp,
      updatedAt: stamp,
    ),
  ];
}


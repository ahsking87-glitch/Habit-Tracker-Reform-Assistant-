import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/quran_multilingual_data.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class MultilingualQuranScreen extends ConsumerStatefulWidget {
  const MultilingualQuranScreen({super.key});

  @override
  ConsumerState<MultilingualQuranScreen> createState() =>
      _MultilingualQuranScreenState();
}

class _MultilingualQuranScreenState
    extends ConsumerState<MultilingualQuranScreen> {
  String _mode = 'quran'; // 'quran' | 'sunnah'
  String _langMode = 'both'; // 'en' | 'bn' | 'both'
  bool _showTranslit = true;
  int _selectedSurah = 1;
  String _searchQuery = '';
  final Set<String> _bookmarkedIds = {'1:1', '2:255'};

  @override
  Widget build(BuildContext context) {
    final streaks = ref.watch(streaksProvider);

    final filteredVerses = quranVerses.where((v) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return v.translationEnglish.toLowerCase().contains(q) ||
            v.translationBengali.toLowerCase().contains(q) ||
            v.textArabic.contains(_searchQuery) ||
            v.surahNameEnglish.toLowerCase().contains(q);
      }
      return v.surahNumber == _selectedSurah;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + Mode Switcher
        MizanCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final titleRow = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MizanColors.amber500.withAlpha(38),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: MizanColors.amber400.withAlpha(115)),
                    ),
                    child: const Icon(LucideIcons.bookOpen,
                        size: 24, color: MizanColors.amber300),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Holy Quran & Prophetic Sunnah (বাংলা / EN)',
                          style: MizanTypography.title(
                              fontSize: 19, color: Colors.white),
                        ),
                        Text(
                          'Sub-10ms Offline SQLite FTS5 Search · Uthmani Arabic · Sahih Intl & বায়ান ফাউন্ডেশন',
                          style: MizanTypography.body(
                              fontSize: 12, color: MizanColors.emerald300),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final switcher = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    selected: _mode == 'quran',
                    selectedColor: MizanColors.amber500,
                    backgroundColor: MizanColors.bgCardAlt,
                    label: Text(
                      'Holy Quran',
                      style: MizanTypography.body(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _mode == 'quran' ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _mode = 'quran'),
                  ),
                  ChoiceChip(
                    selected: _mode == 'sunnah',
                    selectedColor: MizanColors.emerald500,
                    backgroundColor: MizanColors.bgCardAlt,
                    label: Text(
                      'বাংলা সুন্নাহ (Micro-Sunnahs)',
                      style: MizanTypography.body(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _mode == 'sunnah' ? Colors.black : Colors.white,
                      ),
                    ),
                    onSelected: (_) => setState(() => _mode = 'sunnah'),
                  ),
                ],
              );

              if (wide) {
                return Row(
                  children: [
                    Expanded(child: titleRow),
                    const SizedBox(width: 12),
                    switcher,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleRow,
                  const SizedBox(height: 12),
                  switcher,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Toolbar Filters
        MizanCard(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final searchWidth = constraints.maxWidth >= 640
                  ? (constraints.maxWidth * 0.4).clamp(260.0, 380.0)
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: searchWidth,
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: MizanTypography.body(
                          fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(LucideIcons.search,
                            size: 15, color: MizanColors.emerald400),
                        hintText: 'Search Ayah in EN / বাংলা / Arabic...',
                        hintStyle: MizanTypography.body(
                            fontSize: 11.5, color: MizanColors.slate500),
                        isDense: true,
                        filled: true,
                        fillColor: MizanColors.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: MizanColors.borderSubtle),
                        ),
                      ),
                    ),
                  ),
              Wrap(
                spacing: 6,
                children: [
                  for (final opt in [
                    ('en', 'English'),
                    ('bn', 'বাংলা'),
                    ('both', 'EN + বাংলা')
                  ])
                    ChoiceChip(
                      selected: _langMode == opt.$1,
                      selectedColor: MizanColors.amber400,
                      backgroundColor: MizanColors.bgInput,
                      label: Text(
                        opt.$2,
                        style: MizanTypography.body(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _langMode == opt.$1
                              ? Colors.black
                              : MizanColors.slate200,
                        ),
                      ),
                      onSelected: (_) => setState(() => _langMode = opt.$1),
                    ),
                  FilterChip(
                    selected: _showTranslit,
                    selectedColor: MizanColors.emerald800,
                    backgroundColor: MizanColors.bgInput,
                    label: Text(
                      'Transliteration',
                      style: MizanTypography.body(
                          fontSize: 11, color: Colors.white),
                    ),
                    onSelected: (v) => setState(() => _showTranslit = v),
                  ),
                ],
              ),
            ],
          );
            },
          ),
        ),
        const SizedBox(height: 16),

        if (_mode == 'quran') ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: surahList.map((s) {
              final active = s.number == _selectedSurah;
              return ChoiceChip(
                selected: active,
                selectedColor: MizanColors.amber500,
                backgroundColor: MizanColors.bgCard,
                label: Text(
                  '${s.number}. ${s.nameEnglish} (${s.nameBengali})',
                  style: MizanTypography.body(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.black : Colors.white,
                  ),
                ),
                onSelected: (_) => setState(() {
                  _selectedSurah = s.number;
                  _searchQuery = '';
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          ...filteredVerses.map((v) {
            final bookmarked = _bookmarkedIds.contains(v.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: MizanCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MizanBadge(
                          label:
                              'Surah ${v.surahNameEnglish} · ${v.id} · Juz ${v.juzNumber}',
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (bookmarked) {
                                _bookmarkedIds.remove(v.id);
                              } else {
                                _bookmarkedIds.add(v.id);
                              }
                            });
                          },
                          icon: Icon(
                            LucideIcons.bookmark,
                            size: 18,
                            color: bookmarked
                                ? MizanColors.amber400
                                : MizanColors.slate500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      v.textArabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: MizanTypography.arabic(
                        fontSize: 24,
                        color: MizanColors.amber300,
                      ),
                    ),
                    if (_showTranslit) ...[
                      const SizedBox(height: 8),
                      Text(
                        _langMode == 'bn'
                            ? v.transliterationBengali
                            : v.transliteration,
                        style: MizanTypography.body(
                          fontSize: 12,
                          color: MizanColors.slate400,
                        ),
                      ),
                    ],
                    if (_langMode == 'en' || _langMode == 'both') ...[
                      const SizedBox(height: 8),
                      Text(
                        v.translationEnglish,
                        style: MizanTypography.body(
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (_langMode == 'bn' || _langMode == 'both') ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: MizanColors.bgCardAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: MizanColors.borderSubtle),
                        ),
                        child: Text(
                          v.translationBengali,
                          style: MizanTypography.body(
                            fontSize: 13,
                            color: MizanColors.emerald300,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ] else ...[
          // বাংলা সুন্নাহ Micro-Sunnahs Guidance View
          ...streaks.sunnahs.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: MizanCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: MizanTypography.title(
                                    fontSize: 16, color: Colors.white),
                              ),
                              if (s.titleBengali != null)
                                Text(
                                  s.titleBengali!,
                                  style: MizanTypography.body(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: MizanColors.emerald300,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref
                              .read(streaksProvider.notifier)
                              .toggleHabit(s.id),
                          icon: Icon(
                            s.completed
                                ? LucideIcons.checkCircle2
                                : LucideIcons.circle,
                            color: s.completed
                                ? MizanColors.emerald400
                                : MizanColors.slate400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.arabicTitle,
                      textDirection: TextDirection.rtl,
                      style: MizanTypography.arabic(
                        fontSize: 19,
                        color: MizanColors.amber300,
                      ),
                    ),
                    if (_langMode != 'bn') ...[
                      const SizedBox(height: 6),
                      Text(
                        s.hadithReference,
                        style: MizanTypography.body(
                            fontSize: 12, color: MizanColors.slate200),
                      ),
                    ],
                    if ((_langMode == 'bn' || _langMode == 'both') &&
                        s.hadithReferenceBengali != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        s.hadithReferenceBengali!,
                        style: MizanTypography.body(
                            fontSize: 12, color: MizanColors.emerald300),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/codebase_archive_data.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class ArchitectureExplorerScreen extends ConsumerStatefulWidget {
  const ArchitectureExplorerScreen({super.key});

  @override
  ConsumerState<ArchitectureExplorerScreen> createState() =>
      _ArchitectureExplorerScreenState();
}

class _ArchitectureExplorerScreenState
    extends ConsumerState<ArchitectureExplorerScreen> {
  String _search = '';
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    final selectedPath = ref.watch(explorerSelectedFileProvider) ??
        flutterCodebaseArchive.first.path;

    final filtered = flutterCodebaseArchive.where((f) {
      final matchesCat = _category == 'all' || f.category == _category;
      final q = _search.trim().toLowerCase();
      final matchesQ = q.isEmpty ||
          f.name.toLowerCase().contains(q) ||
          f.path.toLowerCase().contains(q) ||
          f.description.toLowerCase().contains(q);
      return matchesCat && matchesQ;
    }).toList();

    final CodeFileItem activeFile = flutterCodebaseArchive.firstWhere(
      (f) => f.path == selectedPath,
      orElse: () => filtered.isNotEmpty
          ? filtered.first
          : flutterCodebaseArchive.first,
    );

    final lines = activeFile.content.split('\n');
    final screenHeight = MediaQuery.of(context).size.height;
    final fileListHeight = (screenHeight * 0.44).clamp(240.0, 520.0);
    final codeViewerHeight = (screenHeight * 0.52).clamp(280.0, 620.0);

    final sidebar = MizanCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            style: MizanTypography.body(fontSize: 12, color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.search,
                  size: 14, color: MizanColors.emerald400),
              hintText: 'Filter Dart / Kotlin / Swift files...',
              hintStyle: MizanTypography.body(
                  fontSize: 11, color: MizanColors.slate500),
              isDense: true,
              filled: true,
              fillColor: MizanColors.bgInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MizanColors.borderSubtle),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final cat in [
                ('all', 'All (${flutterCodebaseArchive.length})'),
                ('flutter_core', 'Flutter / Dart'),
                ('android_native', 'Android Kotlin'),
                ('ios_native', 'iOS Swift'),
                ('architecture_docs', 'Policies'),
              ])
                ChoiceChip(
                  selected: _category == cat.$1,
                  selectedColor: MizanColors.amber500,
                  backgroundColor: MizanColors.bgInput,
                  label: Text(
                    cat.$2,
                    style: MizanTypography.body(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color:
                          _category == cat.$1 ? Colors.black : Colors.white,
                    ),
                  ),
                  onSelected: (_) => setState(() => _category = cat.$1),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: fileListHeight,
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, idx) {
                final f = filtered[idx];
                final active = f.path == activeFile.path;
                return InkWell(
                  onTap: () => ref
                      .read(explorerSelectedFileProvider.notifier)
                      .state = f.path,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF0A2E25)
                          : MizanColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? MizanColors.amber400
                            : MizanColors.borderSubtle,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                f.name,
                                overflow: TextOverflow.ellipsis,
                                style: MizanTypography.code(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: active
                                      ? MizanColors.amber300
                                      : Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              f.language.toUpperCase(),
                              style: MizanTypography.code(
                                fontSize: 9,
                                color: MizanColors.emerald400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          f.path,
                          overflow: TextOverflow.ellipsis,
                          style: MizanTypography.code(
                            fontSize: 9,
                            color: MizanColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    final codePane = MizanCard(
      padding: const EdgeInsets.all(16),
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
                      activeFile.path,
                      style: MizanTypography.code(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: MizanColors.amber300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeFile.description,
                      style: MizanTypography.body(
                          fontSize: 12, color: MizanColors.slate300),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MizanColors.emerald900,
                  foregroundColor: MizanColors.emerald300,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: activeFile.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: MizanColors.emerald900,
                      content: Text('Copied ${activeFile.name} to clipboard.'),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.copy, size: 14),
                label: const Text('Copy'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: codeViewerHeight,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MizanColors.bgInput,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MizanColors.borderSubtle),
            ),
            child: ListView.builder(
              itemCount: lines.length,
              itemBuilder: (_, idx) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${idx + 1}',
                      style: MizanTypography.code(
                        fontSize: 11,
                        color: MizanColors.slate600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lines[idx],
                      style: MizanTypography.code(
                        fontSize: 11.5,
                        color: MizanColors.emerald300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 900) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: sidebar),
            const SizedBox(width: 18),
            Expanded(flex: 8, child: codePane),
          ],
        );
      }
      return Column(
        children: [
          sidebar,
          const SizedBox(height: 18),
          codePane,
        ],
      );
    });
  }
}

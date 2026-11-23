import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class SystemArchitectureDiagramScreen extends ConsumerWidget {
  const SystemArchitectureDiagramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layers = [
      (
        num: 'LAYER 01',
        title: 'Presentation & Bounded Floating Assistant Layer',
        subtitle:
            'Flutter Material 3 + Riverpod Reactive UI + Bounded Nūr System Overlay',
        color: MizanColors.amber400,
        icon: LucideIcons.smartphone,
        files: [
          'lib/features/companion/presentation/widgets/floating_companion_overlay.dart',
          'lib/features/agent/presentation/screens/holistic_ai_agent_screen.dart',
        ],
      ),
      (
        num: 'LAYER 02',
        title: 'Multi-AI BYOK Gateway & Offline Matrix Router',
        subtitle:
            'Routes coaching prompts across Gemini, OpenAI, Claude, DeepSeek or deterministic SQLite fallback',
        color: MizanColors.emerald400,
        icon: LucideIcons.cpu,
        files: ['lib/core/services/ai_gateway_service.dart'],
      ),
      (
        num: 'LAYER 03',
        title: 'Offline Astronomical & Scriptural Domain Core',
        subtitle:
            'Batoul Adhan solar equations, Qibla bearing calculator, Trilingual SQLite FTS5 Quran',
        color: MizanColors.cyan400,
        icon: LucideIcons.compass,
        files: [
          'lib/core/services/adhan_prayer_service.dart',
          'lib/features/quran/presentation/screens/multilingual_quran_screen.dart',
        ],
      ),
      (
        num: 'LAYER 04',
        title: 'Android Accessibility & WindowManager Bridge',
        subtitle:
            'Local-only Reels/Shorts view ID detector + non-coercive 7s pause overlay',
        color: MizanColors.sky400,
        icon: LucideIcons.shieldCheck,
        files: [
          'android/app/src/main/kotlin/com/mizan/app/ShortsBlockerAccessibilityService.kt',
          'android/app/src/main/kotlin/com/mizan/app/FocusOverlayService.kt',
          'android/app/src/main/kotlin/com/mizan/app/FloatingCompanionOverlayService.kt',
        ],
      ),
      (
        num: 'LAYER 05',
        title: 'iOS FamilyControls & ManagedSettings Shield',
        subtitle:
            'Zero-battery DeviceActivity scheduling & ShieldConfigurationExtension',
        color: MizanColors.violet400,
        icon: LucideIcons.lock,
        files: [
          'ios/Runner/ScreenTimeBridge.swift',
          'ios/ShieldExtension/ShieldConfigurationExtension.swift',
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOVEREIGN CROSS-PLATFORM TOPOLOGY',
                style: MizanTypography.code(
                    fontSize: 10.5, color: MizanColors.amber300),
              ),
              const SizedBox(height: 4),
              Text(
                '5-Layer Offline-First Flutter & Native OS Architecture',
                style: MizanTypography.title(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap any file pill inside a layer below to inspect its exact production implementation in Source Code Explorer.',
                style: MizanTypography.body(
                    fontSize: 12.5, color: MizanColors.slate300),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...layers.map((layer) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: MizanCard(
              borderColor: layer.color.withAlpha(115),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: layer.color.withAlpha(38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(layer.icon, size: 20, color: layer.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              layer.num,
                              style: MizanTypography.code(
                                  fontSize: 10, color: layer.color),
                            ),
                            Text(
                              layer.title,
                              style: MizanTypography.title(
                                  fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              layer.subtitle,
                              style: MizanTypography.body(
                                  fontSize: 12, color: MizanColors.slate300),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: layer.files.map((path) {
                      final shortName = path.split('/').last;
                      return OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: MizanColors.bgInput,
                          side: BorderSide(color: layer.color.withAlpha(128)),
                        ),
                        onPressed: () => jumpToSourceFile(ref, path),
                        icon: Icon(LucideIcons.code2,
                            size: 13, color: layer.color),
                        label: Text(
                          shortName,
                          style: MizanTypography.code(
                              fontSize: 11, color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

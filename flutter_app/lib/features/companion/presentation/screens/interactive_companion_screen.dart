import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/models/mizan_models.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';
import '../widgets/floating_companion_overlay.dart';

class InteractiveCompanionScreen extends ConsumerWidget {
  const InteractiveCompanionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comp = ref.watch(companionProvider);
    final notifier = ref.read(companionProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header Card
        MizanCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MizanColors.amber500.withAlpha(38),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: MizanColors.amber400.withAlpha(115)),
                ),
                child: const Icon(LucideIcons.sparkles,
                    size: 26, color: MizanColors.amber300),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bounded Floating AI Companion • نور (Nūr)',
                      style: MizanTypography.title(
                          fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Persistent, hoverable system-level assistant with edge-snapping physics, Peek-a-Boo tuck, and 7 speech-free harmonic acoustic chimes.',
                      style: MizanTypography.body(
                          fontSize: 12.5, color: MizanColors.slate300),
                    ),
                  ],
                ),
              ),
              Switch(
                value: comp.isEnabled,
                activeColor: MizanColors.emerald400,
                onChanged: notifier.setEnabled,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 860;
          final stage = _buildWorkbenchStage(context, comp, notifier);
          final controls = _buildControlsPanel(ref, comp, notifier);
          return wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: stage),
                    const SizedBox(width: 18),
                    Expanded(flex: 6, child: controls),
                  ],
                )
              : Column(
                  children: [
                    stage,
                    const SizedBox(height: 18),
                    controls,
                  ],
                );
        }),
      ],
    );
  }

  Widget _buildWorkbenchStage(
    BuildContext context,
    CompanionState comp,
    CompanionNotifier notifier,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final stageHeight = (screenHeight * 0.44).clamp(280.0, 440.0);

    return MizanCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Interactive Floating Sandbox',
                  overflow: TextOverflow.ellipsis,
                  style:
                      MizanTypography.title(fontSize: 15, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              MizanBadge(
                label: 'Mood: ${comp.mood.name.toUpperCase()}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: stageHeight,
            decoration: BoxDecoration(
              color: MizanColors.bgInput,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: MizanColors.borderEmerald),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.move,
                            size: 28, color: MizanColors.emerald800),
                        const SizedBox(height: 8),
                        Text(
                          'Drag Nūr across edges · Tap for Water-Drop Chime',
                          textAlign: TextAlign.center,
                          style: MizanTypography.body(
                            fontSize: 11.5,
                            color: MizanColors.slate400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Last Chime: ${comp.lastSoundLabel}',
                          textAlign: TextAlign.center,
                          style: MizanTypography.code(
                            fontSize: 10.5,
                            color: MizanColors.amber300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: FloatingCompanionOverlay(
                    nextSalahName: 'Asr',
                    nextSalahMinutes: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'BOUNDED OVERLAY SKINS',
            style: MizanTypography.code(
                fontSize: 10.5, color: MizanColors.amber300),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
            children: [
              (CompanionSkin.lantern, '🏮', 'Celestial Lantern'),
              (CompanionSkin.crescent, '🌙', 'Hilal Crescent'),
              (CompanionSkin.astrolabe, '۞', 'Golden Astrolabe'),
              (CompanionSkin.lotus, '🪷', 'Sacred Lotus'),
            ].map((item) {
              final selected = comp.skin == item.$1;
              return InkWell(
                onTap: () => notifier.setSkin(item.$1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF0A2E25)
                        : MizanColors.bgCardAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? MizanColors.amber400
                          : MizanColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(item.$2, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.$3,
                          overflow: TextOverflow.ellipsis,
                          style: MizanTypography.body(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(
      WidgetRef ref, CompanionState comp, CompanionNotifier notifier) {
    final tones = [
      (SoundEffectType.salahBell, '🔔 432Hz Salah Bell', MizanColors.amber400),
      (
        SoundEffectType.attentionChime,
        '🛡️ Screen Budget Chime',
        MizanColors.rose400
      ),
      (
        SoundEffectType.celebrationHarp,
        '✨ Habit Celebration Harp',
        MizanColors.emerald400
      ),
      (
        SoundEffectType.peekGlissando,
        '👁️ Peek-a-Boo Glissando',
        MizanColors.sky400
      ),
      (SoundEffectType.waterDrop, '💧 Water-Drop Touch', MizanColors.cyan400),
      (
        SoundEffectType.restingHum,
        '🌙 Harmonic Resting Hum',
        MizanColors.amber300
      ),
      (
        SoundEffectType.marimbaTick,
        '🪵 Soft Marimba Tick',
        MizanColors.violet400
      ),
    ];

    return MizanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Non-Verbal Acoustic Soundboard (Zero Speech)',
                  style:
                      MizanTypography.title(fontSize: 15, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: comp.soundEnabled,
                activeColor: MizanColors.emerald400,
                onChanged: notifier.setSoundEnabled,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tones.map((t) {
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: MizanColors.bgCardAlt,
                  side: BorderSide(color: t.$3.withAlpha(128)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => notifier.previewSound(t.$1, t.$2),
                child: Text(
                  t.$2,
                  style: MizanTypography.body(
                      fontSize: 11.5, color: Colors.white),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Chime Volume (${(comp.soundVolume * 100).round()}%)',
            style: MizanTypography.body(
                fontSize: 12, color: MizanColors.slate200),
          ),
          Slider(
            value: comp.soundVolume,
            min: 0.0,
            max: 1.0,
            activeColor: MizanColors.amber400,
            onChanged: notifier.setVolume,
          ),
          Text(
            'Companion Size (${comp.sizePx.round()} px)',
            style: MizanTypography.body(
                fontSize: 12, color: MizanColors.slate200),
          ),
          Slider(
            value: comp.sizePx,
            min: 44,
            max: 72,
            activeColor: MizanColors.emerald400,
            onChanged: notifier.setSize,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '10-Minute Pre-Salah Alert Bell',
              style: MizanTypography.body(fontSize: 12, color: Colors.white),
            ),
            value: comp.salahLeadAlertEnabled,
            activeColor: MizanColors.amber400,
            onChanged: notifier.setSalahAlert,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Screen Quota Compassionate Chime',
              style: MizanTypography.body(fontSize: 12, color: Colors.white),
            ),
            value: comp.screenLimitAlertEnabled,
            activeColor: MizanColors.emerald400,
            onChanged: notifier.setScreenLimitAlert,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => jumpToSourceFile(ref,
                    'android/app/src/main/kotlin/com/mizan/app/FloatingCompanionOverlayService.kt'),
                icon: const Icon(LucideIcons.code2,
                    size: 13, color: MizanColors.amber300),
                label: Text(
                  'FloatingCompanionOverlayService.kt',
                  style: MizanTypography.code(
                      fontSize: 10.5, color: MizanColors.emerald300),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => jumpToSourceFile(ref,
                    'android/app/src/main/kotlin/com/mizan/app/CompanionAudioPoolManager.kt'),
                icon: const Icon(LucideIcons.code2,
                    size: 13, color: MizanColors.amber300),
                label: Text(
                  'CompanionAudioPoolManager.kt',
                  style: MizanTypography.code(
                      fontSize: 10.5, color: MizanColors.emerald300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

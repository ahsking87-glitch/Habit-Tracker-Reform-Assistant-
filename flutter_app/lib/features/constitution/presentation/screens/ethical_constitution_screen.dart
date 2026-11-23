import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/mizan_theme.dart';
import '../../../../core/widgets/mizan_ui_kit.dart';

class EthicalConstitutionScreen extends StatelessWidget {
  const EthicalConstitutionScreen({super.key});

  static const List<({String num, String title, String desc})> _pillars = [
    (
      num: '01',
      title: 'Autonomy Over Hostage-Taking',
      desc:
          'Mīzān never traps the user in an inescapable screen or uses hostile countdown locks. Every shield includes a deliberate, mindful 7-second physiological breathing bypass.',
    ),
    (
      num: '02',
      title: 'Zero Guilt or Shame Framing',
      desc:
          'Traditional blockers use shame-inducing notifications ("You failed again", "You wasted 2 hours"). Mīzān adopts Motivational Interviewing (OARS) to invite self-compassion and reflection.',
    ),
    (
      num: '03',
      title: '100% Local Data Sovereignty',
      desc:
          'Your prayer times, habits, Quran bookmarks, and screen time statistics are saved offline on your hardware. Zero telemetry. Zero remote servers.',
    ),
    (
      num: '04',
      title: 'Compassionate "Istighfar Grace Days"',
      desc:
          'Habit streaks do not punish illness, travel, or emergencies. Monthly grace tokens preserve streaks automatically, preventing the toxic all-or-nothing abandonment syndrome.',
    ),
    (
      num: '05',
      title: 'Strict Prominent Disclosure',
      desc:
          'Under Google Play Accessibility API policies, Mīzān clearly explains in-app why the AccessibilityService is requested BEFORE navigating the user to OS settings.',
    ),
    (
      num: '06',
      title: 'P2P Cryptographic Accountability',
      desc:
          'No public leaderboards or competitive rank humiliation. Accountability partners share zero-knowledge cryptographic hashes (Ed25519) verifying consistency without exposing private life.',
    ),
    (
      num: '07',
      title: 'Actionable 2-Minute Physical Alternatives',
      desc:
          'Breaking a dopamine loop requires a tangible replacement. Every intervention presents immediately actionable micro-actions: cool wudu, 33x tasbih, or looking at the sky.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MizanColors.amber500.withAlpha(46),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: MizanColors.amber400.withAlpha(128)),
                    ),
                    child: const Icon(LucideIcons.shield,
                        size: 24, color: MizanColors.amber300),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE MĪZĀN ETHICAL CHARTER',
                          style: MizanTypography.code(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: MizanColors.amber300,
                          ),
                        ),
                        Text(
                          'The 7 Pillars of Ethical Digital Wellbeing',
                          style: MizanTypography.title(
                              fontSize: 21, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 680 ? 2 : 1;

                Widget buildPillarCard(({String num, String title, String desc}) p) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: MizanColors.bgCardAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MizanColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.num,
                              style: MizanTypography.code(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: MizanColors.amber400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.title,
                                style: MizanTypography.title(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.desc,
                          style: MizanTypography.body(
                            fontSize: 11.5,
                            color: MizanColors.emerald300.withAlpha(217),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (cols == 1) {
                  return Column(
                    children: [
                      for (int i = 0; i < _pillars.length; i++) ...[
                        buildPillarCard(_pillars[i]),
                        if (i < _pillars.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  );
                }

                final rows = <Widget>[];
                for (int i = 0; i < _pillars.length; i += 2) {
                  final first = _pillars[i];
                  final second =
                      i + 1 < _pillars.length ? _pillars[i + 1] : null;
                  rows.add(
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: buildPillarCard(first)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: second != null
                                ? buildPillarCard(second)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (i + 2 < _pillars.length) {
                    rows.add(const SizedBox(height: 14));
                  }
                }
                return Column(children: rows);
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),
        MizanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Google Play & Apple App Store Submission Guide',
                style: MizanTypography.title(
                    fontSize: 16, color: MizanColors.amber300),
              ),
              const SizedBox(height: 8),
              Text(
                'To guarantee seamless store approval for Accessibility & ScreenTime entitlements:',
                style: MizanTypography.body(
                    fontSize: 12, color: MizanColors.slate300),
              ),
              const SizedBox(height: 8),
              Text(
                '• Android: Record a 30-second video showing the in-app Prominent Disclosure dialog appearing before opening Accessibility Settings. Submit with declaration: "Mīzān uses Accessibility API exclusively to detect short-form video URLs and view IDs for digital wellbeing overlays."',
                style: MizanTypography.body(
                    fontSize: 12, color: MizanColors.slate200, height: 1.45),
              ),
              const SizedBox(height: 6),
              Text(
                '• iOS: Submit the Apple FamilyControls entitlement request form highlighting the digital wellbeing use case. Ensure the app adheres to ManagedSettings guidelines without third-party tracking.',
                style: MizanTypography.body(
                    fontSize: 12, color: MizanColors.slate200, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

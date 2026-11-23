import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/native_bridge_service.dart';
import '../../../../core/theme/mizan_theme.dart';

class ProminentDisclosureDialog extends ConsumerWidget {
  const ProminentDisclosureDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width > 600 ? 540.0 : screenSize.width * 0.94;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      backgroundColor: MizanColors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: MizanColors.amber400, width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenSize.height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MizanColors.amber500.withAlpha(46),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: MizanColors.amber400.withAlpha(128)),
                    ),
                    child: const Icon(LucideIcons.shieldCheck,
                        size: 24, color: MizanColors.amber300),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOOGLE PLAY POLICY COMPLIANCE',
                          style: MizanTypography.code(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: MizanColors.amber300,
                          ),
                        ),
                        Text(
                          'Prominent Disclosure: Accessibility Service',
                          style: MizanTypography.title(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x,
                        size: 18, color: MizanColors.slate400),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MizanColors.bgCardAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: MizanColors.borderEmerald),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why Mīzān Requests This Permission',
                      style: MizanTypography.body(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: MizanColors.amber300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mīzān uses the Android AccessibilityService API strictly and solely to identify when algorithmic short-form video feeds (YouTube Shorts, Instagram Reels, TikTok) are rendered on your display.',
                      style: MizanTypography.body(
                          fontSize: 12, color: MizanColors.slate200),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'When detected, Mīzān launches a non-coercive full-screen reflection shield with a 7-second physiological breathing pause and 2-minute offline task alternatives.',
                      style: MizanTypography.body(
                          fontSize: 12, color: MizanColors.slate200),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(LucideIcons.lock,
                      size: 14, color: MizanColors.amber400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Our Strict Privacy & Data Sovereignty Commitments:',
                      style: MizanTypography.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MizanColors.emerald300,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: screenSize.width > 480 ? 2 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: screenSize.width > 480 ? 2.5 : 3.2,
                children: [
                  _guarantee(
                    'ZERO Data Collection',
                    'Never logs keystrokes, personal messages, or passwords.',
                  ),
                  _guarantee(
                    '100% Offline Processing',
                    'All detection happens on-device. Zero network requests.',
                  ),
                  _guarantee(
                    'Zero Dark Patterns',
                    'Always offers a 7-second bypass. Autonomy stays intact.',
                  ),
                  _guarantee(
                    'Revocable at Any Time',
                    'Toggle off immediately inside Mīzān or Android Settings.',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Not Now',
                      style: MizanTypography.body(
                        fontSize: 12,
                        color: MizanColors.emerald300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MizanColors.amber400,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      ref.read(shieldProvider.notifier).grantAccessibility();
                      await NativeBridgeService.instance
                          .requestAndroidPermissions();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.checkCircle2, size: 15),
                    label: Text(
                      'I Understand & Agree',
                      style: MizanTypography.body(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guarantee(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: MizanColors.emerald950.withAlpha(166),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MizanColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: MizanTypography.body(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MizanTypography.body(
              fontSize: 10,
              color: MizanColors.emerald300.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}

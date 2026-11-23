import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/mizan_theme.dart';

class OverlayShieldModal extends ConsumerStatefulWidget {
  final String targetApp;
  final VoidCallback onDismiss;
  final ValueChanged<String> onSelectAlternative;

  const OverlayShieldModal({
    super.key,
    required this.targetApp,
    required this.onDismiss,
    required this.onSelectAlternative,
  });

  @override
  ConsumerState<OverlayShieldModal> createState() =>
      _OverlayShieldModalState();
}

class _OverlayShieldModalState extends ConsumerState<OverlayShieldModal> {
  int _secondsRemaining = 7;
  bool _inhale = true;
  Timer? _countdownTimer;
  Timer? _breathTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        setState(() => _secondsRemaining = 0);
        t.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
    _breathTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (mounted) setState(() => _inhale = !_inhale);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breathTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canUnlock = _secondsRemaining == 0;
    final isSalah = widget.targetApp == 'Salah Approaching';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xF5061814),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: MizanColors.emerald950,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: MizanColors.borderEmerald),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.shieldAlert,
                        size: 13, color: MizanColors.amber400),
                    const SizedBox(width: 6),
                    Text(
                      'OS Overlay Shield Active',
                      style: MizanTypography.body(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: MizanColors.emerald300,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDismiss,
                icon: const Icon(LucideIcons.x,
                    size: 18, color: MizanColors.slate400),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'INTERVENTION TRIGGER',
                    style: MizanTypography.code(
                      fontSize: 10,
                      color: MizanColors.amber300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSalah
                        ? '🕌 Time for Salah Focus'
                        : 'A Mindful Pause (${widget.targetApp})',
                    textAlign: TextAlign.center,
                    style: MizanTypography.title(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSalah
                        ? 'Adhan is approaching in moments. Reclaim your stillness and prepare for the divine audience.'
                        : 'You opened ${widget.targetApp} during a focus window. Before the algorithm captures your attention, pause here.',
                    textAlign: TextAlign.center,
                    style: MizanTypography.body(
                      fontSize: 11,
                      color: MizanColors.slate300,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MizanColors.emerald950.withAlpha(140),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: MizanColors.borderEmerald),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: MizanTypography.arabic(
                            fontSize: 16,
                            color: MizanColors.amber300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"And seek help through patience and prayer..." (Surah Al-Baqarah 2:45)',
                          textAlign: TextAlign.center,
                          style: MizanTypography.body(
                            fontSize: 10,
                            color: MizanColors.emerald300.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 3000),
                    curve: Curves.easeInOut,
                    width: _inhale ? 96 : 74,
                    height: _inhale ? 96 : 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MizanColors.emerald900.withAlpha(179),
                      border: Border.all(
                        color: MizanColors.amber400.withAlpha(191),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _inhale ? 'INHALE' : 'EXHALE',
                          style: MizanTypography.code(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: MizanColors.amber300,
                          ),
                        ),
                        Text(
                          canUnlock ? '✓ Centered' : '${_secondsRemaining}s',
                          style: MizanTypography.code(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Physiological sigh: double inhale through the nose, long exhale through the mouth.',
                    textAlign: TextAlign.center,
                    style: MizanTypography.body(
                      fontSize: 10,
                      color: MizanColors.emerald300.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.sparkles,
                              size: 13, color: MizanColors.amber400),
                          const SizedBox(width: 6),
                          Text(
                            'Immediate 2-Minute Alternatives',
                            style: MizanTypography.body(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: MizanColors.amber300,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Offline Ready',
                        style: MizanTypography.code(
                          fontSize: 10,
                          color: MizanColors.emerald400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio:
                        MediaQuery.of(context).size.width < 400 ? 1.32 : 1.5,
                    children: [
                      _altCard(
                        icon: LucideIcons.droplets,
                        iconColor: MizanColors.cyan400,
                        title: 'Wudu Reset',
                        desc: 'Wash hands & face with cool water.',
                        onTap: () =>
                            widget.onSelectAlternative('Cool Wudu Refresh'),
                      ),
                      _altCard(
                        icon: LucideIcons.compass,
                        iconColor: MizanColors.amber400,
                        title: '33x Tasbih',
                        desc: 'SubhanAllah wa bihamdihi gently.',
                        onTap: () => widget
                            .onSelectAlternative('33x Tasbih Remembrance'),
                      ),
                      _altCard(
                        icon: LucideIcons.bookOpen,
                        iconColor: MizanColors.emerald400,
                        title: '5 Ayahs Quran',
                        desc: 'Feed the soul instead of the feed.',
                        onTap: () => widget
                            .onSelectAlternative('Read 5 Ayahs of Quran'),
                      ),
                      _altCard(
                        icon: LucideIcons.sun,
                        iconColor: MizanColors.amber400,
                        title: 'Sky Horizon Gaze',
                        desc: 'Look at daylight horizon outside.',
                        onTap: () =>
                            widget.onSelectAlternative('Horizon & Sky Gaze'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: canUnlock ? widget.onDismiss : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: canUnlock
                          ? MizanColors.amber500.withAlpha(56)
                          : MizanColors.emerald950,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canUnlock
                            ? MizanColors.amber400.withAlpha(128)
                            : MizanColors.borderSubtle,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          canUnlock
                              ? LucideIcons.checkCircle2
                              : LucideIcons.refreshCw,
                          size: 14,
                          color: canUnlock
                              ? MizanColors.amber400
                              : MizanColors.emerald500,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            canUnlock
                                ? 'Conscious 15-Min Unlock'
                                : 'Pause for ${_secondsRemaining}s...',
                            overflow: TextOverflow.ellipsis,
                            style: MizanTypography.body(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: canUnlock
                                  ? MizanColors.amber300
                                  : MizanColors.emerald400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: widget.onDismiss,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: MizanColors.emerald950,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MizanColors.borderEmerald),
                  ),
                  child: Text(
                    'Return Home',
                    style: MizanTypography.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MizanColors.emerald300,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ethical Design: Mīzān never traps you. After a mindful breath, your autonomy is 100% respected.',
            textAlign: TextAlign.center,
            style: MizanTypography.body(
              fontSize: 9,
              color: MizanColors.emerald400.withAlpha(166),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _altCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: MizanColors.emerald950.withAlpha(191),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MizanColors.borderEmerald),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: iconColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: MizanTypography.body(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MizanColors.emerald300,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: MizanTypography.body(
                fontSize: 9.5,
                color: MizanColors.slate300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

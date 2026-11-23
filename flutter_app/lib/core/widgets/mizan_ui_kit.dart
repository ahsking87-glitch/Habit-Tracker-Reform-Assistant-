import 'package:flutter/material.dart';
import '../theme/mizan_theme.dart';

/// Shared dark emerald card matching `bg-[#071D17] border border-emerald-800/60 rounded-2xl`.
class MizanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double borderRadius;
  final Gradient? gradient;

  const MizanCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = MizanColors.bgCard,
    this.borderColor = MizanColors.borderEmerald,
    this.borderRadius = 20,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MizanBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;

  const MizanBadge({
    super.key,
    required this.label,
    this.bgColor = const Color(0x66064E3B),
    this.borderColor = const Color(0x80047857),
    this.textColor = MizanColors.emerald300,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: MizanTypography.body(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MizanIconButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final bool fullWidth;

  const MizanIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.bgColor = MizanColors.amber500,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.black,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onPressed == null ? 0.55 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: MizanTypography.body(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

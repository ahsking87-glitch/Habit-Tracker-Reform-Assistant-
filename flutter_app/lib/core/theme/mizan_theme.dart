import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mīzān Theme Tokens matching index.css & Tailwind dark emerald-gold design system.
class MizanColors {
  MizanColors._();

  static const Color bgDeep = Color(0xFF051210);
  static const Color bgHeader = Color(0xFF061613);
  static const Color bgSurface = Color(0xFF061814);
  static const Color bgCard = Color(0xFF071D17);
  static const Color bgCardAlt = Color(0xFF09221B);
  static const Color bgCardElevated = Color(0xFF0D2822);
  static const Color bgInput = Color(0xFF040F0D);
  static const Color bgPhoneFrame = Color(0xFF0A241E);

  static const Color borderSubtle = Color(0xFF183E36);
  static const Color borderEmerald = Color(0x99065F46);
  static const Color borderEmeraldBright = Color(0x6610B981);
  static const Color borderGold = Color(0x59F59E0B);

  static const Color gold = Color(0xFFCFA859);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);

  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);

  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);

  static const Color rose400 = Color(0xFFFB7185);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color violet400 = Color(0xFFA78BFA);
  static const Color sky400 = Color(0xFF38BDF8);
}

class MizanTypography {
  MizanTypography._();

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = MizanColors.slate200,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle title({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color color = MizanColors.amber400,
    double? height,
    double? letterSpacing = 0.4,
  }) {
    return GoogleFonts.cinzel(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle arabic({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.normal,
    Color color = MizanColors.amber300,
    double? height = 1.9,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle code({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color color = MizanColors.emerald300,
    double? height = 1.6,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: MizanColors.bgDeep,
      primaryColor: MizanColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: MizanColors.amber500,
        secondary: MizanColors.emerald500,
        surface: MizanColors.bgSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: MizanColors.slate200,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: MizanColors.slate200,
        displayColor: MizanColors.amber400,
      ),
      dividerColor: MizanColors.borderSubtle,
      dialogTheme: DialogTheme(
        backgroundColor: MizanColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: MizanColors.borderEmerald),
        ),
      ),
    );
  }
}

/// Paints the subtle 24px radial dotted gold lattice matching `.bg-islamic-pattern`.
class IslamicPatternPainter extends CustomPainter {
  const IslamicPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0ACFA859) // rgba(207, 168, 89, 0.04)
      ..style = PaintingStyle.fill;

    const double spacing = 24.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x + 1, y + 1), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

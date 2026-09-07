import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFF0B0F14);
  static const Color bgElevated = Color(0xFF121820);
  static const Color bgCard = Color(0xFF161E28);
  static const Color surface = Color(0xFF1A2430);
  static const Color border = Color(0xFF2A3644);
  static const Color borderStrong = Color(0xFF3A4A5C);

  static const Color textPrimary = Color(0xFFF2F5F8);
  static const Color textSecondary = Color(0xFF9AA8B5);
  static const Color textMuted = Color(0xFF6B7A88);

  static const Color accent = Color(0xFF00C2A8);
  static const Color accentDim = Color(0xFF007A6A);
  static const Color cyan = Color(0xFF3DB8E8);

  static const Color valid = Color(0xFF22C55E);
  static const Color ready = Color(0xFF22C55E);
  static const Color recovering = Color(0xFFF59E0B);
  static const Color medium = Color(0xFFF59E0B);
  static const Color invalid = Color(0xFFEF4444);
  static const Color expired = Color(0xFFEF4444);
  static const Color fault = Color(0xFFDC2626);
  static const Color indeterminate = Color(0xFF8B95A1);
  static const Color low = Color(0xFFF97316);

  static const Color scanLine = Color(0xFF00E5C0);
  static const Color viewfinder = Color(0xFF05080C);
  static const Color shutter = Color(0xFFE8EEF4);

  static Color statusOf(String status) {
    final s = status.toUpperCase();
    if (s.contains('READY') ||
        s.contains('VALID') ||
        s.contains('VERIFIED') ||
        s.contains('SYNCED') ||
        s.contains('HIGH') ||
        s.contains('AUTHENTIC') ||
        s.contains('BASELINE RECOVERED') ||
        s.contains('FIT')) {
      return valid;
    }
    if (s.contains('RECOVERING') ||
        s.contains('MEDIUM') ||
        s.contains('PENDING') ||
        s.contains('EXPOSED') ||
        s.contains('ACTIVE')) {
      return recovering;
    }
    if (s.contains('INVALID') ||
        s.contains('EXPIRED') ||
        s.contains('FAULT') ||
        s.contains('DAMAGED') ||
        s.contains('REJECTED') ||
        s.contains('NO RESULT') ||
        s.contains('REMOVED') ||
        s.contains('LOW')) {
      return invalid;
    }
    if (s.contains('INDETERMINATE') || s.contains('UNKNOWN')) {
      return indeterminate;
    }
    return textSecondary;
  }
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.cyan,
        surface: AppColors.bgElevated,
        error: AppColors.invalid,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
    );

    final body = GoogleFonts.ibmPlexSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    final mono = GoogleFonts.ibmPlexMonoTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: body.copyWith(
        displayLarge: body.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: body.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: body.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: body.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
        bodySmall: body.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: body.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(48, 52),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 52),
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: body.bodyMedium?.copyWith(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgElevated,
        modalBackgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accentDim,
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      extensions: [MonoStyle(style: mono.bodyMedium!)],
    );
  }
}

class MonoStyle extends ThemeExtension<MonoStyle> {
  final TextStyle style;
  const MonoStyle({required this.style});

  @override
  MonoStyle copyWith({TextStyle? style}) => MonoStyle(style: style ?? this.style);

  @override
  MonoStyle lerp(ThemeExtension<MonoStyle>? other, double t) {
    if (other is! MonoStyle) return this;
    return MonoStyle(style: TextStyle.lerp(style, other.style, t)!);
  }
}

TextStyle mono(BuildContext context, {double? size, FontWeight? weight, Color? color}) {
  final ext = Theme.of(context).extension<MonoStyle>();
  return (ext?.style ?? GoogleFonts.ibmPlexMono()).copyWith(
    fontSize: size ?? 14,
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? AppColors.textPrimary,
    letterSpacing: 0.2,
  );
}

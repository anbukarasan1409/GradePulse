import 'package:material_ui/material_ui.dart';

/// Core color palette, gradients, and motion presets for the dark navy,
/// electric blue, cyan, and violet glassmorphism design system.
class AppColors {
  AppColors._();

  static const Color navyDeep = Color(0xFF050A18);
  static const Color navySurface = Color(0xFF0B1228);
  static const Color navyCard = Color(0xFF101936);
  static const Color navyElevated = Color(0xFF162247);

  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color electricBlueBright = Color(0xFF60A5FA);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanBright = Color(0xFF22D3EE);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetBright = Color(0xFFA855F7);

  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, cyan],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, violet],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, cyanBright, violetBright],
  );
}

/// Centralized motion timings and curves that respect reduced-motion
/// accessibility preferences.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 340);
  static const Duration slow = Duration(milliseconds: 560);
  static const Duration countUp = Duration(milliseconds: 1100);
  static const Duration routeTransition = Duration(milliseconds: 380);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeOutExpo;
  static const Curve smoothSpring = Curves.easeOutBack;

  /// Returns true when the platform or user requests reduced motion.
  static bool reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media == null) return false;
    return media.disableAnimations || media.accessibleNavigation;
  }

  static Duration effectiveDuration(BuildContext context, Duration normal) {
    return reduceMotion(context) ? Duration.zero : normal;
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData buildDarkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.electricBlue,
      secondary: AppColors.cyan,
      tertiary: AppColors.violet,
      surface: AppColors.navySurface,
      error: AppColors.rose,
      onPrimary: Colors.white,
      onSecondary: AppColors.navyDeep,
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.navyDeep,
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.navyCard.withValues(alpha: 0.72),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.cyanBright,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
        thumbColor: AppColors.electricBlueBright,
        overlayColor: AppColors.cyan.withValues(alpha: 0.18),
        trackHeight: 5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navyElevated,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

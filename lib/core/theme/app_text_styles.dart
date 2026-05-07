import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ChessCoach AI typography system.
/// Premium Google Fonts with responsive scaling for modern chess analytics UI.
class AppTextStyles {
  AppTextStyles._();

  static const double _mobileBaseWidth = 390;
  static const double _tabletBaseWidth = 768;
  static const double _desktopBaseWidth = 1280;

  static String get baseFontFamily => GoogleFonts.playfairDisplay().fontFamily!;
  static String get monoFontFamily => GoogleFonts.jetBrainsMono().fontFamily!;

  static double responsiveScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= _mobileBaseWidth) {
      return (width / _mobileBaseWidth).clamp(0.9, 1.0);
    }
    if (width <= _tabletBaseWidth) {
      return (width / _tabletBaseWidth).clamp(1.0, 1.1);
    }
    return (width / _desktopBaseWidth).clamp(1.1, 1.2);
  }

  static TextTheme textTheme([Color? color]) {
    final textColor = color ?? AppColors.onBackground;
    return GoogleFonts.playfairDisplayTextTheme(
      const TextTheme(),
    ).copyWith(
      displayLarge: _style(48, FontWeight.w700, textColor, letterSpacing: -1.0),
      displayMedium: _style(38, FontWeight.w700, textColor, letterSpacing: -0.8),
      displaySmall: _style(30, FontWeight.w700, textColor, letterSpacing: -0.5),
      headlineLarge: _style(26, FontWeight.w600, textColor),
      headlineMedium: _style(22, FontWeight.w600, textColor),
      headlineSmall: _style(20, FontWeight.w600, textColor),
      titleLarge: _style(18, FontWeight.w600, textColor),
      titleMedium: _style(16, FontWeight.w600, textColor),
      titleSmall: _style(14, FontWeight.w600, textColor),
      bodyLarge: _style(16, FontWeight.w400, AppColors.onSurface),
      bodyMedium: _style(14, FontWeight.w400, AppColors.onSurface),
      bodySmall: _style(12, FontWeight.w400, AppColors.onSurfaceVariant),
      labelLarge: _style(14, FontWeight.w600, textColor, letterSpacing: 0.2),
      labelMedium: _style(12, FontWeight.w600, textColor, letterSpacing: 0.2),
      labelSmall: _style(11, FontWeight.w600, AppColors.onSurfaceVariant, letterSpacing: 0.3),
    );
  }

  static TextStyle _style(double size, FontWeight weight, Color color,
      {double letterSpacing = 0.0, double height = 1.2}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Custom styles for specific use cases
  static TextStyle headline1(BuildContext context, {Color? color}) {
    return _style(32 * responsiveScale(context), FontWeight.w700, color ?? AppColors.onBackground);
  }

  static TextStyle headline2(BuildContext context, {Color? color}) {
    return _style(28 * responsiveScale(context), FontWeight.w600, color ?? AppColors.onBackground);
  }

  static TextStyle headline3(BuildContext context, {Color? color}) {
    return _style(24 * responsiveScale(context), FontWeight.w600, color ?? AppColors.onBackground);
  }

  static TextStyle body1(BuildContext context, {Color? color}) {
    return _style(16 * responsiveScale(context), FontWeight.w400, color ?? AppColors.onSurface);
  }

  static TextStyle body2(BuildContext context, {Color? color}) {
    return _style(14 * responsiveScale(context), FontWeight.w400, color ?? AppColors.onSurface);
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    return _style(12 * responsiveScale(context), FontWeight.w400, color ?? AppColors.onSurfaceVariant);
  }

  static TextStyle button(BuildContext context, {Color? color}) {
    return _style(16 * responsiveScale(context), FontWeight.w600, color ?? AppColors.onPrimary);
  }

  static TextStyle monoCode(BuildContext context, {Color? color}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 14 * responsiveScale(context),
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.onSurface,
    );
  }
}

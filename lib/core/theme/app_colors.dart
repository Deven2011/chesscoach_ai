import 'package:flutter/material.dart';

/// Custom color palette for ChessCoach AI
/// Inspired by chess.com and esports dashboards
/// Dark modern UI with premium feel
class AppColors {
  // Primary: Emerald Green
  static const Color primary = Color(0xFF10B981);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF065F46);

  // Secondary: Gold
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFF5E6A3);
  static const Color secondaryDark = Color(0xFFB8860B);

  // Background: Dark Charcoal
  static const Color background = Color(0xFF2D3748);
  static const Color backgroundLight = Color(0xFF4A5568);
  static const Color backgroundDark = Color(0xFF1A202C);

  // Surface: Matte Black
  static const Color surface = Color(0xFF1A202C);
  static const Color surfaceLight = Color(0xFF2D3748);
  static const Color surfaceDark = Color(0xFF0F1419);
  static const Color surfaceRaised = Color(0xFF334155); // Elevated surface color
  static const Color surfacePanel = Color(0xFF1E293B); // Panel background

  // Accent: Bronze
  static const Color accent = Color(0xFFCD7F32);
  static const Color accentLight = Color(0xFFE6B17A);
  static const Color accentDark = Color(0xFF8B4513);

  // Error and Success
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.white70;
  static const Color onSurface = Colors.white70;
  static const Color onSurfaceVariant = Colors.white54;

  // Additional Premium Colors
  static const Color highlight = Color(0xFFFFD700); // Bright gold for highlights
  static Color shadow = Color(0xFF000000).withValues(alpha: 0.3);
  static const Color border = Color(0xFF4A5568);

  // Helper methods for color manipulation
  static Color withAlpha(Color color, double alpha) => color.withValues(alpha: alpha);
  static Color emerald = primary;
  static Color emeraldDeep = primaryDark;
  static Color emeraldSoft = primaryLight;
  static Color gold = secondary;
  static Color goldDeep = secondaryDark;
  static Color goldSoft = secondaryLight;
  static Color bronze = accent;
  static Color bronzeDeep = accentDark;
  static Color errorRed = error;
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white70;
  static Color textMuted = Colors.white54;
  static Color textDisabled = Colors.white24;
  static Color divider = Colors.white12;
  static Color borderStrong = Colors.white24;
  static Color scrim = Colors.black54;

  static Color emeraldAlpha(double alpha) => primary.withValues(alpha: alpha);
}

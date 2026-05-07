import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Complete handcrafted premium theme for ChessCoach AI.
/// Dark modern UI inspired by chess.com and esports dashboards.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: AppColors.onSecondary,
      tertiary: AppColors.accent,
      onTertiary: AppColors.onPrimary,
      tertiaryContainer: AppColors.accentDark,
      onTertiaryContainer: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      errorContainer: AppColors.error.withOpacity(0.1),
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      shadow: AppColors.shadow,
      scrim: AppColors.shadow,
      inverseSurface: AppColors.onBackground,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.primaryLight,
      surfaceContainerHighest: AppColors.surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: AppTextStyles.textTheme(),
      fontFamily: AppTextStyles.baseFontFamily,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: AppTextStyles.textTheme().headlineSmall?.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.onSurface),
        toolbarHeight: 64,
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.textTheme().labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryDark.withOpacity(0.2);
            }
            return null;
          }),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
        hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.7)),
        errorStyle: TextStyle(color: AppColors.error),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.onSurface,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        deleteIconColor: AppColors.onSurface,
        labelStyle: TextStyle(color: AppColors.onSurface),
        secondaryLabelStyle: TextStyle(color: AppColors.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border),
        ),
        elevation: 0,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceLight,
        circularTrackColor: AppColors.surfaceLight,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return AppColors.surfaceLight;
        }),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600);
          }
          return TextStyle(color: AppColors.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(color: AppColors.onSurfaceVariant);
        }),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: TextStyle(color: AppColors.onSurface),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

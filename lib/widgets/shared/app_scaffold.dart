import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

/// A reusable scaffold wrapper for ChessCoach AI.
/// Provides a premium dark gradient background, SafeArea support,
/// responsive padding, and smooth page transitions.
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final EdgeInsetsGeometry? padding;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer,
    this.padding,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.useSafeArea = true,
  });

  /// Standard screen padding for the application.
  static EdgeInsets getScreenPadding(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    return EdgeInsets.symmetric(
      horizontal: 24 * scale,
      vertical: 20 * scale,
    );
  }

  /// Consistent spacing constants
  static const double sectionSpacing = 24;
  static const double cardSpacing = 16;
  static const double elementSpacing = 12;

  /// Smooth page transition for navigating between screens.
  static Route<T> pageRoute<T>({required Widget child}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// A pre-styled transparent AppBar that fits the ChessCoach AI aesthetic.
  static PreferredSizeWidget transparentAppBar({
    String? title,
    Widget? titleWidget,
    List<Widget>? actions,
    bool centerTitle = true,
    Widget? leading,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: titleWidget ?? (title != null
          ? Text(
              title,
              style: AppTextStyles.textTheme().titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
            )
          : null),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? getScreenPadding(context);

    Widget content = Padding(
      padding: effectivePadding,
      child: body,
    );

    if (useSafeArea) {
      content = SafeArea(
        top: appBar == null && !extendBodyBehindAppBar,
        bottom: true,
        left: true,
        right: true,
        child: content,
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.background,
              AppColors.backgroundLight,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: content,
      ),
    );
  }
}

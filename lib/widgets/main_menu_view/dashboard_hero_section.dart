import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class DashboardHeroSection extends StatefulWidget {
  const DashboardHeroSection({super.key});

  @override
  State<DashboardHeroSection> createState() => _DashboardHeroSectionState();
}

class _DashboardHeroSectionState extends State<DashboardHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late AnimationController _textController;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = AppTextStyles.responsiveScale(context);
    final heroHeight = (size.height * 0.35).clamp(280.0, 450.0);

    return Container(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    width: 100 * scale,
                    height: 100 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.grid_4x4_rounded,
                        size: 50 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24 * scale),

                // App title
                FadeTransition(
                  opacity: _textAnimation,
                  child: Text(
                    'ChessCoach AI',
                    style: AppTextStyles.headline1(context).copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 8 * scale),

                // Tagline
                FadeTransition(
                  opacity: _textAnimation,
                  child: Text(
                    'Train Smarter. Play Better.',
                    style: AppTextStyles.body1(context).copyWith(
                      color: AppColors.onSurfaceVariant.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 20 * scale),
                
                const AnimatedChessPiece(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedChessPiece extends StatefulWidget {
  const AnimatedChessPiece({super.key});

  @override
  State<AnimatedChessPiece> createState() => _AnimatedChessPieceState();
}

class _AnimatedChessPieceState extends State<AnimatedChessPiece>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '♔',
                    style: TextStyle(
                      fontSize: 24 * scale,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    'Grandmaster Level AI',
                    style: AppTextStyles.caption(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

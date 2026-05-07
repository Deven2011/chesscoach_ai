import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../widgets/shared/app_scaffold.dart';
import '../widgets/main_menu_view/game_options.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';
import 'chess_view.dart';

class GameSetupView extends StatefulWidget {
  const GameSetupView({super.key});

  @override
  State<GameSetupView> createState() => _GameSetupViewState();
}

class _GameSetupViewState extends State<GameSetupView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AppScaffold(
      appBar: AppScaffold.transparentAppBar(
        title: 'MATCH SETUP',
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(8.0 * scale),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primary,
                size: 24 * scale,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppModel>(
        builder: (context, appModel, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, scale),
                            SizedBox(height: 32 * scale),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16 * scale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel(
                                      context, scale, 'BATTLE CONFIGURATION'),
                                  SizedBox(height: 20 * scale),
                                  _buildGlassmorphismCard(
                                    context,
                                    scale,
                                    child: const GameOptions(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32 * scale),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildStartButton(context, appModel, scale, bottomPadding),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20 * scale),
          ScaleTransition(
            scale: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100 * scale,
                  height: 100 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.secondary.withValues(alpha: 0.08),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80 * scale,
                  height: 80 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
                Icon(
                  Icons.military_tech_rounded,
                  size: 56 * scale,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            'Prepare for Battle',
            style: AppTextStyles.textTheme().displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
          ),
          SizedBox(height: 12 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * scale),
            child: Text(
              'Customize your match parameters and strategy',
              textAlign: TextAlign.center,
              style: AppTextStyles.textTheme().bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
          SizedBox(height: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, double scale, String label) {
    return Row(
      children: [
        Container(
          width: 4 * scale,
          height: 22 * scale,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.secondary, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        SizedBox(width: 12 * scale),
        Text(
          label,
          style: AppTextStyles.textTheme().labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                fontSize: 12 * scale,
              ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismCard(BuildContext context, double scale,
      {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28 * scale),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(28 * scale),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.05),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.all(24 * scale),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, AppModel appModel,
      double scale, double bottomPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16 * scale, 16 * scale, 16 * scale, (16 * scale) + bottomPadding),
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutQuart),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            _animationController.reverse().then((_) {
              Navigator.pushReplacement(
                context,
                AppScaffold.pageRoute(
                  child: ChessView(appModel, isResuming: false),
                ),
              );
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 64 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'START MATCH',
                    style: AppTextStyles.textTheme().labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                          fontSize: 16 * scale,
                          color: Colors.white,
                        ),
                  ),
                  SizedBox(width: 12 * scale),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24 * scale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

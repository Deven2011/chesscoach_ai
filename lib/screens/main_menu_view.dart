import 'package:flutter/material.dart';
import 'package:en_passant/widgets/main_menu_view/dashboard_hero_section.dart';
import 'package:en_passant/widgets/main_menu_view/action_cards_grid.dart';
import 'package:en_passant/widgets/main_menu_view/stats_section.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class MainMenuView extends StatefulWidget {
  const MainMenuView({super.key});

  @override
  State<MainMenuView> createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return AppScaffold(
      useSafeArea: false, // Hero section handles top padding
      padding: EdgeInsets.zero,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: DashboardHeroSection(),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
              sliver: const SliverToBoxAdapter(
                child: ActionCardsGrid(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppScaffold.sectionSpacing * scale),
            ),
            const SliverToBoxAdapter(
              child: StatsSection(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: AppScaffold.sectionSpacing * scale + MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      ),
    );
  }
}

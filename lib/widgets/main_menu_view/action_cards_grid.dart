import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/providers/auth_provider.dart' as auth;
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/screens/analytics/analytics_dashboard_screen.dart';
import 'package:en_passant/screens/analytics/match_history_screen.dart';
import 'package:en_passant/screens/chess_view.dart';
import 'package:en_passant/screens/coach/ai_coach_dashboard_screen.dart';
import 'package:en_passant/screens/puzzles/daily_puzzle_screen.dart';
import 'package:en_passant/screens/settings_view.dart';
import 'package:en_passant/screens/game_setup_view.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';
import 'package:en_passant/logic/game_state_storage.dart';

class ActionCardsGrid extends StatefulWidget {
  const ActionCardsGrid({super.key});

  @override
  State<ActionCardsGrid> createState() => _ActionCardsGridState();
}

class _ActionCardsGridState extends State<ActionCardsGrid> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final hasSaved = await GameStateStorage.hasSavedGame();
    if (mounted) {
      setState(() {
        _hasSavedGame = hasSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final childAspectRatio =
            (constraints.maxWidth / crossAxisCount) / (200 * scale);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppScaffold.cardSpacing,
          mainAxisSpacing: AppScaffold.cardSpacing,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            ActionCard(
              icon: Icons.play_arrow_rounded,
              title: 'New Game',
              subtitle: 'Start match setup',
              color: AppColors.primary,
              onTap: () => _navigateToSetup(context),
            ),
            if (_hasSavedGame)
              ActionCard(
                icon: Icons.restore_rounded,
                title: 'Resume',
                subtitle: 'Continue last game',
                color: AppColors.secondary,
                onTap: () => _navigateToGame(context, true),
              ),
            ActionCard(
              icon: Icons.extension_rounded,
              title: 'Daily Puzzle',
              subtitle: 'Solve chess puzzles',
              color: AppColors.accent,
              onTap: () => _navigateToPuzzle(context),
            ),
            ActionCard(
              icon: Icons.analytics_rounded,
              title: 'Analytics',
              subtitle: 'View your progress',
              color: AppColors.primaryLight,
              onTap: () => _navigateToAnalytics(context),
            ),
            ActionCard(
              icon: Icons.psychology_alt_rounded,
              title: 'AI Coach',
              subtitle: 'Personal training plan',
              color: AppColors.secondary,
              onTap: () => _navigateToCoach(context),
            ),
            ActionCard(
              icon: Icons.history_rounded,
              title: 'Match History',
              subtitle: 'Review past games',
              color: AppColors.white,
              onTap: () => _navigateToHistory(context),
            ),
            ActionCard(
              icon: Icons.settings_rounded,
              title: 'Settings',
              subtitle: 'Customize experience',
              color: AppColors.secondaryLight,
              onTap: () => _navigateToSettings(context),
            ),
            ActionCard(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: 'Return to login',
              color: AppColors.error,
              onTap: () => _signOut(context),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSetup(BuildContext context) {
    Navigator.push(
      context,
      AppScaffold.pageRoute(child: const GameSetupView()),
    ).then((_) => _checkSavedGame());
  }

  void _navigateToGame(BuildContext context, bool isResuming) {
    final appModel = Provider.of<AppModel>(context, listen: false);
    Navigator.push(
      context,
      AppScaffold.pageRoute(
        child: ChessView(appModel, isResuming: isResuming),
      ),
    ).then((_) => _checkSavedGame());
  }

  void _navigateToPuzzle(BuildContext context) {
    Navigator.push(
      context,
      AppScaffold.pageRoute(child: const DailyPuzzleScreen()),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    Navigator.push(
      context,
      AppScaffold.pageRoute(child: const AnalyticsDashboardScreen()),
    );
  }

  void _navigateToCoach(BuildContext context) {
    Navigator.push(
      context,
      AppScaffold.pageRoute(child: const AiCoachDashboardScreen()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      AppScaffold.pageRoute(child: const MatchHistoryScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      AppScaffold.pageRoute(child: const SettingsView()),
    ).then((_) => _checkSavedGame());
  }

  Future<void> _signOut(BuildContext context) async {
    final authProvider = context.read<auth.AuthProvider>();
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Sign out?', style: AppTextStyles.headline3(context)),
        content: Text(
          'Your saved game and settings stay on this device.',
          style: AppTextStyles.body1(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      if (!mounted) return;
      await authProvider.signOut();
    }
  }
}

class ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0 * scale),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54 * scale,
                  height: 54 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.color, widget.color.withOpacity(0.8)],
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 28 * scale,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  widget.title,
                  style: AppTextStyles.body1(context).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15 * scale,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4 * scale),
                Expanded(
                  child: Text(
                    widget.subtitle,
                    style: AppTextStyles.caption(context).copyWith(
                      fontSize: 11 * scale,
                      color: AppColors.onSurfaceVariant.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

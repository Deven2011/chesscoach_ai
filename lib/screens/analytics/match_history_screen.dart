import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/match_history_provider.dart';
import 'package:en_passant/widgets/analytics/recent_match_tile.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppScaffold.transparentAppBar(title: 'MATCH HISTORY'),
      body: Consumer<MatchHistoryProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
            color: AppColors.primary,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                Text(
                  'Review every completed match saved to your account.',
                  style: AppTextStyles.body1(context).copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                if (provider.errorMessage != null)
                  _ErrorBanner(message: provider.errorMessage!),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!provider.isLoading && provider.matches.isEmpty)
                  const _EmptyHistory()
                else
                  ...provider.matches.map(
                    (match) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RecentMatchTile(match: match),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded,
              color: AppColors.secondary, size: 42),
          const SizedBox(height: 14),
          Text(
            'No matches saved yet',
            style: AppTextStyles.headline3(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finish a game and it will appear here automatically.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2(context).copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: AppTextStyles.body2(context).copyWith(color: AppColors.error),
      ),
    );
  }
}

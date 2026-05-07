import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/widgets/shared/retry_button.dart';

class NoConnectionCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const NoConnectionCard({
    super.key,
    this.title = 'No connection',
    this.message = 'Waiting for internet connection...',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.secondary,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.textTheme().titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTextStyles.textTheme().bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            RetryButton(onPressed: onRetry, label: 'Retry Sync'),
          ],
        ],
      ),
    );
  }
}

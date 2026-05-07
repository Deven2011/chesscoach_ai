import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const RetryButton({
    super.key,
    required this.onPressed,
    this.label = 'Retry',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
      label: Text(
        label,
        style: AppTextStyles.textTheme().labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }
}

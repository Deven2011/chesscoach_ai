import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/connectivity_provider.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        return Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: connectivity.isOffline
                  ? Container(
                      key: const ValueKey('offline-banner'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      color: AppColors.secondaryDark,
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              color: AppColors.onSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "You're offline. Playing locally.",
                                style: AppTextStyles.textTheme()
                                    .labelMedium
                                    ?.copyWith(
                                      color: AppColors.onSecondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('online-banner')),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

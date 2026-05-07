import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/sync_state_model.dart';
import 'package:en_passant/providers/connectivity_provider.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, provider, _) {
        final state = provider.syncState;
        if (state.pendingCount == 0 && provider.isOnline) {
          return const SizedBox.shrink();
        }

        final color = provider.isOffline
            ? AppColors.secondary
            : state.status == SyncQueueStatus.failed
                ? AppColors.error
                : AppColors.primary;
        final message = provider.isOffline
            ? 'Changes will sync automatically.'
            : state.message ?? 'Syncing changes...';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: provider.retrySync,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.isOffline
                        ? Icons.schedule_rounded
                        : Icons.cloud_sync_rounded,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.pendingCount > 0
                          ? '$message ${state.pendingCount} pending.'
                          : message,
                      style: AppTextStyles.textTheme().labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.refresh_rounded, color: color, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

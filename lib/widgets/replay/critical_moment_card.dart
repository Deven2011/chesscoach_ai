import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/models/move_review_model.dart';

class CriticalMomentCard extends StatelessWidget {
  final MoveReviewModel? review;
  final String emptyLabel;
  final VoidCallback? onTap;

  const CriticalMomentCard({
    super.key,
    required this.review,
    this.emptyLabel = 'No critical mistakes detected.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = review;
    return InkWell(
      onTap: item == null ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (item?.color ?? AppColors.primary).withValues(alpha: 0.22),
          ),
        ),
        child: item == null
            ? Text(emptyLabel, style: AppTextStyles.body2(context))
            : Row(
                children: [
                  Icon(Icons.bolt_rounded, color: item.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.qualityLabel} on move ${item.moveNumber}',
                          style: AppTextStyles.body2(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.feedback,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

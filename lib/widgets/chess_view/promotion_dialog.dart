import 'package:flutter/material.dart';
import 'package:en_passant/logic/chess_constants.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/widgets/chess_view/promotion_option.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class PromotionDialog extends StatelessWidget {
  final AppModel appModel;

  const PromotionDialog(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24 * scale),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PROMOTE PAWN',
              style: AppTextStyles.headline3(context).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: AppColors.primaryLight,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Choose your new piece',
              style: AppTextStyles.body2(context).copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: PROMOTIONS
                  .map(
                    (promotionType) => PromotionOption(
                      appModel,
                      promotionType,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

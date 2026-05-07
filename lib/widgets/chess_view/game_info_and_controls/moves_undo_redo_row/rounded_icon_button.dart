import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class RoundedIconButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onPressed;
  final String? tooltip;

  const RoundedIconButton(this.icon, {super.key, this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.surface.withOpacity(0.3),
        disabledForegroundColor: Colors.white.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        minimumSize: Size(double.infinity, 70 * scale),
      ),
      icon: Icon(icon, size: 24 * scale),
    );
  }
}

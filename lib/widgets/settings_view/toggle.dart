import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class Toggle extends StatelessWidget {
  final String label;
  final bool? toggle;
  final Function(bool)? setFunc;

  const Toggle(this.label, {super.key, this.toggle, this.setFunc});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Container(
      margin: EdgeInsets.only(bottom: 8 * scale),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
        title: Text(
          label,
          style: AppTextStyles.body1(context).copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15 * scale,
          ),
        ),
        trailing: Switch(
          value: toggle ?? false,
          onChanged: setFunc,
          activeColor: AppColors.primary,
        ),
      ),
    );
  }
}

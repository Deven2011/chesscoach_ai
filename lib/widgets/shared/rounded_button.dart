import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final double? width;
  final double? height;

  const RoundedButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? (56 * scale),
      child: ElevatedButton(
        onPressed: onPressed,
        style: color != null 
          ? ElevatedButton.styleFrom(backgroundColor: color) 
          : null,
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.button(context).copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
            fontSize: 15 * scale,
          ),
        ),
      ),
    );
  }
}

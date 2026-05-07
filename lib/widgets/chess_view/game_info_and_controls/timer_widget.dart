import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class TimerWidget extends StatelessWidget {
  final ValueListenable<Duration> timeLeft;
  final Color color;
  final String label;

  const TimerWidget({
    super.key,
    required this.timeLeft,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Expanded(
      child: ValueListenableBuilder<Duration>(
        valueListenable: timeLeft,
        builder: (context, duration, child) {
          final isLowTime = duration.inSeconds < 30;
          
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 12 * scale),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLowTime ? AppColors.error.withOpacity(0.5) : color.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: isLowTime ? [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ] : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption(context).copyWith(
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w800,
                    color: color.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _durationToString(duration),
                    style: AppTextStyles.monoCode(context).copyWith(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: isLowTime ? AppColors.error : AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _durationToString(Duration duration) {
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

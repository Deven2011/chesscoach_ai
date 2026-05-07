import 'package:flutter/material.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/picker.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/core/theme/app_colors.dart';

class TimeLimitPicker extends StatelessWidget {
  final int? selectedTime;
  final Function(int?)? setTime;

  const TimeLimitPicker({super.key, this.selectedTime, this.setTime});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Picker<int>(
          label: 'TIME CONTROL',
          selection: selectedTime,
          setFunc: setTime,
          options: const {
            0: _TimeOption(
              icon: Icons.all_inclusive_rounded,
              label: 'Unlimited',
              duration: 'No clock',
            ),
            1: _TimeOption(
              icon: Icons.bolt_rounded,
              label: 'Bullet',
              duration: '1 min',
            ),
            5: _TimeOption(
              icon: Icons.flash_on_rounded,
              label: 'Blitz',
              duration: '5 min',
            ),
            10: _TimeOption(
              icon: Icons.timer_rounded,
              label: 'Rapid',
              duration: '10 min',
            ),
            30: _TimeOption(
              icon: Icons.hourglass_bottom_rounded,
              label: 'Classical',
              duration: '30 min',
            ),
            60: _TimeOption(
              icon: Icons.hourglass_full_rounded,
              label: 'Classical+',
              duration: '60 min',
            ),
          },
        ),
        if (selectedTime != null)
          Padding(
            padding: EdgeInsets.only(top: 8.0 * scale, left: 4 * scale),
            child: Row(
              children: [
                Icon(
                  _getTimeIcon(selectedTime!),
                  size: 14 * scale,
                  color: AppColors.secondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  _getTimeCategory(selectedTime!),
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getTimeIcon(int minutes) {
    if (minutes == 0) return Icons.all_inclusive_rounded;
    if (minutes <= 2) return Icons.bolt_rounded;
    if (minutes <= 5) return Icons.flash_on_rounded;
    if (minutes <= 15) return Icons.timer_rounded;
    return Icons.hourglass_full_rounded;
  }

  String _getTimeCategory(int minutes) {
    if (minutes == 0) return 'Unlimited - Casual Play';
    if (minutes <= 2) return 'Bullet - Lightning Fast';
    if (minutes <= 5) return 'Blitz - High Intensity';
    if (minutes <= 15) return 'Rapid - Strategic Balance';
    if (minutes <= 30) return 'Classical - Deep Analysis';
    return 'Classical+ - Long-form Calculation';
  }
}

class _TimeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String duration;

  const _TimeOption({
    required this.icon,
    required this.label,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(width: 6),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

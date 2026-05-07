import 'package:flutter/material.dart';
import 'package:en_passant/widgets/main_menu_view/game_options/picker.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class AIDifficultyPicker extends StatelessWidget {
  final int aiDifficulty;
  final Function(int?) setFunc;

  const AIDifficultyPicker(this.aiDifficulty, this.setFunc, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Picker<int>(
          label: 'AI DIFFICULTY',
          selection: aiDifficulty,
          setFunc: setFunc,
          options: const {
            1: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.spa_rounded),
                SizedBox(width: 6),
                Text('Easy'),
              ],
            ),
            2: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.brightness_medium_rounded),
                SizedBox(width: 6),
                Text('Medium'),
              ],
            ),
            3: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded),
                SizedBox(width: 6),
                Text('Hard'),
              ],
            ),
            4: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology_rounded),
                SizedBox(width: 6),
                Text('Expert'),
              ],
            ),
            5: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded),
                SizedBox(width: 6),
                Text('Master'),
              ],
            ),
          },
        ),
        SizedBox(height: 12 * scale),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
          child: Row(
            children: [
              Icon(
                _getDifficultyIcon(aiDifficulty),
                size: 14 * scale,
                color: _getDifficultyColor(aiDifficulty),
              ),
              SizedBox(width: 6 * scale),
              Expanded(
                child: Text(
                  _getDifficultyDescription(aiDifficulty),
                  style: AppTextStyles.textTheme().bodySmall?.copyWith(
                        color: _getDifficultyColor(aiDifficulty),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getDifficultyIcon(int difficulty) {
    switch (difficulty) {
      case 1:
        return Icons.spa_rounded;
      case 2:
        return Icons.brightness_medium_rounded;
      case 3:
        return Icons.local_fire_department_rounded;
      case 4:
        return Icons.psychology_rounded;
      case 5:
        return Icons.bolt_rounded;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppColors.success;
      case 2:
        return Colors.blue;
      case 3:
        return AppColors.secondary;
      case 4:
        return Colors.orange;
      case 5:
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  String _getDifficultyDescription(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy - relaxed opening practice';
      case 2:
        return 'Medium - balanced casual challenge';
      case 3:
        return 'Hard - sharper tactical pressure';
      case 4:
        return 'Expert - deeper search and defense';
      case 5:
        return 'Master - maximum supported engine depth';
      default:
        return 'Select difficulty';
    }
  }
}

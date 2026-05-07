import 'package:flutter/material.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/screens/chess_view.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class RestartExitButtons extends StatelessWidget {
  final AppModel appModel;

  const RestartExitButtons(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Padding(
      padding: EdgeInsets.only(top: 8 * scale),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showRestartConfirmation(context),
              child: const Text('RESTART'),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (appModel.gameOver) {
                  appModel.exitChessView();
                  Navigator.pop(context);
                } else {
                  showExitDialog(context, appModel);
                }
              },
              child: const Text('EXIT'),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestartConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Restart Game?', style: AppTextStyles.headline3(context)),
        content: Text('Are you sure you want to start a new game?', style: AppTextStyles.body1(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appModel.newGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('RESTART'),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show exit dialog (re-declared if needed or imported)
void showExitDialog(BuildContext context, AppModel appModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Exit Game?', style: AppTextStyles.headline3(context)),
        content: Text('Do you want to save your progress?', style: AppTextStyles.body1(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              appModel.exitChessView();
              Navigator.of(context).pop();
            },
            child: const Text('EXIT WITHOUT SAVING'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appModel.saveAndExitChessView();
              Navigator.of(context).pop();
            },
            child: const Text('SAVE & EXIT'),
          ),
        ],
      ),
    );
}

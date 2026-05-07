import 'package:flutter/material.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/widgets/settings_view/toggle.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class Toggles extends StatelessWidget {
  final AppModel appModel;

  const Toggles(this.appModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return Column(
      children: [
        Toggle(
          'Board Rotation (2P)',
          toggle: appModel.enableRotation,
          setFunc: appModel.setEnableRotation,
        ),
        Toggle(
          'Show Hints',
          toggle: appModel.showHints,
          setFunc: appModel.setShowHints,
        ),
        Toggle(
          'Show Notation',
          toggle: appModel.showNotation,
          setFunc: appModel.setShowNotation,
        ),
        Toggle(
          'Allow Undo/Redo',
          toggle: appModel.allowUndoRedo,
          setFunc: appModel.setAllowUndoRedo,
        ),
        Toggle(
          'Show Move History',
          toggle: appModel.showMoveHistory,
          setFunc: appModel.setShowMoveHistory,
        ),
        Toggle(
          'Sound Enabled',
          toggle: appModel.soundEnabled,
          setFunc: appModel.setSoundEnabled,
        ),
      ],
    );
  }
}

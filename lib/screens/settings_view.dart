import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/app_themes.dart' as board_themes;
import 'package:en_passant/widgets/settings_view/app_theme_picker.dart';
import 'package:en_passant/widgets/settings_view/piece_theme_picker.dart';
import 'package:en_passant/widgets/settings_view/toggles.dart';
import 'package:en_passant/widgets/shared/app_scaffold.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showResetConfirmation(BuildContext context, AppModel appModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Settings?',
          style: AppTextStyles.headline3(context).copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to reset all settings to their defaults?',
          style: AppTextStyles.body1(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appModel.resetSettingsToDefaults();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return AppScaffold(
      appBar: AppScaffold.transparentAppBar(
        title: 'Settings',
        actions: [
          Consumer<AppModel>(
            builder: (context, appModel, child) => IconButton(
              onPressed: () => _showResetConfirmation(context, appModel),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset to defaults',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader(context, 'Appearance'),
                const AppThemePicker(),
                SizedBox(height: AppScaffold.cardSpacing * scale),
                const PieceThemePicker(),
                SizedBox(height: AppScaffold.sectionSpacing * scale),
                _buildSectionHeader(context, 'Gameplay'),
                Consumer<AppModel>(
                  builder: (context, appModel, child) => Toggles(appModel),
                ),
                SizedBox(height: AppScaffold.sectionSpacing * scale),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0 * scale),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BACK'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scale = AppTextStyles.responsiveScale(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale, top: 8 * scale),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

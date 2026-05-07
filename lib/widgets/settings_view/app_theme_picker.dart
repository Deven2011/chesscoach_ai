import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/models/app_themes.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class AppThemePicker extends StatefulWidget {
  const AppThemePicker({super.key});

  @override
  State<AppThemePicker> createState() => _AppThemePickerState();
}

class _AppThemePickerState extends State<AppThemePicker> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final appModel = Provider.of<AppModel>(context, listen: false);
    _scrollController =
        FixedExtentScrollController(initialItem: appModel.themeIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Selector<AppModel, int>(
      selector: (_, m) => m.themeIndex,
      builder: (context, themeIndex, child) {
        if (_scrollController.hasClients &&
            _scrollController.selectedItem != themeIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpToItem(themeIndex);
            }
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0 * scale),
              child: Text(
                'Board Theme',
                style: AppTextStyles.body2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(
              height: 140 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: CupertinoPicker(
                scrollController: _scrollController,
                magnification: 1.1,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 44 * scale,
                onSelectedItemChanged: (index) {
                  Provider.of<AppModel>(context, listen: false).setTheme(index);
                },
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: AppColors.primary.withOpacity(0.1),
                ),
                children: themeList
                    .map(
                      (theme) => Center(
                        child: Text(
                          theme.name ?? "Unnamed",
                          style: AppTextStyles.body1(context).copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

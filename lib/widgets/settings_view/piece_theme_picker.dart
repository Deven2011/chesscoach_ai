import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/widgets/settings_view/piece_preview.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class PieceThemePicker extends StatefulWidget {
  const PieceThemePicker({super.key});

  @override
  State<PieceThemePicker> createState() => _PieceThemePickerState();
}

class _PieceThemePickerState extends State<PieceThemePicker> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final appModel = Provider.of<AppModel>(context, listen: false);
    _scrollController =
        FixedExtentScrollController(initialItem: appModel.pieceThemeIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);

    return Consumer<AppModel>(
      builder: (context, appModel, child) {
        if (_scrollController.hasClients &&
            _scrollController.selectedItem != appModel.pieceThemeIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpToItem(appModel.pieceThemeIndex);
            }
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0 * scale),
              child: Text(
                'Piece Set',
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
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _scrollController,
                      magnification: 1.1,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 44 * scale,
                      onSelectedItemChanged: appModel.setPieceTheme,
                      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                        background: AppColors.primary.withOpacity(0.1),
                      ),
                      children: appModel.pieceThemes
                          .map(
                            (theme) => Center(
                              child: Text(
                                theme,
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
                  Container(
                    width: 1,
                    height: 80 * scale,
                    color: AppColors.border.withOpacity(0.3),
                  ),
                  Container(
                    width: 100 * scale,
                    height: 140 * scale,
                    child: GameWidget(
                      game: PiecePreview(appModel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

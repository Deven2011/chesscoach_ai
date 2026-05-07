import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:en_passant/logic/chess_game.dart';
import 'package:en_passant/models/app_model.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class ChessBoardWidget extends StatelessWidget {
  final AppModel appModel;
  final ChessGame chessGame;

  const ChessBoardWidget(this.appModel, this.chessGame, {super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smaller dimension to keep the board square
        final boardSize = constraints.biggest.shortestSide;

        return Center(
          child: Stack(
            children: [
              AnimatedRotation(
                turns: appModel.isBoardInverted ? 0.5 : 0,
                duration: appModel.animateBoardRotation
                    ? const Duration(milliseconds: 600)
                    : Duration.zero,
                curve: Curves.easeInOutQuart,
                child: Container(
                  width: boardSize,
                  height: boardSize,
                  decoration: appModel.theme.name != 'Video Chess'
                      ? BoxDecoration(
                          color: appModel.theme.darkTile,
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: appModel.theme.border.withOpacity(0.8),
                            width: 4 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 20 * scale,
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 8),
                            ),
                          ],
                        )
                      : const BoxDecoration(),
                  child: ClipRRect(
                    borderRadius: appModel.theme.name != 'Video Chess'
                        ? BorderRadius.circular(8 * scale)
                        : BorderRadius.zero,
                    child: GameWidget(game: chessGame),
                  ),
                ),
              ),
              if (appModel.showNotation)
                IgnorePointer(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: _NotationOverlay(
                      appModel.theme.notation,
                      isRotated: appModel.isBoardInverted,
                      boardSize: boardSize,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NotationOverlay extends StatefulWidget {
  final Color color;
  final bool isRotated;
  final double boardSize;

  const _NotationOverlay(
    this.color, {
    required this.isRotated,
    required this.boardSize,
  });

  @override
  State<_NotationOverlay> createState() => _NotationOverlayState();
}

class _NotationOverlayState extends State<_NotationOverlay> {
  late bool _visibleRotated;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _visibleRotated = widget.isRotated;
  }

  @override
  void didUpdateWidget(_NotationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRotated != widget.isRotated) {
      setState(() {
        _opacity = 0.0;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _visibleRotated = widget.isRotated;
            _opacity = 1.0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final tileSize = widget.boardSize / 8;
    final textStyle = AppTextStyles.monoCode(context).copyWith(
      color: widget.color.withOpacity(0.7),
      fontSize: 9 * scale,
      fontWeight: FontWeight.w800,
    );

    return AnimatedOpacity(
      duration: Duration(milliseconds: _opacity == 0.0 ? 150 : 300),
      opacity: _opacity,
      child: Stack(
        children: [
          // Files (Letters a-h)
          for (int i = 0; i < 8; i++)
            Positioned(
              left: i * tileSize,
              bottom: 2 * scale,
              width: tileSize - (4 * scale),
              child: Text(
                String.fromCharCode(
                  (_visibleRotated ? 'h' : 'a').codeUnitAt(0) +
                      (_visibleRotated ? -i : i),
                ),
                style: textStyle,
                textAlign: TextAlign.right,
              ),
            ),
          // Ranks (Numbers 1-8)
          for (int i = 0; i < 8; i++)
            Positioned(
              top: (i * tileSize) + (4 * scale),
              left: 4 * scale,
              child: Text(
                (_visibleRotated ? i + 1 : 8 - i).toString(),
                style: textStyle,
              ),
            ),
        ],
      ),
    );
  }
}

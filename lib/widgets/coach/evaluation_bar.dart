import 'package:flutter/material.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class EvaluationBar extends StatelessWidget {
  final double value;
  final int? centipawnEval;
  final bool isAnalyzing;

  const EvaluationBar({
    super.key,
    required this.value,
    this.centipawnEval,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.05, 0.95).toDouble();

    return SizedBox(
      width: 28,
      child: Column(
        children: [
          Text(
            _label(centipawnEval),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.28),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            height: constraints.maxHeight * clamped,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isAnalyzing)
                          const Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(int? eval) {
    if (eval == null) return '0.0';
    final pawns = eval / 100;
    if (pawns > 0) return '+${pawns.toStringAsFixed(1)}';
    return pawns.toStringAsFixed(1);
  }
}

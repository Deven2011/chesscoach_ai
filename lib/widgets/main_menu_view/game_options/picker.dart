import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';

class Picker<T extends Object> extends StatefulWidget {
  final String? label;
  final Map<T, Widget>? options;
  final T? selection;
  final Function(T?)? setFunc;

  const Picker({
    super.key,
    this.label,
    this.options,
    this.selection,
    this.setFunc,
  });

  @override
  State<Picker<T>> createState() => _PickerState<T>();
}

class _PickerState<T extends Object> extends State<Picker<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(Picker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppTextStyles.responsiveScale(context);
    final optionEntries = widget.options?.entries.toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 12 * scale, left: 4 * scale),
            child: Text(
              widget.label!.toUpperCase(),
              style: AppTextStyles.textTheme().labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0 * scale),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (optionEntries.isEmpty) return const SizedBox.shrink();

                    final spacing = 8 * scale;
                    final columns = _columnCount(
                        constraints.maxWidth, optionEntries.length);
                    final itemWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: optionEntries.map((option) {
                        final isSelected = widget.selection == option.key;

                        return SizedBox(
                          width: itemWidth,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              final isAnimating = isSelected &&
                                  _animationController.isAnimating;
                              final pulseScale = isAnimating
                                  ? 1.0 + (_animationController.value * 0.025)
                                  : 1.0;

                              return Transform.scale(
                                scale: pulseScale,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => widget.setFunc?.call(option.key),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOutQuart,
                                    constraints: BoxConstraints(
                                      minHeight: 58 * scale,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10 * scale,
                                      vertical: 12 * scale,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.surfaceLight
                                              .withValues(alpha: 0.32),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.secondary
                                                .withValues(alpha: 0.72)
                                            : AppColors.border
                                                .withValues(alpha: 0.22),
                                        width: isSelected ? 1.4 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.34),
                                                blurRadius: 16,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 8),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: IconTheme.merge(
                                          data: IconThemeData(
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.secondary,
                                            size: 18 * scale,
                                          ),
                                          child: DefaultTextStyle(
                                            style: AppTextStyles.textTheme()
                                                    .labelMedium
                                                    ?.copyWith(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : AppColors.onSurface,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w800
                                                          : FontWeight.w600,
                                                      fontSize: 13 * scale,
                                                      letterSpacing: 0.1,
                                                    ) ??
                                                const TextStyle(),
                                            child: option.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  int _columnCount(double width, int count) {
    if (count <= 1) return 1;
    if (count == 2) return 2;
    if (width >= 560 && count >= 4) return 4;
    if (width >= 420 && count >= 3) return 3;
    return 2;
  }
}

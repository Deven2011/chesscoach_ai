import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:en_passant/core/theme/app_colors.dart';
import 'package:en_passant/core/theme/app_text_styles.dart';
import 'package:en_passant/providers/replay_provider.dart';

class EvaluationGraph extends StatelessWidget {
  const EvaluationGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReplayProvider>(
      builder: (context, replay, child) {
        final evaluations = replay.review.evaluations;
        return Container(
          height: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
          ),
          child: evaluations.isEmpty
              ? Center(
                  child: Text(
                    'Evaluation graph appears after reviewed moves.',
                    style: AppTextStyles.body2(context),
                  ),
                )
              : CustomPaint(
                  painter: _EvaluationPainter(
                    evaluations: evaluations,
                    currentIndex: replay.state.currentMoveIndex,
                  ),
                  child: const SizedBox.expand(),
                ),
        );
      },
    );
  }
}

class _EvaluationPainter extends CustomPainter {
  final List<int> evaluations;
  final int currentIndex;

  const _EvaluationPainter({
    required this.evaluations,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      axisPaint,
    );

    final maxAbs = math.max(
      300,
      evaluations.map((value) => value.abs()).reduce(math.max),
    );
    final points = <Offset>[];
    for (var index = 0; index < evaluations.length; index++) {
      final x = evaluations.length == 1
          ? 0.0
          : size.width * index / (evaluations.length - 1);
      final normalized = (evaluations[index] / maxAbs).clamp(-1.0, 1.0);
      final y = size.height / 2 - normalized * (size.height * 0.42);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final markerIndex = (currentIndex - 1).clamp(0, points.length - 1).toInt();
    final marker = points[markerIndex];
    canvas.drawCircle(
      marker,
      5,
      Paint()..color = AppColors.secondary,
    );
  }

  @override
  bool shouldRepaint(covariant _EvaluationPainter oldDelegate) {
    return oldDelegate.evaluations != evaluations ||
        oldDelegate.currentIndex != currentIndex;
  }
}

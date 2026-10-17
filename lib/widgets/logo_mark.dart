import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Chocolate rounded-square logo mark with a 3×3 cream grid.
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: choc700,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: CustomPaint(
        painter: _GridPainter(size: size),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double size;
  const _GridPainter({required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = cream.withOpacity(0.85)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = cream.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final double pad = size * 0.22;
    final double inner = size - pad * 2;
    final double step = inner / 2;

    // 3×3 dot grid
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final dx = pad + col * step;
        final dy = pad + row * step;
        canvas.drawCircle(Offset(dx, dy), size * 0.055, dotPaint);
      }
    }
    // Connecting lines (horizontal + vertical)
    for (int i = 0; i < 3; i++) {
      final y = pad + i * step;
      canvas.drawLine(Offset(pad, y), Offset(pad + inner, y), paint);
    }
    for (int i = 0; i < 3; i++) {
      final x = pad + i * step;
      canvas.drawLine(Offset(x, pad), Offset(x, pad + inner), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => o.size != size;
}

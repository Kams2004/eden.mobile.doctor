import 'package:flutter/material.dart';

class MedicalBackground extends StatelessWidget {
  final Widget child;

  const MedicalBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface.withValues(alpha: 0.95),
            colorScheme.surface.withValues(alpha: 0.98),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Medical Filigram/Watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: MedicalFiligranPainter(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          // Main Content
          child,
        ],
      ),
    );
  }
}

class MedicalFiligranPainter extends CustomPainter {
  final Color color;

  MedicalFiligranPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final double spacing = 80.0;
    final double crossSize = 40.0;

    // Draw medical crosses pattern
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawMedicalCross(canvas, paint, Offset(x, y), crossSize);
      }
    }

    // Draw DNA helix pattern
    final double helixSpacing = 120.0;
    for (double x = helixSpacing / 2; x < size.width; x += helixSpacing) {
      for (double y = helixSpacing / 2; y < size.height; y += helixSpacing) {
        _drawDNAHelix(canvas, paint, Offset(x, y), 60.0);
      }
    }
  }

  void _drawMedicalCross(
      Canvas canvas, Paint paint, Offset center, double size) {
    final double halfSize = size / 2;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy),
      Offset(center.dx + halfSize, center.dy),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - halfSize),
      Offset(center.dx, center.dy + halfSize),
      paint,
    );
  }

  void _drawDNAHelix(Canvas canvas, Paint paint, Offset center, double height) {
    final Path path1 = Path();
    final Path path2 = Path();

    final double width = 30.0;
    final int segments = 8;

    for (int i = 0; i <= segments; i++) {
      final double t = i / segments;
      final double y = center.dy - height / 2 + t * height;
      final double x1 = center.dx + width / 2 * (1 - 2 * t).abs();
      final double x2 = center.dx - width / 2 * (1 - 2 * t).abs();

      if (i == 0) {
        path1.moveTo(x1, y);
        path2.moveTo(x2, y);
      } else {
        path1.lineTo(x1, y);
        path2.lineTo(x2, y);
      }
    }

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

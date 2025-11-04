import 'package:flutter/material.dart';
import '../../../../services/theme_service.dart';

class ScanningOverlayWidget extends StatefulWidget {
  const ScanningOverlayWidget({super.key});

  @override
  State<ScanningOverlayWidget> createState() => _ScanningOverlayWidgetState();
}

class _ScanningOverlayWidgetState extends State<ScanningOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScanningOverlayPainter(_scanLineAnimation, _themeService.isDarkMode),
      size: Size.infinite,
    );
  }
}

class ScanningOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;

  ScanningOverlayPainter(this.animation, this.isDarkMode) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final scanLinePaint = Paint()
      ..color = isDarkMode ? Colors.green : Color(0xFF3B82F6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Calculate overlay rectangle (70% of screen width, centered)
    final overlayWidth = size.width * 0.85;
    final overlayHeight = size.height * 0.6;
    final left = (size.width - overlayWidth) / 2;
    final top = (size.height - overlayHeight) / 2;

    final overlayRect = Rect.fromLTWH(left, top, overlayWidth, overlayHeight);

    // Draw semi-transparent overlay
    final overlayPaint = Paint()..color = Colors.black54;

    // Draw overlay with cutout
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    final cutoutPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;

    canvas.drawRect(overlayRect, cutoutPaint);

    // Draw corner brackets
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = isDarkMode ? Colors.white : Color(0xFF3B82F6)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + overlayWidth - cornerLength, top),
      Offset(left + overlayWidth, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + overlayWidth, top),
      Offset(left + overlayWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + overlayHeight - cornerLength),
      Offset(left, top + overlayHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + overlayHeight),
      Offset(left + cornerLength, top + overlayHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + overlayWidth - cornerLength, top + overlayHeight),
      Offset(left + overlayWidth, top + overlayHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + overlayWidth, top + overlayHeight - cornerLength),
      Offset(left + overlayWidth, top + overlayHeight),
      cornerPaint,
    );

    // Draw animated scan line
    final scanLineY = top + (overlayHeight * animation.value);
    canvas.drawLine(
      Offset(left + 10, scanLineY),
      Offset(left + overlayWidth - 10, scanLineY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

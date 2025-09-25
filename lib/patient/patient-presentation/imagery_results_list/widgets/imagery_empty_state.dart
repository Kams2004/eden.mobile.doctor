import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';

/// Empty state widget displayed when no imagery results are available
class ImageryEmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onRefresh;
  final bool isSearchResult;

  const ImageryEmptyState({
    super.key,
    this.message = 'Aucun résultat d\'imagerie',
    this.subtitle,
    this.onRefresh,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(colorScheme),
            SizedBox(height: 4.h),
            _buildMessage(colorScheme),
            if (subtitle != null) ...[
              SizedBox(height: 2.h),
              _buildSubtitle(colorScheme),
            ],
            SizedBox(height: 4.h),
            _buildActionButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(ColorScheme colorScheme) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background medical pattern
          Positioned.fill(
            child: CustomPaint(
              painter: MedicalPatternPainter(
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Main icon
          CustomIconWidget(
            iconName: isSearchResult ? 'search_off' : 'medical_services',
            color: colorScheme.primary.withValues(alpha: 0.6),
            size: 15.w,
          ),
          // Secondary icons for medical context
          if (!isSearchResult) ...[
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  size: 4.w,
                ),
              ),
            ),
            Positioned(
              bottom: 8.w,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'monitor_heart',
                  color: colorScheme.primary.withValues(alpha: 0.8),
                  size: 4.w,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessage(ColorScheme colorScheme) {
    return Text(
      message,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(ColorScheme colorScheme) {
    return Text(
      subtitle!,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      children: [
        if (onRefresh != null)
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.onPrimary,
              size: 4.w,
            ),
            label: Text(
              'Actualiser',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        if (isSearchResult) ...[
          SizedBox(height: 2.h),
          OutlinedButton.icon(
            onPressed: () {
              // Clear search or navigate back
            },
            icon: CustomIconWidget(
              iconName: 'clear',
              color: colorScheme.primary,
              size: 4.w,
            ),
            label: Text(
              'Effacer la recherche',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for medical pattern background
class MedicalPatternPainter extends CustomPainter {
  final Color color;

  MedicalPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * 0.3 * i, paint);
    }

    // Draw cross pattern
    canvas.drawLine(
      Offset(center.dx - radius * 0.2, center.dy),
      Offset(center.dx + radius * 0.2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.2),
      Offset(center.dx, center.dy + radius * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
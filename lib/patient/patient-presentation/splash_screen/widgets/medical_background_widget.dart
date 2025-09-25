import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../patient-core/core/app_export.dart';

/// Medical-themed background widget with watermark filigram
class MedicalBackgroundWidget extends StatelessWidget {
  final Widget child;

  const MedicalBackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.03),
            AppTheme.lightTheme.colorScheme.surface,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Medical watermark filigram
          _buildMedicalWatermark(),
          // Main content
          child,
        ],
      ),
    );
  }

  Widget _buildMedicalWatermark() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: Stack(
          children: [
            // Top left medical cross
            Positioned(
              top: 15.h,
              left: 10.w,
              child: Transform.rotate(
                angle: 0.2,
                child: CustomIconWidget(
                  iconName: 'local_hospital',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 15.w,
                ),
              ),
            ),
            // Center medical symbols
            Positioned(
              top: 35.h,
              right: 15.w,
              child: Transform.rotate(
                angle: -0.3,
                child: CustomIconWidget(
                  iconName: 'medical_services',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 12.w,
                ),
              ),
            ),
            // Bottom medical icon
            Positioned(
              bottom: 20.h,
              left: 20.w,
              child: Transform.rotate(
                angle: 0.4,
                child: CustomIconWidget(
                  iconName: 'science',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 10.w,
                ),
              ),
            ),
            // Additional decorative elements
            Positioned(
              top: 25.h,
              left: 5.w,
              child: Transform.rotate(
                angle: -0.1,
                child: CustomIconWidget(
                  iconName: 'biotech',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 8.w,
                ),
              ),
            ),
            Positioned(
              bottom: 35.h,
              right: 8.w,
              child: Transform.rotate(
                angle: 0.5,
                child: CustomIconWidget(
                  iconName: 'health_and_safety',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 9.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

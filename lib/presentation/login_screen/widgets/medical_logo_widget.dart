import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class MedicalLogoWidget extends StatelessWidget {
  const MedicalLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image (No background, just the image)
        Image.asset(
          'assets/images/pdmdlogo.jpeg',
          width: 25.w,
          height: 25.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 3.h),
        // App Name (Updated to "EDEN")
        Text(
          'EDEN',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 24.sp,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 1.h),
        // Subtitle
        Text(
          'Au service de vrotre santer',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryLight,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricAuthWidget extends StatelessWidget {
  final VoidCallback? onBiometricAuth;
  final bool isAvailable;

  const BiometricAuthWidget({
    Key? key,
    this.onBiometricAuth,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAvailable || kIsWeb) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 4.h),

        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'ou',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontSize: 12.sp,
                    ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric Auth Button
        Container(
          width: double.infinity,
          height: 7.h,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBiometricAuth,
              borderRadius: BorderRadius.circular(3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: defaultTargetPlatform == TargetPlatform.iOS
                        ? 'face'
                        : 'fingerprint',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? 'Se connecter avec Face ID'
                        : 'Se connecter avec empreinte',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

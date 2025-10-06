import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Correct import
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class MedicalLogoWidget extends StatelessWidget {
  const MedicalLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset( 
          'assets/lotties/login.json',
          width: 50.w,
          height: 50.w,
          fit: BoxFit.contain,
        ),
      
        // SizedBox(height: 1.h),
        // Text(
        //   'Au service de votre santé', 
        //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //     color: AppTheme.textSecondaryLight,
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w400,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
      ],
    );
  }
}
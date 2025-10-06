import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import 'package:lottie/lottie.dart'; 

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Lottie.asset(
                'assets/lotties/roles.json',
                width: 100.w,
                height: 75.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 2.h),
              // Title
              Text(
                'EDEN',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 4.h),
              // Subtitle
              Text(
                'Choisissez votre rôle',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8.h),
              // Role Selection Buttons (Horizontal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Doctor Button
                  _buildRoleButton(
                    context,
                    'Médecin',
                    () => Navigator.pushReplacementNamed(
                      context,
                      '/sendmail-screen',
                    ),
                  ),
                  // Patient Button
                  _buildRoleButton(
                    context,
                    'Patient',
                    () => Navigator.pushReplacementNamed(
                      context,
                      '/patient-dashboard', // <-- Navigate directly to PatientDashboard
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 2,
      ),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

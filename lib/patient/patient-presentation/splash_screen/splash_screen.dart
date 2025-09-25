import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-theme/theme/app_theme.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/medical_background_widget.dart';
import './widgets/medical_logo_widget.dart';

/// Splash Screen for PDMD Patient Portal
/// Provides branded launch experience while initializing secure medical data services
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize application with medical data services and authentication
  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isInitializing = true;
        _hasError = false;
      });

      // Simulate critical background tasks for medical app
      await Future.wait([
        _checkBiometricAuthentication(),
        _loadEncryptedCredentials(),
        _fetchMedicalDataPermissions(),
        _prepareSecureStorage(),
        _checkNetworkConnectivity(),
      ]);

      // Minimum splash duration for branding
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        await _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erreur d\'initialisation des services médicaux';
        });

        // Show retry option after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _showRetryDialog();
          }
        });
      }
    }
  }

  /// Check biometric authentication availability
  Future<void> _checkBiometricAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate biometric check - would use local_auth package in real implementation
  }

  /// Load encrypted patient credentials
  Future<void> _loadEncryptedCredentials() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulate secure credential loading - would use flutter_secure_storage
  }

  /// Fetch medical data permissions
  Future<void> _fetchMedicalDataPermissions() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Simulate permission checks for medical data access
  }

  /// Prepare secure storage for medical data
  Future<void> _prepareSecureStorage() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate secure storage initialization
  }

  /// Check network connectivity for medical data sync
  Future<void> _checkNetworkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simulate network connectivity check
  }

  /// Navigate to appropriate screen based on authentication status
  Future<void> _navigateToNextScreen() async {
    // Simulate authentication status check
    final bool isAuthenticated = await _checkAuthenticationStatus();
    final bool isNewUser = await _checkIfNewUser();

    if (!mounted) return;

    if (isAuthenticated) {
      // Navigate to patient dashboard for authenticated users
      Navigator.pushReplacementNamed(context, '/patient-dashboard');
    } else if (isNewUser) {
      // Navigate to registration for new users
      // For now, navigate to dashboard as registration screen not specified
      Navigator.pushReplacementNamed(context, '/patient-dashboard');
    } else {
      // Navigate to login for returning users
      // For now, navigate to dashboard as login screen not specified
      Navigator.pushReplacementNamed(context, '/patient-dashboard');
    }
  }

  /// Check current authentication status
  Future<bool> _checkAuthenticationStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Simulate authentication check - would check secure storage
    return false; // Default to not authenticated for demo
  }

  /// Check if user is new to the system
  Future<bool> _checkIfNewUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Simulate new user check - would check local storage
    return false; // Default to existing user for demo
  }

  /// Show retry dialog for initialization errors
  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Erreur de connexion',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Impossible de se connecter aux services médicaux. Vérifiez votre connexion internet et réessayez.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: Text(
              'Réessayer',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for medical theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: MedicalBackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              // Main content area
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PDMD Medical Logo
                      const MedicalLogoWidget(),

                      SizedBox(height: 8.h),

                      // Loading indicator or error state
                      _hasError
                          ? _buildErrorState()
                          : const LoadingIndicatorWidget(),
                    ],
                  ),
                ),
              ),

              // Footer with app version and medical compliance
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState() {
    return Column(
      children: [
        CustomIconWidget(
          iconName: 'error_outline',
          color: AppTheme.lightTheme.colorScheme.error,
          size: 8.w,
        ),
        SizedBox(height: 2.h),
        Text(
          _errorMessage,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build footer with medical compliance information
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        children: [
          Text(
            'PDMD Patient Portal v1.0.0',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.7),
                size: 3.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'Données médicales sécurisées • Conforme RGPD',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
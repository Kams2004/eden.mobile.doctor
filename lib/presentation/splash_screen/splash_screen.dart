import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import 'package:lottie/lottie.dart'; 


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate critical background tasks
      await Future.wait([
        _verifyBiometricAuthentication(),
        _checkSecureTokenValidity(),
        _loadEncryptedUserPreferences(),
        _prepareCachedPatientData(),
        _checkNetworkConnectivity(),
      ]);

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 3000));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        _handleInitializationError();
      }
    }
  }

  Future<void> _verifyBiometricAuthentication() async {
    // Simulate biometric authentication verification
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _checkSecureTokenValidity() async {
    // Simulate secure token validation
    await Future.delayed(const Duration(milliseconds: 400));
  }

  Future<void> _loadEncryptedUserPreferences() async {
    // Simulate loading encrypted user preferences
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _prepareCachedPatientData() async {
    // Simulate preparing cached patient data
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _checkNetworkConnectivity() async {
    // Simulate network connectivity check
    await Future.delayed(const Duration(milliseconds: 200));
  }

  void _navigateToNextScreen() {
    // Simulate authentication status check
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    if (isFirstTime) {
      // Navigate to role selection for first time users
      Navigator.pushReplacementNamed(context, '/role-selection');
    } else if (isAuthenticated) {
      // If user is already authenticated, go directly to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // For returning users who are not authenticated, go to role selection
      Navigator.pushReplacementNamed(context, '/role-selection');
    }
  }

  bool _checkAuthenticationStatus() {
    // Simulate authentication check - returns false for demo
    return false;
  }

  bool _checkFirstTimeUser() {
    // Simulate first time user check - returns false for demo
    return false;
  }

  void _handleInitializationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Erreur de connexion',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Impossible de se connecter aux services médicaux. Veuillez vérifier votre connexion internet et réessayer.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for professional medical app appearance
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.primaryLight,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.primaryLight,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight,
              AppTheme.primaryLight.withValues(alpha: 0.8),
              AppTheme.accentLight.withValues(alpha: 0.6),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content to center
              const Spacer(flex: 2),
              // Animated Logo Section
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogoSection(),
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
              // Loading Indicator
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLoadingIndicator(),
                  );
                },
              ),
              // Spacer to maintain center alignment
              const Spacer(flex: 3),
              // Footer Section
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFooterSection(),
                  );
                },
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Image (No background, no box)
        Image.asset(
          'assets/images/pdmd.png',
          width: 25.w,
          height: 25.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 4.h),
        // App Name
        Text(
          'EDEN',
          style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        // Subtitle
        Text(
          'Au service de votre santé',
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Lottie Loading Animation with more control
      Lottie.asset(
        'assets/lotties/splash.json',
        width: 35.w,
        height: 35.w,
        fit: BoxFit.contain,
        repeat: true, // Loop the animation
        animate: true, // Start animation automatically
      ),
      SizedBox(height: 2.h),
      // Loading Text
      Text(
        'Initialisation sécurisée...',
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

  Widget _buildFooterSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Security Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: Colors.white.withValues(alpha: 0.9),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Conforme HIPAA',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        // Version Info
        Text(
          'Version 1.0.0',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
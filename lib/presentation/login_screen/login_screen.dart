import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/medical_logo_widget.dart';
import './widgets/security_notice_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _biometricAvailable = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock credentials for different user types (now using usernames)
  final Map<String, Map<String, String>> _mockCredentials = {
    'admin': {
      'password': 'admin123',
      'role': 'Administrateur',
      'name': 'Dr. Marie Dubois'
    },
    'docteur': {
      'password': '123456',
      'role': 'Medecin',
      'name': 'doctor'
    },
    'specialiste': {
      'password': 'spec123',
      'role': 'Spécialiste',
      'name': 'Dr. Sophie Laurent'
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
    _setupSystemUI();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    _animationController.forward();
  }

  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.backgroundLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate biometric availability check
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _biometricAvailable = true; // Simulate availability
      });
    }
  }

  // Updated to accept username instead of email
  Future<void> _handleLogin(String username, String password) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    // Check mock credentials
    final credentials = _mockCredentials[username.toLowerCase()];
    if (credentials != null && credentials['password'] == password) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion réussie ! Bienvenue ${credentials['name']}'),
          backgroundColor: AppTheme.successLight,
          duration: const Duration(seconds: 2),
        ),
      );
      // Navigate to dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      // Error - show specific error message
      String errorMessage = 'Identifiants incorrects';
      if (!_mockCredentials.containsKey(username.toLowerCase())) {
        errorMessage = 'Compte non trouvé. Veuillez vérifier votre nom d\'utilisateur.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.errorLight,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Aide',
            textColor: Colors.white,
            onPressed: () {
              _showCredentialsHelp();
            },
          ),
        ),
      );
      // Error haptic feedback
      HapticFeedback.mediumImpact();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCredentialsHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comptes de démonstration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Utilisez ces identifiants pour tester l\'application :'),
            const SizedBox(height: 16),
            ..._mockCredentials.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value['role']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  // Updated to show username instead of email
                  Text('Nom d\'utilisateur: ${entry.key}'),
                  Text('Mot de passe: ${entry.value['password']}'),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBiometricAuth() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    // Simulate biometric authentication
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    // Simulate successful biometric auth
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Authentification biométrique réussie !'),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 8.h),
                    // Animated Logo Section
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: const MedicalLogoWidget(),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Security Notice
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const SecurityNoticeWidget(),
                    ),
                    SizedBox(height: 5.h),
                    // Login Form
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: LoginFormWidget(
                          onLogin: _handleLogin,
                          isLoading: _isLoading,
                        ),
                      ),
                    ),
                    // Biometric Authentication
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: BiometricAuthWidget(
                        onBiometricAuth: _handleBiometricAuth,
                        isAvailable: _biometricAvailable,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Footer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'EDEN Medical v1.0.0',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryLight
                                  .withValues(alpha: 0.7),
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Sécurisé • Confidentiel • Conforme HIPAA',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryLight
                                  .withValues(alpha: 0.6),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

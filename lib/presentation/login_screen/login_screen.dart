import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/login_model.dart';
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
  String? _selectedRole;

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
    'evowesau': {
      'password': 'W3QeftnR',
      'role': 'Patient',
      'name': 'MOFFO MELASSI Chamberlain'
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
    _setupSystemUI();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedRole = ModalRoute.of(context)?.settings.arguments as String?;
    print('Selected role from navigation: $_selectedRole');
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

  // Updated to handle both doctor and patient login
  Future<void> _handleLogin(String username, String password) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    
    try {
      // First try API login
      final authService = AuthService();
      final loginRequest = LoginRequest(
        username: username,
        password: password,
        rememberMe: true,
      );
      
      final response = await authService.login(loginRequest);
      
      // Store login data
      StorageService.setLoginData(
        accessToken: response.accessToken,
        userId: response.data.id,
        userRole: response.data.roles.first.name,
      );
      
      // Store user-specific data based on role
      if (response.data.roles.first.name == 'Patient') {
        if (response.data.patientId != null) {
          StorageService.setPatientId(response.data.patientId!);
        }
        StorageService.setPatientInfo(
          response.data.firstName,
          response.data.lastName,
        );
      } else {
        if (response.data.doctorId != null) {
          StorageService.setDoctorId(response.data.doctorId!);
        }
        StorageService.setDoctorInfo(
          response.data.firstName,
          response.data.lastName,
        );
      }
      
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion réussie ! Bienvenue ${response.data.firstName}'),
          backgroundColor: AppTheme.successLight,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate based on API role
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        final userRole = response.data.roles.first.name;
        print('=== LOGIN NAVIGATION DEBUG ===');
        print('User role from API: "$userRole"');
        print('Role comparison (userRole == "Patient"): ${userRole == 'Patient'}');
        print('Patient ID: ${response.data.patientId}');
        print('Doctor ID: ${response.data.doctorId}');
        
        if (userRole == 'Patient') {
          print('✅ Navigating to PATIENT dashboard: /patient-dashboard');
          Navigator.pushReplacementNamed(context, '/patient-dashboard');
        } else {
          print('✅ Navigating to DOCTOR dashboard: /dashboard');
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        print('=== END DEBUG ===');
      }
      
    } catch (e) {
      print('API login failed: $e');
      // Show clear error message
      String errorMessage = e.toString().contains('Exception:') 
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Erreur de connexion: $e';
      
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
            // Patient credentials
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Nom d\'utilisateur: EVowESau'),
                  Text('Mot de passe: W3QeftnR'),
                ],
              ),
            ),
            // Doctor credentials
            ..._mockCredentials.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value['role']!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        child: SafeArea(
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
                      // Header Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                             Container(
  width: 20.w,
  height: 20.w,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.1),
      ],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.white.withOpacity(0.2),
        blurRadius: 5,
        spreadRadius: 5,
      ),
    ],
  ),
  child: Center(
    child: Image.asset(
      'assets/images/pdmd.png',
      width: 18.w, // Same size as the original icon
      height: 18.w,
      fit: BoxFit.contain,
    ),
  ),
),
                                SizedBox(height: 3.h),
                                Text(
                                  'EDEN',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Connexion Sécurisée',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Login Form
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: Offset(0, 15),
                                ),
                              ],
                            ),
                            child: LoginFormWidget(
                              onLogin: _handleLogin,
                              isLoading: _isLoading,
                            ),
                          ),
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
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Sécurisé • Confidentiel • Conforme',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
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
      ),
    );
  }
}

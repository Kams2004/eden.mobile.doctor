import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../model/login_model.dart';
import 'package:eden_medical/presentation/dashboard/dashboard.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String username, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    Key? key,
    required this.onLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final request = LoginRequest(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
        
        final response = await _authService.login(request);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connexion réussie ! Bienvenue ${response.data.firstName}'),
              backgroundColor: AppTheme.successLight,
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de connexion: ${e.toString()}'),
              backgroundColor: AppTheme.errorLight,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username Field
TextFormField(
  controller: _usernameController,
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.next,
  enabled: !widget.isLoading,
  decoration: InputDecoration(
    labelText: 'Nom d\'utilisateur',
    // hintText: 'Votre nom d\'utilisateur',
    labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFamily: 'Lexend',
      letterSpacing: 0.0,
      color: Colors.black,
    ),
    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFamily: 'Lexend',
      letterSpacing: 0.0,
      color: Colors.black,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    filled: true,
    fillColor: Colors.black12,
    contentPadding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
    prefixIcon: Padding(
      padding: EdgeInsets.all(3.w),
      child: CustomIconWidget(
        iconName: 'person',
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 6.w,
      ),
    ),
  ),
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontFamily: 'Lexend',
    letterSpacing: 0.0,
    color: Colors.black,
  ),
  validator: _validateUsername,
  autovalidateMode: AutovalidateMode.onUserInteraction,
),
SizedBox(height: 2.h),

// Password Field
TextFormField(
  controller: _passwordController,
  obscureText: _obscurePassword,
  textInputAction: TextInputAction.done,
  enabled: !widget.isLoading,
  decoration: InputDecoration(
    labelText: 'Mot de passe',
    // hintText: 'Saisissez votre mot de passe',
    labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFamily: 'Lexend',
      letterSpacing: 0.0,
      color: Colors.black,
    ),
    hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFamily: 'Lexend',
      letterSpacing: 0.0,
      color: Colors.black,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0x00000000),
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    filled: true,
    fillColor: Colors.black12,
    contentPadding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 16),
    prefixIcon: Padding(
      padding: EdgeInsets.all(3.w),
      child: CustomIconWidget(
        iconName: 'lock',
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 6.w,
      ),
    ),
    suffixIcon: IconButton(
      onPressed: widget.isLoading
          ? null
          : () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      icon: CustomIconWidget(
        iconName: _obscurePassword ? 'visibility' : 'visibility_off',
        color: AppTheme.textSecondaryLight,
        size: 6.w,
      ),
    ),
  ),
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    fontFamily: 'Lexend',
    letterSpacing: 0.0,
    color: Colors.black,
  ),
  validator: _validatePassword,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  onFieldSubmitted: (_) => _isFormValid ? _handleLogin() : null,
),
          
          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isLoading
                  ? null
                  : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Fonctionnalité de récupération de mot de passe à venir'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Mot de passe oublié ?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          // Login Button
          SizedBox(
            height: 7.h,
            child:
ElevatedButton(
              onPressed: (_isFormValid && !widget.isLoading) ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.textSecondaryLight.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                elevation: _isFormValid ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                height: 5.w,
                width: 5.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Se connecter',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
            //  ElevatedButton(
            //   onPressed:null,
            //   // (_isFormValid && !widget.isLoading) ? _handleLogin : null,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: _isFormValid
            //         ? AppTheme.lightTheme.colorScheme.primary
            //         : AppTheme.textSecondaryLight.withValues(alpha: 0.3),
            //     foregroundColor: Colors.white,
            //     elevation: _isFormValid ? 2 : 0,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(3.w),
            //     ),
            //   ),
            //   child: widget.isLoading
            //       ? SizedBox(
            //     height: 5.w,
            //     width: 5.w,
            //     child: const CircularProgressIndicator(
            //       strokeWidth: 2,
            //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //     ),
            //   )
            //       : Text(
            //     'Se connecter',
            //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //       color: Colors.white,
            //       fontWeight: FontWeight.w600,
            //       fontSize: 16.sp,
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}

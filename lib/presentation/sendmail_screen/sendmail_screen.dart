import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../model/sendmail_model.dart';

class SendMailScreen extends StatefulWidget {
  const SendMailScreen({super.key});

  @override
  State<SendMailScreen> createState() => _SendMailScreenState();
}

class _SendMailScreenState extends State<SendMailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _federationIdController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _federationIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMail() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = SendMailRequest(
          federationId: _federationIdController.text.trim(),
        );

        final response = await _authService.sendMail(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: AppTheme.successLight,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to login screen after success
          Navigator.pushReplacementNamed(context, '/login-screen');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AppTheme.errorLight,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String? _validateFederationId(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'ID de fédération est requis';
    }
    return null;
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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(6.w),
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
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.email_outlined,
                              size: 40,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Récupération des identifiants',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Saisissez votre ID de fédération pour recevoir vos identifiants par email',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Form Section
                    Container(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Federation ID Field
                            TextFormField(
                              controller: _federationIdController,
                              enabled: !_isLoading,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Color(0xFF1E293B),
                              ),
                              decoration: InputDecoration(
                                labelText: 'ID de Fédération',
                                hintText: 'Ex: XXXMIY380BZM',
                                labelStyle: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.sp,
                                ),
                                hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12.sp,
                                ),
                                prefixIcon: Container(
                                  margin: EdgeInsets.all(3.w),
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.badge_outlined,
                                    color: Color(0xFF3B82F6),
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFF3B82F6),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              validator: _validateFederationId,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                            SizedBox(height: 4.h),

                            // Send Button
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSendMail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.send,
                                            size: 18,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            'Envoyer les identifiants',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            SizedBox(height: 3.h),
                            
                            // Back to login link
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pushReplacementNamed(context, '/login-screen'),
                              child: Text(
                                'Retour à la connexion',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
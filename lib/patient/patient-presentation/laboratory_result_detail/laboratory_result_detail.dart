import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import 'widgets/medical_disclaimer_widget.dart';
import 'widgets/result_header_widget.dart';
import 'widgets/test_results_widget.dart';
import 'widgets/qr_code_widget.dart';
import 'widgets/action_buttons_widget.dart';

class LaboratoryResultDetail extends StatefulWidget {
  const LaboratoryResultDetail({super.key});

  @override
  State<LaboratoryResultDetail> createState() => _LaboratoryResultDetailState();
}

class _LaboratoryResultDetailState extends State<LaboratoryResultDetail> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _testDetails = [];
  Map<String, dynamic>? _resultData;
  String? _error;
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _resultData == null) {
      _resultData = args;
      _loadTestDetails();
    }
  }

  Future<void> _loadTestDetails() async {
    if (_resultData == null) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      final testCode = _resultData!['name'] ?? '';
      final details = await authService.getLaboratoryDetail(testCode, accessToken);
      
      setState(() {
        _testDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildErrorWidget() {
    // Check if error contains unpaid bills message
    bool isUnpaidBillsError = _error!.contains('factures impayées') || 
                              _error!.contains('Vous avez des factures impayées');
    
    if (isUnpaidBillsError) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(6.w),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 12.w,
                  color: Color(0xFFF59E0B),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Factures Impayées',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _themeService.isDarkMode ? Colors.white : Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Vous avez des factures impayées. Veuillez les régler pour accéder à vos résultats.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF3B82F6)),
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Retour',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/patient-invoices');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Voir Factures',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    // Default error widget
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 15.w,
            color: Colors.red,
          ),
          SizedBox(height: 2.h),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _loadTestDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6)
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail du Résultat',
          style: TextStyle(
            color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, 
              color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6)
            ),
            onPressed: _loadTestDetails,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.white,
              image: !_themeService.isDarkMode ? DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ) : null,
            ),
          ),
          if (_themeService.isDarkMode)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
            ),
          if (!_themeService.isDarkMode)
            Container(
              color: Colors.white.withOpacity(0.85),
            ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                )
              : _error != null
                  ? _buildErrorWidget()
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_resultData != null) ...[
                            ResultHeaderWidget(resultData: _resultData!),
                            SizedBox(height: 3.h),
                            TestResultsWidget(testDetails: _testDetails),
                            SizedBox(height: 3.h),
                            MedicalDisclaimerWidget(),
                            SizedBox(height: 3.h),
                            QRCodeWidget(resultData: _resultData!),
                            // SizedBox(height: 3.h),
                            // ActionButtonsWidget(resultData: _resultData!),
                          ],
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}
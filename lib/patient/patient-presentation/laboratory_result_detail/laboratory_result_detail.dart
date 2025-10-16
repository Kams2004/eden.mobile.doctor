import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Détail du Résultat',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadTestDetails,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                  ? Center(
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
                                color: Colors.grey[600],
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
                    )
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
                            SizedBox(height: 3.h),
                            ActionButtonsWidget(resultData: _resultData!),
                          ],
                        ],
                      ),
                    ),
        ],
      ),
    );
  }
}
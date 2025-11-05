import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';
import '../../core/app_export.dart';
import '../widgets/doctor_professional_app_bar.dart';
import 'widgets/analyse_header_widget.dart';
import 'widgets/analyse_filter_widget.dart';
import 'widgets/analyse_summary_widget.dart';
import 'widgets/analyse_monthly_widget.dart';
import 'widgets/analyse_details_widget.dart';

class AnalysePointsPage extends StatefulWidget {
  const AnalysePointsPage({super.key});

  @override
  State<AnalysePointsPage> createState() => _AnalysePointsPageState();
}

class _AnalysePointsPageState extends State<AnalysePointsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _monthlyData;
  Map<String, dynamic>? _yearlyData;
  String? _error;
  String _selectedView = 'monthly'; // monthly or yearly
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _invoiceStatus = 'invoiced'; // invoiced or Notinvoiced
  bool _maskAmounts = false;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      if (_selectedView == 'monthly') {
        final monthlyData = await authService.getMonthlyAnalysis(
          doctorId, _selectedMonth, _invoiceStatus, accessToken
        );
        setState(() {
          _monthlyData = monthlyData;
          _isLoading = false;
        });
      } else {
        final yearlyData = await authService.getYearlyAnalysis(
          doctorId, _selectedYear, _invoiceStatus, accessToken
        );
        setState(() {
          _yearlyData = yearlyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged({
    String? view,
    int? year,
    int? month,
    String? status,
    bool? maskAmounts,
  }) {
    setState(() {
      if (view != null) _selectedView = view;
      if (year != null) _selectedYear = year;
      if (month != null) _selectedMonth = month;
      if (status != null) _invoiceStatus = status;
      if (maskAmounts != null) _maskAmounts = maskAmounts;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      appBar: DoctorProfessionalAppBar(
        title: 'Analyse des Points',
        icon: Icons.analytics,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_themeService.isDarkMode)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/overlay2.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (!_themeService.isDarkMode)
            Container(
              color: Colors.white.withOpacity(0.7),
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
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_error != null) {
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            AnalyseHeaderWidget(
              maskAmounts: _maskAmounts,
              onMaskToggle: () => _onFilterChanged(maskAmounts: !_maskAmounts),
              themeService: _themeService,
            ),
            SizedBox(height: 3.h),
            AnalyseFilterWidget(
              selectedView: _selectedView,
              selectedYear: _selectedYear,
              selectedMonth: _selectedMonth,
              invoiceStatus: _invoiceStatus,
              onFilterChanged: _onFilterChanged,
              themeService: _themeService,
            ),
            SizedBox(height: 3.h),
            if (_selectedView == 'monthly' && _monthlyData != null) ...[
              AnalyseSummaryWidget(
                data: _monthlyData!,
                isMonthly: true,
                maskAmounts: _maskAmounts,
                themeService: _themeService,
              ),
            ] else if (_selectedView == 'yearly' && _yearlyData != null) ...[
              AnalyseSummaryWidget(
                data: _yearlyData!,
                isMonthly: false,
                maskAmounts: _maskAmounts,
                themeService: _themeService,
              ),
              SizedBox(height: 3.h),
              AnalyseMonthlyWidget(
                yearlyData: _yearlyData!,
                maskAmounts: _maskAmounts,
                themeService: _themeService,
              ),
              SizedBox(height: 3.h),
              AnalyseDetailsWidget(
                yearlyData: _yearlyData!,
                maskAmounts: _maskAmounts,
                themeService: _themeService,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
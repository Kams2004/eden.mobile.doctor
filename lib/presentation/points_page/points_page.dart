import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';
import '../../core/app_export.dart';
import '../widgets/doctor_professional_app_bar.dart';
import 'widgets/points_header_widget.dart';
import 'widgets/points_filter_widget.dart';
import 'widgets/points_summary_widget.dart';
import 'widgets/points_list_widget.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _pointsData;
  String? _error;
  String _selectedFilter = 'all';
  DateTimeRange? _selectedDateRange;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
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
      
      final pointsData = await authService.getDoctorCommissions(doctorId, accessToken);
      
      setState(() {
        _pointsData = pointsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onDateRangeChanged(DateTimeRange? dateRange) {
    setState(() {
      _selectedDateRange = dateRange;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      appBar: DoctorProfessionalAppBar(
        title: 'Points & Commissions',
        icon: Icons.account_balance_wallet,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadPoints,
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
              onPressed: _loadPoints,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_pointsData == null) {
      return Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(
            fontSize: 14.sp,
            color: _themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPoints,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            PointsHeaderWidget(
              totalAmount: _pointsData!['montant_total']?.toDouble() ?? 0.0,
              themeService: _themeService,
            ),
            SizedBox(height: 3.h),
            PointsFilterWidget(
              selectedFilter: _selectedFilter,
              onFilterChanged: _onFilterChanged,
              selectedDateRange: _selectedDateRange,
              onDateRangeChanged: _onDateRangeChanged,
              themeService: _themeService,
            ),
            SizedBox(height: 3.h),
            PointsSummaryWidget(
              pointsData: _pointsData!,
              themeService: _themeService,
            ),
            SizedBox(height: 3.h),
            PointsListWidget(
              pointsData: _pointsData!,
              selectedFilter: _selectedFilter,
              selectedDateRange: _selectedDateRange,
              themeService: _themeService,
            ),
          ],
        ),
      ),
    );
  }
}
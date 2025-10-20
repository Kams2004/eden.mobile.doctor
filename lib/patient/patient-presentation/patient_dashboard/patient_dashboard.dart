import 'package:eden_medical/patient/patient-presentation/laboratory_results_list/laboratory_results_list.dart';
import 'package:eden_medical/patient/patient-presentation/imagery_results_list/imagery_results_list.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _laboratoryResults = [];
  List<Map<String, dynamic>> _imageryResults = [];
  List<Map<String, dynamic>> _explorationResults = [];
  List<Map<String, dynamic>> _notifications = [];
  String? _error;
  String _patientName = '';
  
  final Map<String, int> _resultCounts = {
    'laboratory': 0,
    'imagery': 0,
    'prescription': 0,
    'exploration': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
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
      
      // Load all results
      final laboratoryResults = await authService.getLaboratoryResults(accessToken);
      final imageryResults = await authService.getImageryResults(accessToken);
      final explorationResults = await authService.getExplorationResults(accessToken);
      
      // Load notifications (using patient ID from storage)
      final patientId = StorageService.patientId ?? 4; // Default to 4 if not found
      final notifications = await authService.getPatientNotifications(patientId, accessToken);
      
      // Get patient name from storage
      final firstName = StorageService.patientName ?? '';
      final lastName = StorageService.patientLastname ?? '';
      
      setState(() {
        _laboratoryResults = laboratoryResults;
        _imageryResults = imageryResults;
        _explorationResults = explorationResults;
        _notifications = notifications;
        _patientName = '$firstName $lastName'.trim();
        _calculateResultCounts();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _calculateResultCounts() {
    _resultCounts['laboratory'] = _laboratoryResults.length;
    _resultCounts['imagery'] = _imageryResults.length;
    _resultCounts['exploration'] = _explorationResults.length;
    _resultCounts['prescription'] = 0; // Not implemented yet
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
              onPressed: _loadDashboardData,
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

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: Color(0xFF3B82F6),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            SizedBox(height: 3.h),
            _buildStatsCard(),
            SizedBox(height: 3.h),
            _buildResultsSection(),
            SizedBox(height: 3.h),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${_patientName.isNotEmpty ? _patientName : 'Patient'}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Bienvenue sur votre espace patient',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Color(0xFF3B82F6),
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalResults = _resultCounts.values.fold(0, (sum, count) => sum + count);
    final lastUpdate = _laboratoryResults.isNotEmpty 
        ? _formatDate(_laboratoryResults.first['validation_date'])
        : 'Aucune donnée';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Résultats',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '$totalResults',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Dernière MAJ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  lastUpdate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos Résultats Médicaux',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCompactResultCard(
                    'Laboratoire',
                    _resultCounts['laboratory']!,
                    Icons.science_outlined,
                    Color(0xFF3B82F6),
                    _laboratoryResults.isNotEmpty ? _formatDate(_laboratoryResults.first['date_analysis']) : 'Aucune donnée',
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildCompactResultCard(
                    'Imagerie',
                    _resultCounts['imagery']!,
                    Icons.medical_information_outlined,
                    Color(0xFF10B981),
                    _imageryResults.isNotEmpty ? _formatDate(_imageryResults.first['validation_date']) : 'Aucune donnée',
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildCompactResultCard(
                    'Prescription',
                    _resultCounts['prescription']!,
                    Icons.receipt_outlined,
                    Color(0xFF8B5CF6),
                    'Aucune donnée',
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildCompactResultCard(
                    'Exploration',
                    _resultCounts['exploration']!,
                    Icons.search_outlined,
                    Color(0xFFF59E0B),
                    _explorationResults.isNotEmpty ? _formatDate(_explorationResults.first['validation_date']) : 'Aucune donnée',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactResultCard(String title, int count, IconData icon, Color color, String lastDate) {
    return GestureDetector(
      onTap: () {
        if (title == 'Laboratoire' && count > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LaboratoryResultsList(),
            ),
          );
        } else if (title == 'Imagerie' && count > 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageryResultsList(),
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 3.5.w,
                  ),
                ),
                Spacer(),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 1.w,
                    height: 1.w,
                    decoration: BoxDecoration(
                      color: count > 0 ? color : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      lastDate,
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actualités du Centre',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.schedule,
                size: 12.w,
                color: Colors.grey[400],
              ),
              SizedBox(height: 2.h),
              Text(
                'Service prochainement disponible',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Les actualités du centre seront bientôt disponibles ici.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Date invalide';
    }
  }

  void _handleLogout() {
    StorageService.clearData();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-dashboard',
          onLogout: _handleLogout,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF3B82F6)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'EDEN',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Color(0xFF3B82F6)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadDashboardData,
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Color(0xFF3B82F6)),
                onPressed: () {},
              ),
              if (_notifications.where((n) => !n['is_read']).isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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
            color: Colors.white.withOpacity(0.5),
          ),
          _buildBody(),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:eden_medical/patient/patient-presentation/laboratory_results_list/laboratory_results_list.dart';
import 'package:eden_medical/patient/patient-presentation/imagery_results_list/imagery_results_list.dart';
import 'package:eden_medical/patient/patient-presentation/exploration_results_list/exploration_results_list.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../../core/app_export.dart';

import '../../../base_url/api_config.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _laboratoryResults = [];
  List<Map<String, dynamic>> _imageryResults = [];
  List<Map<String, dynamic>> _explorationResults = [];
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _blogPosts = [];
  List<Map<String, dynamic>> _invoices = [];
  String? _error;
  String _patientName = '';
  late ThemeService _themeService;
  
  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  PageController? _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  
  final Map<String, int> _resultCounts = {
    'laboratory': 0,
    'imagery': 0,
    'prescription': 0,
    'exploration': 0,
  };

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _initAnimations();
    _loadDashboardData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOutCubic,
    ));
    
    _pageController = PageController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController?.dispose();
    _slideController?.dispose();
    _pageController?.dispose();
    super.dispose();
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
      final prescriptions = await authService.getAllPrescriptions(accessToken);
      
      print('Laboratory Results: $laboratoryResults');
      print('Imagery Results: $imageryResults');
      print('Exploration Results: $explorationResults');
      print('Prescriptions: $prescriptions');
      
      // Debug date fields
      if (imageryResults.isNotEmpty) {
        print('Imagery first item keys: ${imageryResults.first.keys.toList()}');
      }
      if (prescriptions.isNotEmpty) {
        print('Prescription first item keys: ${prescriptions.first.keys.toList()}');
      }
      
      // Load blog posts from API
      List<Map<String, dynamic>> blogPosts = [];
      try {
        blogPosts = await authService.getBlogPosts(accessToken);
        print('Blog Posts: $blogPosts');
      } catch (e) {
        print('Failed to load blog posts: $e');
        // Use empty list if API fails
        blogPosts = [];
      }
      
      // Load invoices
      List<Map<String, dynamic>> invoices = [];
      try {
        final patientIdForInvoices = StorageService.patientId ?? 1;
        invoices = await authService.getPatientInvoices(patientIdForInvoices, accessToken);
        print('Invoices: $invoices');
      } catch (e) {
        print('Failed to load invoices: $e');
        invoices = [];
      }
      
      // Load notifications (using patient ID from storage)
      final patientId = StorageService.patientId ?? 4;
      final notifications = await authService.getPatientNotifications(patientId, accessToken);
      
      // Get patient name from storage
      final firstName = StorageService.patientName ?? '';
      final lastName = StorageService.patientLastname ?? '';
      
      setState(() {
        _laboratoryResults = laboratoryResults;
        _imageryResults = imageryResults;
        _explorationResults = explorationResults;
        _prescriptions = prescriptions;
        _notifications = notifications;
        _blogPosts = blogPosts.where((post) => post['is_visible'] == true).toList();
        _invoices = invoices;
        _patientName = '$firstName $lastName'.trim();
        _calculateResultCounts();
        _isLoading = false;
      });
      
      // Start animations
      _fadeController?.forward();
      _slideController?.forward();
      
      // Start auto-slide for news if there are blog posts
      if (_blogPosts.isNotEmpty) {
        // Add small delay to ensure PageController is ready
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            _startAutoSlide();
          }
        });
      }
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
    _resultCounts['prescription'] = _prescriptions.length;
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ImagerySkeletonLoader(itemCount: 4);
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
        child: _fadeAnimation != null && _slideAnimation != null
            ? FadeTransition(
                opacity: _fadeAnimation!,
                child: SlideTransition(
                  position: _slideAnimation!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeHeader(),
                      SizedBox(height: 3.h),
                      _buildStatsCard(),
                      SizedBox(height: 3.h),
                      _buildResultsSection(),

                      if (_blogPosts.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        _buildNewsSection(),
                      ],
                      if (_invoices.where((invoice) => invoice['state'] != 'paid').isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        _buildBillingSection(),
                      ],
                    ],
                  ),
                ),
              )
            :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(),
                SizedBox(height: 3.h),
                _buildStatsCard(),
                SizedBox(height: 3.h),
                _buildResultsSection(),
                if (_blogPosts.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  _buildNewsSection(),
                ],
                if (_invoices.where((invoice) => invoice['state'] != 'paid').isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  _buildBillingSection(),
                ]
                
              ],
            ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[200]!, 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_themeService.isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
                    color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Bienvenue sur votre espace patient',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _themeService.isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/patient-notifications-settings');
            },
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF3B82F6),
                    size: 6.w,
                  ),
                  if (_notifications.where((n) => !(n['is_read'] ?? false)).isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalResults = _resultCounts.values.fold(0, (sum, count) => sum + count);
    final lastUpdate = _getMostRecentDate();

    return AnimatedContainer(
      duration: Duration(milliseconds: 800),
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
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
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
                      'Dernière mise à jour',
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
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: _themeService.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Consultez vos résultats d\'examens médicaux récents',
          style: TextStyle(
            fontSize: 13.sp,
            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
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
                    Color.fromARGB(255, 10, 100, 245),
                    _laboratoryResults.isNotEmpty ? _formatDate(_laboratoryResults.first['validation_date']) : 'Aucune donnée',
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildCompactResultCard(
                    'Imagerie',
                    _resultCounts['imagery']!,
                    Icons.medical_information_outlined,
                    Color.fromARGB(255, 3, 167, 112),
                    _imageryResults.isNotEmpty ? _getImageryDate(_imageryResults.first) : 'Aucune donnée',
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
                    Color.fromARGB(255, 135, 86, 250),
                    _prescriptions.isNotEmpty ? _getPrescriptionDate(_prescriptions.first) : 'Aucune donnée',
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildCompactResultCard(
                    'Exploration',
                    _resultCounts['exploration']!,
                    Icons.search_outlined,
                    Color(0xFFF59E0B),
                    _explorationResults.isNotEmpty ? _formatDate(_explorationResults.first['date_analysis']) : 'Aucune donnée',
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
        } else if (title == 'Prescription' && count > 0) {
          Navigator.pushNamed(context, '/prescription');
        } else if (title == 'Exploration' && count > 0) {
          Navigator.pushNamed(context, '/exploration-results');
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
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
                    fontSize: 20.sp,
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
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _themeService.isDarkMode ? Color(0xFFE2E8F0) : Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: Colors.white,
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
                        fontSize: 11.sp,
                        color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700],
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
        Row(
          children: [
            Icon(
              Icons.article_outlined,
              color: Color(0xFF3B82F6),
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Actualités Médicales',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Restez informé des dernières actualités et conseils médicaux',
          style: TextStyle(
            fontSize: 12.sp,
            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        _blogPosts.isEmpty ? _buildEmptyNews() : _buildBlogList(),
      ],
    );
  }

  Widget _buildEmptyNews() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[200]!, 
          width: 1
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 12.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'Aucune actualité disponible',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Les dernières actualités médicales apparaîtront ici.',
            style: TextStyle(
              fontSize: 14.sp,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

   Widget _buildBillingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF10B981),
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Mes Factures Impayées',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _themeService.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Gérez vos factures et suivez vos paiements médicaux',
          style: TextStyle(
            fontSize: 12.sp,
            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
          ),
        ),
        SizedBox(height: 2.h),
        _invoices.isEmpty ? _buildEmptyInvoices() : _buildInvoicesList(),
      ],
    );
  }

  Widget _buildEmptyInvoices() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[200]!, 
          width: 1
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 12.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'Aucune facture disponible',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Vos factures apparaîtront ici.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    // Only show unpaid invoices in dashboard
    final unpaidInvoices = _invoices.where((invoice) => invoice['state'] != 'paid').toList();
    return Column(
      children: unpaidInvoices.take(3).map((invoice) => _buildInvoiceCard(invoice)).toList(),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final isPaid = invoice['state'] == 'paid';
    final amount = double.tryParse(invoice['amount_to_pay']?.toString() ?? '0') ?? 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF334155) : Colors.grey[200]!, 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInvoiceDetails(invoice),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['invoice_number'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _formatInvoiceDate(invoice['date']),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${amount.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.green : Colors.orange[700],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPaid ? 'Payée' : 'En attente',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? Colors.green[700] : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetails(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 90.w,
            constraints: BoxConstraints(maxHeight: 80.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Détails de la facture',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInvoiceDetailRow('Numéro de facture', invoice['invoice_number'] ?? 'N/A'),
                        _buildInvoiceDetailRow('Référence', invoice['reference'] ?? 'N/A'),
                        _buildInvoiceDetailRow('Date', _formatInvoiceDate(invoice['date'])),
                        _buildInvoiceDetailRow('Statut', invoice['state'] == 'paid' ? 'Payée' : 'En attente'),
                        Divider(height: 3.h),
                        Text(
                          'Montants',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        _buildInvoiceDetailRow('Montant HT', '${(invoice['untaxed_amount'] ?? 0).toStringAsFixed(0)} FCFA'),
                        _buildInvoiceDetailRow('Montant assurance', '${invoice['montant_assurance'] ?? '0'} FCFA'),
                        _buildInvoiceDetailRow('Montant patient', '${(invoice['montant_patient'] ?? 0).toStringAsFixed(0)} FCFA'),
                        Divider(height: 2.h),
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Montant à payer',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${(double.tryParse(invoice['amount_to_pay']?.toString() ?? '0') ?? 0).toStringAsFixed(0)} FCFA',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatInvoiceDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      DateTime date;
      if (dateString.contains('GMT')) {
        final parts = dateString.split(' ');
        if (parts.length >= 5) {
          final day = parts[1];
          final month = _getMonthNumber(parts[2]);
          final year = parts[3];
          date = DateTime(int.parse(year), month, int.parse(day));
        } else {
          return 'Date invalide';
        }
      } else {
        date = DateTime.parse(dateString);
      }
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Date invalide';
    }
  }

  void _startAutoSlide() {
    if (_blogPosts.length > 1) {
      print('Starting auto-slide with ${_blogPosts.length} blog posts');
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          if (_currentIndex < _blogPosts.length - 1) {
            _currentIndex++;
          } else {
            _currentIndex = 0;
          }
          
          print('Auto-sliding to index: $_currentIndex');
          
          if (_pageController != null && _pageController!.hasClients) {
            _pageController!.animateToPage(
              _currentIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    } else {
      print('Auto-slide not started: only ${_blogPosts.length} blog posts');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBlogList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      height: 40.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _blogPosts.length,
            itemBuilder: (context, index) {
              final newsItem = _blogPosts[index];
              return _buildNewsCard(newsItem);
            },
          ),
          if (_blogPosts.length > 1)
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _blogPosts.length,
                  (index) => Container(
                    width: _currentIndex == index ? 3.w : 2.w,
                    height: _currentIndex == index ? 3.w : 2.w,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> newsItem) {
    final String title = newsItem['titre'] ?? '';
    final String description = newsItem['description'] ?? '';
    final String category = 'ACTUALITÉ';
    final Color backgroundColor = Color(0xFF3B82F6);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (newsItem['id'] != null)
              Positioned.fill(
                child: Image.network(
                  '${ApiConfig.baseUrl}/blog/image/${newsItem['id']}',
                  fit: BoxFit.cover,
                  headers: {
                    'Authorization': 'Bearer ${StorageService.accessToken}',
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.article,
                        color: Colors.white.withOpacity(0.3),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            // Content overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (category.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const Spacer(flex: 1),
                  // Title
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // Description
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // Action button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => _handleVoirPlus(newsItem),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                        minimumSize: Size(0, 4.h),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Voir plus',
                            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
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

  void _handleVoirPlus(Map<String, dynamic> newsItem) {
    // Handle news item tap
    print('Tapped on news: ${newsItem['titre']}');
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      print('Date is null or empty: $dateString');
      return 'Non disponible';
    }
    try {
      print('Parsing date: $dateString');
      DateTime date;
      
      // Handle different date formats
      if (dateString.contains('GMT')) {
        // Format: "Wed, 19 Mar 2025 15:23:21 GMT"
        // Convert to ISO format: "2025-03-19T15:23:21.000Z"
        final parts = dateString.split(' ');
        if (parts.length >= 5) {
          final day = parts[1];
          final month = _getMonthNumber(parts[2]);
          final year = parts[3];
          final time = parts[4];
          
          final isoDate = '$year-${month.toString().padLeft(2, '0')}-${day.padLeft(2, '0')}T$time.000Z';
          print('Converted to ISO: $isoDate');
          date = DateTime.parse(isoDate);
        } else {
          throw FormatException('Invalid GMT date format');
        }
      } else {
        date = DateTime.parse(dateString);
      }
      
      final formatted = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      print('Formatted date: $formatted');
      return formatted;
    } catch (e) {
      print('Date parsing error: $e for date: $dateString');
      return 'Date invalide';
    }
  }
  
  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1E40AF),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 12.w,
              color: Colors.white,
            ),
            SizedBox(height: 1.h),
            Text(
              'Actualité',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBlogDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    try {
      final date = DateTime.parse(dateString.replaceAll('GMT', '').trim());
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}j';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inMinutes}min';
      }
    } catch (e) {
      return 'Récent';
    }
  }

  String _getImageryDate(Map<String, dynamic> imagery) {
    // Try different possible date field names for imagery
    final possibleFields = ['date_analysis', 'validation_date', 'created_at', 'date_created', 'date', 'updated_at'];
    
    for (String field in possibleFields) {
      if (imagery[field] != null) {
        print('Found imagery date field: $field = ${imagery[field]}');
        return _formatDate(imagery[field]);
      }
    }
    
    print('No date field found in imagery: ${imagery.keys.toList()}');
    return 'Aucune donnée';
  }

  String _getPrescriptionDate(Map<String, dynamic> prescription) {
    // Based on API response, the field is 'Create_date'
    if (prescription['Create_date'] != null) {
      return _formatDate(prescription['Create_date']);
    }
    
    return 'Aucune donnée';
  }

  String _getMostRecentDate() {
    List<DateTime> dates = [];
    
    // Laboratory results
    for (var result in _laboratoryResults) {
      if (result['validation_date'] != null) {
        try {
          dates.add(_parseDate(result['validation_date']));
        } catch (e) {}
      }
    }
    
    // Imagery results
    for (var result in _imageryResults) {
      if (result['date_analysis'] != null) {
        try {
          dates.add(_parseDate(result['date_analysis']));
        } catch (e) {}
      }
    }
    
    // Prescriptions
    for (var result in _prescriptions) {
      if (result['Create_date'] != null) {
        try {
          dates.add(_parseDate(result['Create_date']));
        } catch (e) {}
      }
    }
    
    // Exploration results
    for (var result in _explorationResults) {
      if (result['date_analysis'] != null) {
        try {
          dates.add(_parseDate(result['date_analysis']));
        } catch (e) {}
      }
    }
    
    if (dates.isEmpty) return 'Aucune donnée';
    
    // Find the most recent date
    dates.sort((a, b) => b.compareTo(a));
    DateTime mostRecent = dates.first;
    
    // Format as "Fri, 18 Jul 2025"
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    String weekday = weekdays[mostRecent.weekday - 1];
    String day = mostRecent.day.toString();
    String month = months[mostRecent.month - 1];
    String year = mostRecent.year.toString();
    
    return '$weekday, $day $month $year';
  }
  
  DateTime _parseDate(String dateString) {
    if (dateString.contains('GMT')) {
      final parts = dateString.split(' ');
      if (parts.length >= 5) {
        final day = int.parse(parts[1]);
        final month = _getMonthNumber(parts[2]);
        final year = int.parse(parts[3]);
        return DateTime(year, month, day);
      }
    }
    return DateTime.parse(dateString);
  }

  Future<void> _handleLogout() async {
    try {
      final accessToken = StorageService.accessToken;
      if (accessToken != null) {
        final authService = AuthService();
        await authService.logout(accessToken);
      }
    } catch (e) {
      print('Logout API error (continuing anyway): $e');
    }
    
    // Always clear data and navigate, regardless of API response
    StorageService.clearData();
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/role-selection',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-dashboard',
          onLogout: _handleLogout,
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(8.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF1E40AF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: Builder(
              builder: (context) => Container(
                margin: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white, size: 6.w),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/pdmd.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'P',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EDEN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Espace Patient',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.translate, color: Colors.white, size: 5.w),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Traduction bientôt disponible'),
                        backgroundColor: Color(0xFF3B82F6),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined,
                    color: Colors.white,
                    size: 5.w,
                  ),
                  onPressed: () {
                    setState(() {
                      _themeService.toggleTheme();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _themeService.isDarkMode 
                              ? 'Mode sombre activé' 
                              : 'Mode clair activé'
                        ),
                        backgroundColor: Color(0xFF3B82F6),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 2.w, left: 1.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
                  onPressed: _loadDashboardData,
                ),
              ),
            ],
          ),
        ),
      ),
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
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
              _buildBody(),
            ],
          ),
        );
  }
}
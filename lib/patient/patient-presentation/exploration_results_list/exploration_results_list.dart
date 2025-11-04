import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';
import 'widgets/exploration_card.dart';
import 'widgets/exploration_empty_state.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class ExplorationResultsList extends StatefulWidget {
  const ExplorationResultsList({super.key});

  @override
  State<ExplorationResultsList> createState() => _ExplorationResultsListState();
}

class _ExplorationResultsListState extends State<ExplorationResultsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _explorationResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  String? _error;
  String _selectedFilter = 'Tous';
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _loadExplorationResults();
  }

  Future<void> _loadExplorationResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      final results = await authService.getExplorationResults(accessToken);
      
      setState(() {
        _explorationResults = results;
        _filteredResults = results;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isExpired(Map<String, dynamic> result) {
    final statutExpiration = result['statut_expiration'];
    final expirationDate = result['expiration_date'];
    
    if (statutExpiration == true || (expirationDate != null && DateTime.now().isAfter(_parseDate(expirationDate)))) {
      return true;
    }
    return false;
  }
  
  DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return DateTime.now();
    try {
      if (dateString.contains('GMT')) {
        final parts = dateString.split(' ');
        if (parts.length >= 5) {
          final day = int.parse(parts[1]);
          final month = _getMonthNumber(parts[2]);
          final year = int.parse(parts[3]);
          final timeParts = parts[4].split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          return DateTime(year, month, day, hour, minute);
        }
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
  
  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedFilter) {
        case 'Tous':
          _filteredResults = _explorationResults;
          break;
        case 'Terminé':
          _filteredResults = _explorationResults.where((result) => result['state'] == 'validated').toList();
          break;
        case 'En cours':
          _filteredResults = _explorationResults.where((result) => result['state'] != 'validated').toList();
          break;
        case 'Expiré':
          _filteredResults = _explorationResults.where((result) => _isExpired(result)).toList();
          break;
        case 'Non expiré':
          _filteredResults = _explorationResults.where((result) => !_isExpired(result)).toList();
          break;
      }
    });
  }

  Widget _buildFilterChips() {
    final filters = ['Tous', 'Terminé', 'En cours', 'Expiré', 'Non expiré'];
    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                _applyFilter();
              },
              backgroundColor: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
              selectedColor: Color(0xFF3B82F6),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? Color(0xFF3B82F6) : Color(0xFF3B82F6).withOpacity(0.3),
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }
  
  int _getDaysUntilExpiration(Map<String, dynamic> result) {
    final expirationDate = result['expiration_date'];
    if (expirationDate == null) {
      final dateAnalysis = result['date_analysis'] ?? result['date_requested'];
      if (dateAnalysis != null) {
        final analysisDate = _parseDate(dateAnalysis);
        final expiration = analysisDate.add(Duration(days: 7));
        return expiration.difference(DateTime.now()).inDays;
      }
      return 7;
    }
    return _parseDate(expirationDate).difference(DateTime.now()).inDays;
  }

  Widget _buildExpirationWarning() {
    if (_filteredResults.isEmpty) return SizedBox.shrink();
    
    int minDaysLeft = 8;
    bool hasExpiredResults = false;
    
    for (var result in _filteredResults) {
      if (_isExpired(result)) {
        hasExpiredResults = true;
      } else {
        final daysLeft = _getDaysUntilExpiration(result);
        if (daysLeft <= 7 && daysLeft < minDaysLeft) {
          minDaysLeft = daysLeft;
        }
      }
    }
    
    if (!hasExpiredResults && minDaysLeft > 7) return SizedBox.shrink();
    
    String message;
    if (hasExpiredResults && minDaysLeft <= 7) {
      if (minDaysLeft <= 0) {
        message = 'Certains résultats ont expiré et d\'autres expirent bientôt.';
      } else if (minDaysLeft == 1) {
        message = 'Certains résultats ont expiré et d\'autres expirent dans 1 jour.';
      } else {
        message = 'Certains résultats ont expiré et d\'autres expirent dans $minDaysLeft jours.';
      }
    } else if (hasExpiredResults) {
      message = 'Certains résultats ont expiré et ne sont plus accessibles.';
    } else if (minDaysLeft <= 0) {
      message = 'Certains résultats expirent aujourd\'hui.';
    } else if (minDaysLeft == 1) {
      message = 'Certains résultats expirent dans 1 jour.';
    } else {
      message = 'Certains résultats expirent dans $minDaysLeft jours.';
    }
    
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _themeService.isDarkMode ? Color(0xFF9CA3AF) : Colors.grey[700],
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Information importante',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _themeService.isDarkMode ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/exploration-results',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Résultats d\'Exploration',
        subtitle: 'Examens fonctionnels',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadExplorationResults,
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
          _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return ImagerySkeletonLoader(itemCount: 6);
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
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadExplorationResults,
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

    if (_explorationResults.isEmpty) {
      return ExplorationEmptyState(
        onRefresh: _loadExplorationResults,
      );
    }

    return Column(
      children: [
        _buildExpirationWarning(),
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadExplorationResults,
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                return ExplorationCard(
                  exploration: _filteredResults[index],
                  isExpired: _isExpired(_filteredResults[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
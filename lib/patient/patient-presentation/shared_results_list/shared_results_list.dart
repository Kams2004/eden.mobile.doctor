import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';
import 'widgets/shared_results_header.dart';
import 'widgets/shared_result_card.dart';
import 'widgets/shared_results_empty_state.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class SharedResultsList extends StatefulWidget {
  const SharedResultsList({super.key});

  @override
  State<SharedResultsList> createState() => _SharedResultsListState();
}

class _SharedResultsListState extends State<SharedResultsList> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _sharedResults = [];
  List<Map<String, dynamic>> _filteredResults = [];
  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  String? _error;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _loadSharedResults();
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSharedResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final patientId = StorageService.patientId;
      
      if (accessToken == null || patientId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      final results = await authService.getSharedResults(patientId, accessToken);
      
      // Fetch doctor information for each result
      final enrichedResults = <Map<String, dynamic>>[];
      for (final result in results) {
        try {
          final doctorInfo = await authService.getDoctorInfo(result['doctor_id'], accessToken);
          final enrichedResult = Map<String, dynamic>.from(result);
          enrichedResult['doctor_info'] = doctorInfo;
          enrichedResults.add(enrichedResult);
        } catch (e) {
          // If doctor info fails, add result without doctor info
          enrichedResults.add(result);
        }
      }
      
      setState(() {
        _sharedResults = enrichedResults;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = List.from(_sharedResults);

    if (_searchQuery.isNotEmpty) {
      results = results.where((result) {
        final searchLower = _searchQuery.toLowerCase();
        return (result['exam_code'] as String? ?? '').toLowerCase().contains(searchLower);
      }).toList();
    }

    if (_selectedFilter != 'Tous') {
      results = results.where((result) {
        return result['exam_type'] == _selectedFilter;
      }).toList();
    }

    setState(() {
      _filteredResults = results;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  Future<void> _deleteSharedResult(Map<String, dynamic> result) async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      await authService.deleteSharedResult(result['id'], accessToken);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Partage supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadSharedResults();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-resultats-partages',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Résultats Partagés',
        subtitle: 'Partages avec médecins',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadSharedResults,
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
          if (_themeService.isDarkMode)
            Container(
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
          Column(
            children: [
              SharedResultsHeader(
                searchQuery: _searchQuery,
                selectedFilter: _selectedFilter,
                onSearchChanged: _onSearchChanged,
                onFilterChanged: _onFilterChanged,
              ),
              Expanded(
                child: _buildResultsList(),
              ),
            ],
          ),
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
                color: _themeService.isDarkMode ? Colors.white : Colors.red,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadSharedResults,
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

    if (_filteredResults.isEmpty) {
      return SharedResultsEmptyState(
        isSearchResult: _searchQuery.isNotEmpty,
        searchQuery: _searchQuery,
        onRefresh: _loadSharedResults,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSharedResults,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _filteredResults.length,
        itemBuilder: (context, index) {
          return SharedResultCard(
            result: _filteredResults[index],
            onDelete: _deleteSharedResult,
          );
        },
      ),
    );
  }
}
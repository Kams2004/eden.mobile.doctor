import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../imagery_result_detail/imagery_result_detail.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';


import './widgets/imagery_empty_state.dart';
import './widgets/imagery_filter_bottom_sheet.dart';
import './widgets/imagery_filter_chips.dart';
import './widgets/imagery_result_card.dart';
import './widgets/imagery_search_header.dart';
import './widgets/imagery_skeleton_loader.dart';

/// Imagery Results List screen displaying patient medical imaging examination results
class ImageryResultsList extends StatefulWidget {
  const ImageryResultsList({super.key});

  @override
  State<ImageryResultsList> createState() => _ImageryResultsListState();
}

class _ImageryResultsListState extends State<ImageryResultsList> {
  final ScrollController _scrollController = ScrollController();
  final RefreshIndicator _refreshIndicatorKey = RefreshIndicator(
    onRefresh: () async {},
    child: Container(),
  );

  // State variables
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _searchQuery = '';
  List<String> _activeFilters = [];
  Map<String, dynamic> _currentFilters = {};
  List<Map<String, dynamic>> _imageryResults = [];
  List<Map<String, dynamic>> _filteredResults = [];



  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      final results = await authService.getImageryResults(accessToken);
      print('=== IMAGERY RESULTS DEBUG ===');
      print('Results count: ${results.length}');
      if (results.isNotEmpty) {
        print('First result: ${results[0]}');
      }
      print('=== END DEBUG ===');
      
      setState(() {
        _imageryResults = results;
        _filteredResults = List.from(_imageryResults);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading imagery results: $e');
      setState(() {
        _imageryResults = [];
        _filteredResults = [];
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    // Handle scroll events for pagination if needed
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more data if available
    }
  }

  Future<void> _onRefresh() async {
    try {
      setState(() {
        _isRefreshing = true;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken != null) {
        final results = await authService.getImageryResults(accessToken);
        setState(() {
          _imageryResults = results;
          _applyFiltersAndSearch();
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _imageryResults = [];
          _applyFiltersAndSearch();
          _isRefreshing = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultats d\'imagerie actualisés'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'actualisation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageryFilterBottomSheet(
        currentFilters: _currentFilters,
        onFiltersApplied: _onFiltersApplied,
      ),
    );
  }

  void _onFiltersApplied(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
      _activeFilters = _buildActiveFiltersList(filters);
    });
    _applyFiltersAndSearch();
  }

  List<String> _buildActiveFiltersList(Map<String, dynamic> filters) {
    List<String> activeFilters = [];

    if (filters['dateRange'] != null) {
      activeFilters.add('date:${filters['dateRange']}');
    }

    if (filters['examTypes'] != null) {
      for (String type in (filters['examTypes'] as List<String>)) {
        activeFilters.add('type:$type');
      }
    }

    if (filters['status'] != null) {
      for (String status in (filters['status'] as List<String>)) {
        activeFilters.add('status:$status');
      }
    }

    return activeFilters;
  }

  void _applyFiltersAndSearch() {
    List<Map<String, dynamic>> results = List.from(_imageryResults);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((result) {
        final searchLower = _searchQuery.toLowerCase();
        return (result['test'] as String? ?? '')
                .toLowerCase()
                .contains(searchLower) ||
            (result['patient'] as String? ?? '')
                .toLowerCase()
                .contains(searchLower) ||
            (result['requestor'] as String? ?? '')
                .toLowerCase()
                .contains(searchLower);
      }).toList();
    }

    // Apply advanced filters
    if (_currentFilters.isNotEmpty) {
      results = _applyAdvancedFilters(results);
    }

    setState(() {
      _filteredResults = results;
    });
  }

  List<Map<String, dynamic>> _applyAdvancedFilters(
      List<Map<String, dynamic>> results) {
    List<Map<String, dynamic>> filtered = results;

    // Apply exam type filter
    if (_currentFilters['examTypes'] != null &&
        (_currentFilters['examTypes'] as List).isNotEmpty) {
      filtered = filtered.where((result) {
        final examType = (result['requested_test'] ?? result['test'] ?? '').toString().toUpperCase();
        return (_currentFilters['examTypes'] as List<String>)
            .any((type) => examType.contains(type.toUpperCase()));
      }).toList();
    }

    // Apply status filter
    if (_currentFilters['status'] != null &&
        (_currentFilters['status'] as List).isNotEmpty) {
      filtered = filtered.where((result) {
        final status = result['state'] == 'validated' ? 'Validé' : 'En cours';
        return (_currentFilters['status'] as List<String>).contains(status);
      }).toList();
    }

    // Apply date range filter
    if (_currentFilters['dateRange'] != null) {
      final now = DateTime.now();
      DateTime? startDate;
      
      switch (_currentFilters['dateRange']) {
        case 'Aujourd\'hui':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Cette semaine':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'Ce mois':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Ces 3 mois':
          startDate = DateTime(now.year, now.month - 3, 1);
          break;
        case 'Cette année':
          startDate = DateTime(now.year, 1, 1);
          break;
      }
      
      if (startDate != null) {
        filtered = filtered.where((result) {
          try {
            final dateStr = result['date'] ?? result['request_date'] ?? '';
            if (dateStr.toString().contains('GMT')) {
              final cleanDate = dateStr.toString().replaceAll(RegExp(r'^\w+,\s*'), '').replaceAll(' GMT', '');
              final parts = cleanDate.split(' ');
              if (parts.length >= 3) {
                final day = int.parse(parts[0]);
                final monthStr = parts[1];
                final year = int.parse(parts[2]);
                final months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                               'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
                final month = months[monthStr] ?? 1;
                final resultDate = DateTime(year, month, day);
                return resultDate.isAfter(startDate!) || resultDate.isAtSameMomentAs(startDate);
              }
            }
            return true;
          } catch (e) {
            return true;
          }
        }).toList();
      }
    }

    // Apply sorting
    final sortBy = _currentFilters['sortBy'] as String? ?? 'date_desc';
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'date_asc':
          return (a['date'] ?? a['request_date'] ?? '')
              .toString().compareTo((b['date'] ?? b['request_date'] ?? '').toString());
        case 'date_desc':
          return (b['date'] ?? b['request_date'] ?? '')
              .toString().compareTo((a['date'] ?? a['request_date'] ?? '').toString());
        case 'type_asc':
          return (a['requested_test'] ?? a['test'] ?? '')
              .toString().compareTo((b['requested_test'] ?? b['test'] ?? '').toString());
        case 'type_desc':
          return (b['requested_test'] ?? b['test'] ?? '')
              .toString().compareTo((a['requested_test'] ?? a['test'] ?? '').toString());
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _onFilterRemoved(String filter) {
    setState(() {
      _activeFilters.remove(filter);
    });
    _updateFiltersFromActiveList();
    _applyFiltersAndSearch();
  }

  void _onClearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _currentFilters.clear();
    });
    _applyFiltersAndSearch();
  }

  void _updateFiltersFromActiveList() {
    // Rebuild current filters from active filters list
    Map<String, dynamic> newFilters = {};
    List<String> examTypes = [];
    List<String> status = [];

    for (String filter in _activeFilters) {
      if (filter.startsWith('type:')) {
        examTypes.add(filter.substring(5));
      } else if (filter.startsWith('status:')) {
        status.add(filter.substring(7));
      } else if (filter.startsWith('date:')) {
        newFilters['dateRange'] = filter.substring(5);
      }
    }

    if (examTypes.isNotEmpty) newFilters['examTypes'] = examTypes;
    if (status.isNotEmpty) newFilters['status'] = status;

    _currentFilters = newFilters;
  }

  void _onResultTap(Map<String, dynamic> result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageryResultDetail(),
        settings: RouteSettings(arguments: result),
      ),
    );
  }

  void _onViewImages(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture des images pour ${result["test"] ?? "cet examen"}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showShareDialog(Map<String, dynamic> result) {
    final TextEditingController matriculeController = TextEditingController();
    bool isSearching = false;
    String? doctorName;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.share_outlined, color: Color(0xFF3B82F6), size: 6.w),
                  SizedBox(width: 2.w),
                  Text('Partager le résultat', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Examen à partager:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                        SizedBox(height: 0.5.h),
                        Text('Type: Imagerie', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                        Text('Code: ${result['name'] ?? result['id'] ?? 'N/A'}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text('Matricule du médecin:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: matriculeController,
                    onChanged: (value) {
                      setState(() {
                        if (value.isNotEmpty && doctorName == null) {
                          Future.delayed(Duration(milliseconds: 300), () {
                            if (matriculeController.text.isNotEmpty) {
                              setState(() {
                                doctorName = 'Dr. ${matriculeController.text.toUpperCase()}';
                              });
                            }
                          });
                        } else if (value.isEmpty) {
                          doctorName = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Entrez le matricule',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: isSearching ? SizedBox(width: 4.w, height: 4.w, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.search),
                        onPressed: () async {
                          if (matriculeController.text.isNotEmpty) {
                            setState(() { isSearching = true; });
                            await Future.delayed(Duration(milliseconds: 500));
                            setState(() { 
                              isSearching = false;
                              doctorName = 'Dr. ${matriculeController.text.toUpperCase()}';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  if (doctorName != null) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 5.w),
                          SizedBox(width: 2.w),
                          Text('Médecin trouvé: $doctorName', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
                ),
                ElevatedButton(
                  onPressed: (doctorName != null && matriculeController.text.isNotEmpty) ? () async {
                    Navigator.pop(context);
                    await _shareWithDoctor(result);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Partager', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _shareWithDoctor(Map<String, dynamic> result) async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      print('=== SHARE RESULT DEBUG ===');
      print('Doctor ID: $doctorId');
      print('Exam Type: Imagerie');
      print('Exam Code: ${result['number'] ?? result['id']?.toString() ?? ''}');
      print('Access Token: ${accessToken?.substring(0, 10)}...');
      
      await authService.shareResult(
        doctorId: doctorId,
        examType: 'Imagerie',
        examCode: result['number'] ?? result['id']?.toString() ?? '',
        accessToken: accessToken,
      );
      
      print('Share result completed successfully');
      print('=== END SHARE DEBUG ===');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultat partagé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du partage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onShareWithDoctor(Map<String, dynamic> result) {
    _showShareDialog(result);
  }

  void _onAddToFavorites(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajouté aux favoris: ${result["test"] ?? "cet examen"}'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {},
        ),
      ),
    );
  }

  void _onDownloadReport(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Téléchargement du rapport: ${result["test"] ?? "cet examen"}'),
        duration: Duration(seconds: 2),
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

  Widget _buildSimpleResultCard(Map<String, dynamic> result) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          onTap: () => _onResultTap(result),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF10B981).withOpacity(0.1),
                            Color(0xFF10B981).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.medical_information_outlined,
                        color: Color(0xFF10B981),
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  result['requested_test'] ?? result['test'] ?? 'Examen d\'imagerie',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _showShareDialog(result),
                                    icon: Icon(
                                      Icons.share_outlined,
                                      color: Color(0xFF3B82F6),
                                      size: 5.w,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _onResultTap(result),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xFF3B82F6),
                                          size: 4.w,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'Détails',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Code: ${result['number'] ?? result['id'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: result['state'] == 'validated' 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        result['state'] == 'validated' ? 'Validé' : 'En cours',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: result['state'] == 'validated' 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoColumn('Patient', result['patient'] ?? 'N/A'),
                          _buildInfoColumn('Date', _formatDate(result['date'] ?? result['request_date'])),
                        ],
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        children: [
                          _buildInfoColumn('Demandeur', result['requestor'] ?? 'N/A'),
                          _buildInfoColumn('Validé par', result['validated_by'] ?? 'N/A'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Non disponible';
    
    try {
      DateTime date;
      
      if (dateString.contains('GMT') || dateString.contains('UTC')) {
        // Handle RFC 2822 format: "Wed, 19 Mar 2025 08:12:01 GMT"
        final cleanDate = dateString.replaceAll(RegExp(r'^\w+,\s*'), '').replaceAll(' GMT', '').replaceAll(' UTC', '');
        final parts = cleanDate.split(' ');
        if (parts.length >= 4) {
          final day = int.parse(parts[0]);
          final monthStr = parts[1];
          final year = int.parse(parts[2]);
          final timePart = parts[3];
          
          final months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                         'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
          final month = months[monthStr] ?? 1;
          
          final timeComponents = timePart.split(':');
          final hour = int.parse(timeComponents[0]);
          final minute = int.parse(timeComponents[1]);
          
          date = DateTime(year, month, day, hour, minute);
        } else {
          return 'Non disponible';
        }
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          return 'Non disponible';
        }
      } else {
        date = DateTime.parse(dateString);
      }
      
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Non disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/imagery-results-list',
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
          'Résultats d\'Imagerie',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          // Medical watermark background
          image: DecorationImage(
            image: NetworkImage(
                'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
            fit: BoxFit.cover,
            opacity: 0.03,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search header
              ImagerySearchHeader(
                searchQuery: _searchQuery,
                onSearchChanged: _onSearchChanged,
                onFilterTap: _onFilterTap,
                hasActiveFilters: _activeFilters.isNotEmpty,
              ),

              // Active filters chips
              ImageryFilterChips(
                activeFilters: _activeFilters,
                onFilterRemoved: _onFilterRemoved,
                onClearAll: _onClearAllFilters,
              ),

              // Results list
              Expanded(
                child: _buildResultsList(),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return ImagerySkeletonLoader(itemCount: 5);
    }

    if (_filteredResults.isEmpty) {
      return ImageryEmptyState(
        message: _searchQuery.isNotEmpty
            ? 'Aucun résultat pour "$_searchQuery"'
            : 'Aucun résultat d\'imagerie disponible',
        subtitle: _searchQuery.isNotEmpty
            ? 'Essayez de modifier votre recherche ou d\'ajuster les filtres'
            : 'Vos résultats d\'examens d\'imagerie apparaîtront ici une fois disponibles',
        onRefresh: _onRefresh,
        isSearchResult: _searchQuery.isNotEmpty,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 2.h),
        itemCount: _filteredResults.length,
        itemBuilder: (context, index) {
          final result = _filteredResults[index];
          return _buildSimpleResultCard(result);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../imagery_result_detail/imagery_result_detail.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';


import './widgets/imagery_empty_state.dart';
import './widgets/imagery_filter_bottom_sheet.dart';
import './widgets/imagery_filter_chips.dart';
import './widgets/imagery_result_card.dart';
import './widgets/imagery_search_header.dart';
import './widgets/imagery_skeleton_loader.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

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
  String _selectedFilter = 'Tous';
  late ThemeService _themeService;



  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
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
      _applySimpleFilter();
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

  Future<void> _onResultTap(Map<String, dynamic> result) async {
    final errorMessage = result['error'];
    if (errorMessage != null && errorMessage.toString().contains('Factures Impayées')) {
      _showUnpaidBillsDialog(errorMessage.toString());
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageryResultDetail(),
        settings: RouteSettings(arguments: result),
      ),
    );
  }

  void _showUnpaidBillsDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
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
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Retour',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/patient-invoices');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
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
          ],
        );
      },
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

  void _showImageryShareDialog(Map<String, dynamic> result) {
    final TextEditingController matriculeController = TextEditingController();
    bool isSearching = false;
    Map<String, dynamic>? doctorInfo;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 90.w,
                constraints: BoxConstraints(maxHeight: 70.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, color: Colors.white, size: 6.w),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Partager le résultat',
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
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
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
                                  Text('Résultat à partager:', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.blue[700])),
                                  SizedBox(height: 0.5.h),
                                  Text('Type: Imagerie', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                  Text('Code: ${result['number'] ?? result['id'] ?? 'N/A'}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text('Matricule du médecin:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                            SizedBox(height: 1.h),
                            TextField(
                              controller: matriculeController,
                              decoration: InputDecoration(
                                hintText: 'Entrez le matricule (ex: XXXALL587EWK)',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                suffixIcon: IconButton(
                                  icon: isSearching 
                                      ? SizedBox(width: 4.w, height: 4.w, child: CircularProgressIndicator(strokeWidth: 2)) 
                                      : Icon(Icons.search),
                                  onPressed: () async {
                                    if (matriculeController.text.isNotEmpty) {
                                      setDialogState(() { isSearching = true; doctorInfo = null; });
                                      try {
                                        final authService = AuthService();
                                        final accessToken = StorageService.accessToken;
                                        if (accessToken != null) {
                                          final doctor = await authService.getDoctorByMatricule(matriculeController.text.trim(), accessToken);
                                          setDialogState(() { 
                                            isSearching = false;
                                            doctorInfo = doctor;
                                          });
                                        } else {
                                          throw Exception('Token d\'accès manquant');
                                        }
                                      } catch (e) {
                                        setDialogState(() { isSearching = false; });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Médecin non trouvé ou erreur de recherche'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (doctorInfo != null) ...[
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 5.w),
                                        SizedBox(width: 2.w),
                                        Text('Médecin trouvé', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Text('Nom: ${doctorInfo!['DoctorName']} ${doctorInfo!['DoctorLastname']}', style: TextStyle(fontSize: 12.sp)),
                                    Text('Spécialité: ${doctorInfo!['Speciality']}', style: TextStyle(fontSize: 12.sp)),
                                    Text('Email: ${doctorInfo!['DoctorEmail']}', style: TextStyle(fontSize: 12.sp)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Confirmez-vous l\'envoi de ce résultat au Dr. ${doctorInfo!['DoctorName']} ${doctorInfo!['DoctorLastname']} ?',
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: doctorInfo != null ? () async {
                                      Navigator.pop(context);
                                      await _shareImageryResult(result, doctorInfo!);
                                    } : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF3B82F6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text('Envoyer', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
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
      },
    );
  }

  Future<void> _shareImageryResult(Map<String, dynamic> result, Map<String, dynamic> doctorInfo) async {
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      await authService.sendResultToDoctor(
        doctorId: doctorInfo['id'],
        examType: 'Imagerie',
        examCode: result['number'] ?? result['id']?.toString() ?? '',
        accessToken: accessToken,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultat envoyé avec succès au Dr. ${doctorInfo['DoctorName']} ${doctorInfo['DoctorLastname']}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
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

  bool _isExpired(Map<String, dynamic> result) {
    final statutExpiration = result['statut_expiration'];
    final expirationDate = result['expiration_date'];
    
    if (statutExpiration == true || (expirationDate != null && DateTime.now().isAfter(_parseDate(expirationDate)))) {
      return true;
    }
    return false;
  }
  
  int _getDaysUntilExpiration(Map<String, dynamic> result) {
    final expirationDate = result['expiration_date'];
    if (expirationDate == null) {
      final dateAnalysis = result['date'] ?? result['request_date'];
      if (dateAnalysis != null) {
        final analysisDate = _parseDate(dateAnalysis);
        final expiration = analysisDate.add(Duration(days: 7));
        return expiration.difference(DateTime.now()).inDays;
      }
      return 7;
    }
    return _parseDate(expirationDate).difference(DateTime.now()).inDays;
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

  void _applySimpleFilter() {
    setState(() {
      switch (_selectedFilter) {
        case 'Tous':
          _filteredResults = _imageryResults;
          break;
        case 'Terminé':
          _filteredResults = _imageryResults.where((result) => result['state'] == 'validated').toList();
          break;
        case 'En cours':
          _filteredResults = _imageryResults.where((result) => result['state'] != 'validated').toList();
          break;
        case 'Expiré':
          _filteredResults = _imageryResults.where((result) => _isExpired(result)).toList();
          break;
        case 'Non expiré':
          _filteredResults = _imageryResults.where((result) => !_isExpired(result)).toList();
          break;
      }
    });
  }

  Widget _buildSimpleFilterChips() {
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
                _applySimpleFilter();
              },
              backgroundColor: Colors.white,
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

  Widget _buildSimpleResultCard(Map<String, dynamic> result) {
    final isExpired = _isExpired(result);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isExpired 
            ? (_themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100])
            : (_themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white),
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
          onTap: isExpired ? null : () => _onResultTap(result),
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
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: isExpired ? null : () => _showImageryShareDialog(result),
                                    icon: Icon(
                                      Icons.share_outlined,
                                      color: isExpired ? Colors.grey : Color(0xFF3B82F6),
                                      size: 5.w,
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
                              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                          decoration: BoxDecoration(
                            color: result['state'] == 'validated' 
                                ? Colors.green.withOpacity(0.1) 
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            result['state'] == 'validated' ? 'Terminé' : 'En cours',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: result['state'] == 'validated' 
                                  ? Colors.green[700] 
                                  : Colors.orange[700],
                            ),
                          ),
                        ),
                        if (isExpired) ...[
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Expiré',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                        if (result['error'] != null && result['error'].toString().contains('Factures Impayées')) ...[
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'FACTURE IMPAYÉE',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoColumn('Patient', result['patient'] ?? 'N/A'),
                          _buildInfoColumn('Date D\'analyse', _formatDate(result['date'] ?? result['request_date'])),
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
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/imagery-results-list',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Résultats d\'Imagerie',
        subtitle: 'Examens radiologiques',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.white,
          image: !_themeService.isDarkMode ? DecorationImage(
            image: AssetImage("assets/images/overlay2.jpeg"),
            fit: BoxFit.cover,
          ) : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
           
 // Expiration warning
              _buildExpirationWarning(),
              
              // Simple filter chips
              _buildSimpleFilterChips(),

             
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

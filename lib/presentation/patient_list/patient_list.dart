import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/patients_model.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/month_navigation_widget.dart';
import './widgets/grouped_patient_card_widget.dart';
import './widgets/search_bar_widget.dart';

class PatientList extends StatefulWidget {
  const PatientList({Key? key}) : super(key: key);

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _authService = AuthService();

  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  Map<String, dynamic> _activeFilters = {};
  String _searchQuery = '';
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = false;
  double _totalCommission = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = StorageService.accessToken;
      final userId = StorageService.userId;
      
      if (accessToken == null || userId == null) {
        throw Exception('Token d\'accès manquant');
      }

      // Use stored doctor ID or fetch profile as fallback
      final storedDoctorId = StorageService.doctorId;
      final PatientsResponse response;
      
      if (storedDoctorId != null) {
        print('Using stored doctor ID: $storedDoctorId');
        response = await _authService.getDoctorPatients(storedDoctorId, accessToken);
      } else {
        print('No stored doctor ID, fetching profile with user ID: $userId');
        final doctorProfile = await _authService.getDoctorProfile(userId, accessToken);
        response = await _authService.getDoctorPatients(doctorProfile.id, accessToken);
      }
      
      setState(() {
        _totalCommission = response.commission;
        
        // Group exams by patient name and date
        Map<String, Map<String, dynamic>> groupedPatients = {};
        
        for (var exam in response.dataPatients) {
          DateTime? examDate;
          try {
            if (exam.date.contains('GMT')) {
              examDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(exam.date.replaceAll(' GMT', ''));
            } else {
              examDate = DateTime.parse(exam.date);
            }
          } catch (e) {
            examDate = DateTime.now();
          }
          
          final key = '${exam.patientName}_${DateFormat('yyyy-MM-dd').format(examDate)}';
          
          if (groupedPatients.containsKey(key)) {
            // Add exam to existing patient
            groupedPatients[key]!['exams'].add({
              'type': exam.examType,
              'amount': exam.amount,
            });
            groupedPatients[key]!['totalAmount'] += exam.amount;
          } else {
            // Create new patient entry
            groupedPatients[key] = {
              "id": key.hashCode,
              "name": exam.patientName,
              "examinationDate": DateFormat('dd/MM/yyyy').format(examDate),
              "examDate": examDate,
              "commissionStatus": "Confirmé",
              "isPaid": true,
              "phone": "+237 6XX XXX XXX",
              "transferDate": DateFormat('dd/MM/yyyy').format(examDate.add(Duration(days: 3))),
              "exams": [{
                'type': exam.examType,
                'amount': exam.amount,
              }],
              "totalAmount": exam.amount,
            };
          }
        }
        
        _allPatients = groupedPatients.values.toList();
        _isLoading = false;
      });
      
      _applyFilters();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: "Erreur: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredPatients = _allPatients.where((patient) {
        // Month filter
        final examDate = patient['examDate'] as DateTime;
        if (examDate.year != _currentMonth.year || examDate.month != _currentMonth.month) {
          return false;
        }
        
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final name = (patient['name'] as String).toLowerCase();
          if (!name.contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        // Status filter
        if (_activeFilters['status'] != null &&
            _activeFilters['status'] != 'Tous') {
          if (patient['commissionStatus'] != _activeFilters['status']) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _applyFilters();
  }

  void _removeFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onFiltersChanged: _onFiltersChanged,
        ),
      ),
    );
  }

  Future<void> _refreshPatients() async {
    await _loadPatients();
    
    Fluttertoast.showToast(
      msg: "Liste des patients mise à jour",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _navigateToPatientDetail(Map<String, dynamic> patient) {
    Navigator.pushNamed(
      context,
      '/patient-detail',
      arguments: patient,
    );
  }

  void _viewCommission(Map<String, dynamic> patient) {
    final totalAmount = (patient['totalAmount'] as double?) ?? 0.0;
    final exams = (patient['exams'] as List<dynamic>?) ?? [];
    
    String examDetails = exams.map((exam) => 
      '${exam['type']}: ${exam['amount'].toStringAsFixed(0)} FCFA'
    ).join('\n');
    
    Fluttertoast.showToast(
      msg: "Total: ${totalAmount.toStringAsFixed(0)} FCFA\n$examDetails",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _callPatient(Map<String, dynamic> patient) {
    final phone = patient['phone'] as String?;
    Fluttertoast.showToast(
      msg: phone != null ? "Appel vers $phone" : "Numéro non disponible",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportReport(Map<String, dynamic> patient) {
    Fluttertoast.showToast(
      msg: "Export du rapport pour ${patient['name']}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _archivePatient(Map<String, dynamic> patient) {
    setState(() {
      _allPatients.removeWhere((p) => p['id'] == patient['id']);
    });
    _applyFilters();

    Fluttertoast.showToast(
      msg: "${patient['name']} archivé",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _applyFilters();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _applyFilters();
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    _activeFilters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty && value != 'Tous') {
        chips.add(
          FilterChipWidget(
            label: '$key: $value',
            isSelected: true,
            onRemove: () => _removeFilter(key),
          ),
        );
      }
    });

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patients',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Commission totale: ${_totalCommission.toStringAsFixed(2)} FCFA',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshPatients,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Navigation
          MonthNavigationWidget(
            currentMonth: _getMonthName(_currentMonth),
            onPreviousMonth: _previousMonth,
            onNextMonth: _nextMonth,
          ),

          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) => _onSearchChanged(),
            onFilterTap: _showFilterBottomSheet,
            hintText: 'Rechercher un patient...',
          ),

          // Active Filter Chips
          if (_buildActiveFilterChips().isNotEmpty)
            Container(
              height: 6.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildActiveFilterChips(),
              ),
            ),

          // Patient List

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? EmptyStateWidget(
                        title:
                            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                ? 'Aucun patient trouvé'
                                : 'Aucun patient',
                        subtitle: _searchQuery.isNotEmpty ||
                                _activeFilters.isNotEmpty
                            ? 'Essayez de modifier vos critères de recherche ou filtres.'
                            : 'Commencez par ajouter votre premier patient pour suivre les commissions.',
                        buttonText: 'Ajouter un patient',
                        onButtonPressed: () {
                          Fluttertoast.showToast(
                            msg: "Fonctionnalité d'ajout de patient",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshPatients,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = _filteredPatients[index];
                            return GroupedPatientCardWidget(
                              patient: patient,
                              onTap: () => _navigateToPatientDetail(patient),
                              onViewCommission: () => _viewCommission(patient),
                              onCallPatient: () => _callPatient(patient),
                              onArchive: () => _archivePatient(patient),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

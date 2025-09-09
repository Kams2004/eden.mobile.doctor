import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/month_navigation_widget.dart';
import './widgets/patient_card_widget.dart';
import './widgets/search_bar_widget.dart';

class PatientList extends StatefulWidget {
  const PatientList({Key? key}) : super(key: key);

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allPatients = [];
  List<Map<String, dynamic>> _filteredPatients = [];
  Map<String, dynamic> _activeFilters = {};
  String _searchQuery = '';
  DateTime _currentMonth = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeMockData() {
    _allPatients = [
      {
        "id": 1,
        "name": "Marie Dubois",
        "examinationDate": "15/08/2025",
        "commissionStatus": "Confirmé",
        "isPaid": true,
        "examinationType": "IRM",
        "commissionAmount": 125.50,
        "phone": "+33 1 23 45 67 89",
        "transferDate": "20/08/2025",
      },
      {
        "id": 2,
        "name": "Pierre Martin",
        "examinationDate": "18/08/2025",
        "commissionStatus": "En attente",
        "isPaid": false,
        "examinationType": "Scanner",
        "commissionAmount": 89.75,
        "phone": "+33 1 98 76 54 32",
        "transferDate": null,
      },
      {
        "id": 3,
        "name": "Sophie Leroy",
        "examinationDate": "22/08/2025",
        "commissionStatus": "Confirmé",
        "isPaid": true,
        "examinationType": "Échographie",
        "commissionAmount": 67.25,
        "phone": "+33 1 45 67 89 12",
        "transferDate": "25/08/2025",
      },
      {
        "id": 4,
        "name": "Jean Moreau",
        "examinationDate": "25/08/2025",
        "commissionStatus": "En attente",
        "isPaid": false,
        "examinationType": "Radiographie",
        "commissionAmount": 45.00,
        "phone": "+33 1 34 56 78 90",
        "transferDate": null,
      },
      {
        "id": 5,
        "name": "Catherine Bernard",
        "examinationDate": "28/08/2025",
        "commissionStatus": "Confirmé",
        "isPaid": true,
        "examinationType": "Mammographie",
        "commissionAmount": 98.50,
        "phone": "+33 1 56 78 90 12",
        "transferDate": "30/08/2025",
      },
      {
        "id": 6,
        "name": "Michel Rousseau",
        "examinationDate": "02/09/2025",
        "commissionStatus": "Annulé",
        "isPaid": false,
        "examinationType": "IRM",
        "commissionAmount": 0.00,
        "phone": "+33 1 67 89 01 23",
        "transferDate": null,
      },
      {
        "id": 7,
        "name": "Isabelle Petit",
        "examinationDate": "05/09/2025",
        "commissionStatus": "En attente",
        "isPaid": false,
        "examinationType": "Scanner",
        "commissionAmount": 112.75,
        "phone": "+33 1 78 90 12 34",
        "transferDate": null,
      },
      {
        "id": 8,
        "name": "François Garnier",
        "examinationDate": "08/09/2025",
        "commissionStatus": "Confirmé",
        "isPaid": true,
        "examinationType": "Échographie",
        "commissionAmount": 73.25,
        "phone": "+33 1 89 01 23 45",
        "transferDate": "10/09/2025",
      },
    ];

    _applyFilters();
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

        // Examination type filter
        if (_activeFilters['examinationType'] != null &&
            _activeFilters['examinationType'] != 'Tous') {
          if (patient['examinationType'] != _activeFilters['examinationType']) {
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
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would fetch fresh data from the server
    _initializeMockData();

    setState(() {
      _isLoading = false;
    });

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
    Fluttertoast.showToast(
      msg:
          "Commission: ${(patient['commissionAmount'] as double).toStringAsFixed(2)} fcfa",
      toastLength: Toast.LENGTH_SHORT,
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
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
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
        title: Text(
          'Patients',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
                            return PatientCardWidget(
                              patient: patient,
                              onTap: () => _navigateToPatientDetail(patient),
                              onViewCommission: () => _viewCommission(patient),
                              onCallPatient: () => _callPatient(patient),
                              onExportReport: () => _exportReport(patient),
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

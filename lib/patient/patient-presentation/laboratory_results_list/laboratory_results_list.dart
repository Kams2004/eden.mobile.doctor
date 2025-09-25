import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../patient-core/core/app_export.dart';
import '../../patient-widgets/widgets/custom_icon_widget.dart';
import './widgets/category_section_header.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/laboratory_result_card.dart';
import './widgets/search_filter_header.dart';
import './widgets/skeleton_loading_card.dart';

class LaboratoryResultsList extends StatefulWidget {
  const LaboratoryResultsList({super.key});

  @override
  State<LaboratoryResultsList> createState() => _LaboratoryResultsListState();
}

class _LaboratoryResultsListState extends State<LaboratoryResultsList>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  List<String> _activeFilters = [];
  List<String> _selectedCategories = [];
  DateTimeRange? _selectedDateRange;
  List<String> _selectedStatuses = [];

  Map<String, bool> _expandedCategories = {};
  Map<String, List<Map<String, dynamic>>> _groupedResults = {};

  // Mock data for laboratory results
  final List<Map<String, dynamic>> _laboratoryResults = [
    {
      "id": 1,
      "testName": "Bilan lipidique complet",
      "orderNumber": "LAB2025001",
      "category": "BIOCHIMIE",
      "emissionDate": "15/01/2025",
      "resultDate": "16/01/2025",
      "duration": "24h",
      "status": "completed",
      "analysesCount": 6,
      "analyses": [
        {
          "name": "Cholestérol total",
          "value": "1.95",
          "unit": "g/L",
          "reference": "< 2.00"
        },
        {
          "name": "HDL Cholestérol",
          "value": "0.52",
          "unit": "g/L",
          "reference": "> 0.40"
        },
        {
          "name": "LDL Cholestérol",
          "value": "1.25",
          "unit": "g/L",
          "reference": "< 1.60"
        },
        {
          "name": "Triglycérides",
          "value": "0.89",
          "unit": "g/L",
          "reference": "< 1.50"
        },
        {
          "name": "Apolipoprotéine A1",
          "value": "1.45",
          "unit": "g/L",
          "reference": "1.20-1.60"
        },
        {
          "name": "Apolipoprotéine B",
          "value": "0.85",
          "unit": "g/L",
          "reference": "0.60-1.20"
        }
      ]
    },
    {
      "id": 2,
      "testName": "Transaminases hépatiques",
      "orderNumber": "LAB2025002",
      "category": "TRANSAMINASES",
      "emissionDate": "14/01/2025",
      "resultDate": "15/01/2025",
      "duration": "18h",
      "status": "completed",
      "analysesCount": 4,
      "analyses": [
        {
          "name": "ALAT (GPT)",
          "value": "28",
          "unit": "UI/L",
          "reference": "< 45"
        },
        {
          "name": "ASAT (GOT)",
          "value": "32",
          "unit": "UI/L",
          "reference": "< 40"
        },
        {
          "name": "Gamma GT",
          "value": "22",
          "unit": "UI/L",
          "reference": "< 55"
        },
        {
          "name": "Phosphatases alcalines",
          "value": "85",
          "unit": "UI/L",
          "reference": "30-120"
        }
      ]
    },
    {
      "id": 3,
      "testName": "Numération formule sanguine",
      "orderNumber": "LAB2025003",
      "category": "HÉMATOLOGIE",
      "emissionDate": "13/01/2025",
      "resultDate": "14/01/2025",
      "duration": "12h",
      "status": "completed",
      "analysesCount": 8,
      "analyses": [
        {
          "name": "Globules rouges",
          "value": "4.5",
          "unit": "T/L",
          "reference": "4.0-5.2"
        },
        {
          "name": "Hémoglobine",
          "value": "14.2",
          "unit": "g/dL",
          "reference": "12.0-16.0"
        },
        {
          "name": "Hématocrite",
          "value": "42",
          "unit": "%",
          "reference": "36-46"
        },
        {
          "name": "Globules blancs",
          "value": "6.8",
          "unit": "G/L",
          "reference": "4.0-10.0"
        },
        {
          "name": "Neutrophiles",
          "value": "65",
          "unit": "%",
          "reference": "50-70"
        },
        {
          "name": "Lymphocytes",
          "value": "28",
          "unit": "%",
          "reference": "20-40"
        },
        {
          "name": "Plaquettes",
          "value": "285",
          "unit": "G/L",
          "reference": "150-400"
        },
        {"name": "VGM", "value": "88", "unit": "fL", "reference": "80-100"}
      ]
    },
    {
      "id": 4,
      "testName": "Sérologie hépatite B",
      "orderNumber": "LAB2025004",
      "category": "IMMUNOLOGIE",
      "emissionDate": "12/01/2025",
      "resultDate": "14/01/2025",
      "duration": "48h",
      "status": "pending",
      "analysesCount": 3,
      "analyses": [
        {
          "name": "AgHBs",
          "value": "Négatif",
          "unit": "",
          "reference": "Négatif"
        },
        {
          "name": "Ac anti-HBs",
          "value": "En cours",
          "unit": "mUI/mL",
          "reference": "> 10"
        },
        {
          "name": "Ac anti-HBc",
          "value": "En cours",
          "unit": "",
          "reference": "Négatif"
        }
      ]
    },
    {
      "id": 5,
      "testName": "Culture d'urine",
      "orderNumber": "LAB2025005",
      "category": "MICROBIOLOGIE",
      "emissionDate": "11/01/2025",
      "resultDate": "13/01/2025",
      "duration": "72h",
      "status": "completed",
      "analysesCount": 2,
      "analyses": [
        {
          "name": "Culture",
          "value": "Négative",
          "unit": "",
          "reference": "< 10³ UFC/mL"
        },
        {
          "name": "Antibiogramme",
          "value": "Non réalisé",
          "unit": "",
          "reference": "Si culture positive"
        }
      ]
    },
    {
      "id": 6,
      "testName": "Bilan thyroïdien",
      "orderNumber": "LAB2025006",
      "category": "ENDOCRINOLOGIE",
      "emissionDate": "10/01/2025",
      "resultDate": "11/01/2025",
      "duration": "24h",
      "status": "in_progress",
      "analysesCount": 3,
      "analyses": [
        {
          "name": "TSH",
          "value": "2.1",
          "unit": "mUI/L",
          "reference": "0.4-4.0"
        },
        {
          "name": "T4 libre",
          "value": "En cours",
          "unit": "pmol/L",
          "reference": "10-25"
        },
        {
          "name": "T3 libre",
          "value": "En cours",
          "unit": "pmol/L",
          "reference": "3.5-6.5"
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        _groupResultsByCategory();
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _groupResultsByCategory() {
    _groupedResults.clear();
    _expandedCategories.clear();

    final filteredResults = _getFilteredResults();

    for (var result in filteredResults) {
      final category = result["category"] as String;
      if (!_groupedResults.containsKey(category)) {
        _groupedResults[category] = [];
        _expandedCategories[category] = true; // Expand all by default
      }
      _groupedResults[category]!.add(result);
    }
  }

  List<Map<String, dynamic>> _getFilteredResults() {
    var results = List<Map<String, dynamic>>.from(_laboratoryResults);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((result) {
        final testName = (result["testName"] as String).toLowerCase();
        final category = (result["category"] as String).toLowerCase();
        final orderNumber = (result["orderNumber"] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();

        return testName.contains(query) ||
            category.contains(query) ||
            orderNumber.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      results = results.where((result) {
        return _selectedCategories.contains(result["category"]);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatuses.isNotEmpty) {
      results = results.where((result) {
        return _selectedStatuses.contains(result["status"]);
      }).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      results = results.where((result) {
        // Simple date filtering - in real app, parse actual dates
        return true; // Placeholder for date filtering logic
      }).toList();
    }

    return results;
  }

  void _updateActiveFilters() {
    _activeFilters.clear();

    if (_selectedCategories.isNotEmpty) {
      _activeFilters.addAll(_selectedCategories);
    }

    if (_selectedStatuses.isNotEmpty) {
      _activeFilters.addAll(
          _selectedStatuses.map((status) => _getStatusDisplayName(status)));
    }

    if (_selectedDateRange != null) {
      _activeFilters.add('Période personnalisée');
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      appBar: AppBar(
        title: Text('Résultats de Laboratoire'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshResults,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.primary,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
            fit: BoxFit.cover,
            opacity: 0.03,
          ),
        ),
        child: Column(
          children: [
            SearchFilterHeader(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onFilterTap: _showFilterBottomSheet,
              activeFilters: _activeFilters,
              onRemoveFilter: _removeFilter,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshResults,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_groupedResults.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResultsList();
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 6,
      itemBuilder: (context, index) => SkeletonLoadingCard(),
    );
  }

  Widget _buildEmptyState() {
    final isSearchResult = _searchQuery.isNotEmpty || _activeFilters.isNotEmpty;

    return EmptyStateWidget(
      title: isSearchResult
          ? 'Aucun résultat trouvé'
          : 'Aucun résultat disponible',
      subtitle: isSearchResult
          ? 'Aucun résultat ne correspond à vos critères de recherche.'
          : 'Il n\'y a pas de résultats de laboratoire à afficher pour le moment.',
      actionText: 'Actualiser',
      onActionPressed: _refreshResults,
      isSearchResult: isSearchResult,
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _groupedResults.length,
      itemBuilder: (context, index) {
        final category = _groupedResults.keys.elementAt(index);
        final results = _groupedResults[category]!;
        final isExpanded = _expandedCategories[category] ?? false;

        return Column(
          children: [
            CategorySectionHeader(
              categoryName: category,
              resultCount: results.length,
              isExpanded: isExpanded,
              onToggle: () => _toggleCategory(category),
            ),
            if (isExpanded)
              ...results
                  .map((result) => LaboratoryResultCard(
                        result: result,
                        onTap: () => _navigateToDetail(result),
                        onShare: () => _shareResult(result),
                        onFavorite: () => _toggleFavorite(result),
                      ))
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Laboratory tab is active
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'science',
              color: Theme.of(context).colorScheme.primary,
              size: 6.w,
            ),
            label: 'Laboratoire',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'medical_services',
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Imagerie',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Profil',
          ),
        ],
        onTap: _onBottomNavTap,
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _groupResultsByCategory();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedCategories: _selectedCategories,
        selectedDateRange: _selectedDateRange,
        selectedStatuses: _selectedStatuses,
        onApplyFilters: _applyFilters,
      ),
    );
  }

  void _applyFilters(List<String> categories, DateTimeRange? dateRange,
      List<String> statuses) {
    setState(() {
      _selectedCategories = categories;
      _selectedDateRange = dateRange;
      _selectedStatuses = statuses;
    });
    _updateActiveFilters();
    _groupResultsByCategory();
  }

  void _removeFilter(String filter) {
    setState(() {
      _selectedCategories.remove(filter);
      _selectedStatuses
          .removeWhere((status) => _getStatusDisplayName(status) == filter);

      if (filter == 'Période personnalisée') {
        _selectedDateRange = null;
      }
    });
    _updateActiveFilters();
    _groupResultsByCategory();
  }

  void _toggleCategory(String category) {
    setState(() {
      _expandedCategories[category] = !(_expandedCategories[category] ?? false);
    });
  }

  Future<void> _refreshResults() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      _groupResultsByCategory();
      setState(() {
        _isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Résultats actualisés'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToDetail(Map<String, dynamic> result) {
    Navigator.pushNamed(
      context,
      '/laboratory-result-detail',
      arguments: result,
    );
  }

  void _shareResult(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de ${result["testName"]} avec votre médecin'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result["testName"]} ajouté aux favoris'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/patient-dashboard');
        break;
      case 1:
        // Already on laboratory results
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/imagery-results-list');
        break;
      case 3:
        // Show profile options
        _showProfileOptions();
        break;
    }
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Voir le profil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Paramètres'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Aide & Support'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'logout',
                color: Theme.of(context).colorScheme.error,
                size: 6.w,
              ),
              title: Text('Se déconnecter'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/splash-screen',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


import '../../patient-widgets/widgets/custom_bottom_bar.dart';
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

  // Mock data for imagery results
  final List<Map<String, dynamic>> _mockImageryResults = [
    {
      "id": 1,
      "examinationType": "Radiographie thoracique",
      "indication": "Contrôle post-opératoire, surveillance pneumonie",
      "technique": "Radiographie numérique standard, incidences face et profil",
      "examinationDate": "15/08/2024",
      "completionDate": "15/08/2024 14:30",
      "bodyRegion": "Thorax",
      "status": "completed",
      "imageCount": 2,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "results":
          """Examen radiographique du thorax réalisé en incidences de face et de profil. TECHNIQUE: Radiographie numérique standard, patient debout. RÉSULTATS: - Poumons: Parenchyme pulmonaire d'aspect normal - Plèvres: Pas d'épanchement pleural visible - Médiastin: Silhouette cardiaque de taille normale - Structures osseuses: Intégrité des côtes et du rachis dorsal CONCLUSION: Radiographie thoracique normale. Pas d'anomalie détectée.""",
      "conclusion": "Radiographie thoracique normale. Pas d'anomalie détectée.",
      "doctorName": "Dr. Marie Dubois",
      "department": "Radiologie"
    },
    {
      "id": 2,
      "examinationType": "IRM cérébrale",
      "indication": "Céphalées persistantes, bilan neurologique",
      "technique":
          "IRM 1.5T avec injection de gadolinium, séquences T1, T2, FLAIR",
      "examinationDate": "12/08/2024",
      "completionDate": "12/08/2024 16:45",
      "bodyRegion": "Tête et cou",
      "status": "completed",
      "imageCount": 15,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1559757175-0eb30cd8c063?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "results":
          """IRM cérébrale avec injection de produit de contraste. TECHNIQUE: IRM 1.5 Tesla, séquences T1, T2, FLAIR, diffusion et T1 après injection. RÉSULTATS: - Substance blanche: Quelques hypersignaux punctiformes en T2/FLAIR - Substance grise: Aspect normal - Ventricules: Taille et morphologie normales - Espaces sous-arachnoïdiens: Pas de dilatation - Vascularisation: Pas d'anomalie de signal CONCLUSION: IRM cérébrale montrant quelques hypersignaux punctiformes aspécifiques en substance blanche, compatibles avec l'âge. Pas d'anomalie significative.""",
      "conclusion":
          "Quelques hypersignaux punctiformes aspécifiques compatibles avec l'âge.",
      "doctorName": "Dr. Pierre Martin",
      "department": "Neuroradiologie"
    },
    {
      "id": 3,
      "examinationType": "Scanner abdomino-pelvien",
      "indication": "Douleurs abdominales, bilan digestif",
      "technique":
          "Scanner hélicoïdal avec injection IV, reconstructions multiplanaires",
      "examinationDate": "10/08/2024",
      "completionDate": "10/08/2024 11:20",
      "bodyRegion": "Abdomen",
      "status": "completed",
      "imageCount": 8,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "results":
          """Scanner abdomino-pelvien avec injection de produit de contraste iodé. TECHNIQUE: Acquisition hélicoïdale, coupes de 2.5mm, injection IV de 100ml. RÉSULTATS: - Foie: Taille et densité normales, pas de lésion focale - Vésicule biliaire: Aspect normal - Pancréas: Morphologie et rehaussement normaux - Rate: Taille normale - Reins: Aspect morphologique normal bilatéralement - Tube digestif: Pas d'anomalie visible CONCLUSION: Scanner abdomino-pelvien normal. Pas d'anomalie détectée.""",
      "conclusion": "Scanner abdomino-pelvien normal.",
      "doctorName": "Dr. Sophie Laurent",
      "department": "Radiologie"
    },
    {
      "id": 4,
      "examinationType": "Échographie cardiaque",
      "indication": "Bilan cardiologique, souffle systolique",
      "technique": "Échographie transthoracique, doppler couleur",
      "examinationDate": "08/08/2024",
      "completionDate": "08/08/2024 09:15",
      "bodyRegion": "Thorax",
      "status": "completed",
      "imageCount": 6,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1559757175-0eb30cd8c063?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "results":
          """Échographie cardiaque transthoracique avec doppler. TECHNIQUE: Sonde sectorielle 2-4 MHz, toutes les incidences standard. RÉSULTATS: - Ventricule gauche: Taille normale, fonction systolique conservée (FE: 65%) - Ventricule droit: Aspect normal - Oreillettes: Tailles normales - Valves: Aspect morphologique normal, pas de fuite significative - Péricarde: Pas d'épanchement CONCLUSION: Échographie cardiaque normale. Fonction ventriculaire gauche conservée.""",
      "conclusion": "Échographie cardiaque normale, fonction VG conservée.",
      "doctorName": "Dr. Jean Moreau",
      "department": "Cardiologie"
    },
    {
      "id": 5,
      "examinationType": "Mammographie bilatérale",
      "indication": "Dépistage systématique, antécédents familiaux",
      "technique": "Mammographie numérique, incidences CC et MLO bilatérales",
      "examinationDate": "05/08/2024",
      "completionDate": "05/08/2024 14:00",
      "bodyRegion": "Thorax",
      "status": "pending",
      "imageCount": 4,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "results":
          """Mammographie de dépistage bilatérale. TECHNIQUE: Mammographie numérique, incidences cranio-caudale et oblique médio-latérale. RÉSULTATS: - Sein droit: Densité mammaire hétérogène, pas de masse suspecte - Sein gauche: Aspect symétrique, quelques calcifications bénignes - Ganglions axillaires: Aspect normal bilatéralement CONCLUSION: Mammographie de dépistage normale (ACR 2). Contrôle recommandé dans 2 ans.""",
      "conclusion": "Mammographie normale (ACR 2), contrôle dans 2 ans.",
      "doctorName": "Dr. Anne Rousseau",
      "department": "Sénologie"
    }
  ];

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
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 1500));

    setState(() {
      _imageryResults = List.from(_mockImageryResults);
      _filteredResults = List.from(_imageryResults);
      _isLoading = false;
    });
  }

  void _onScroll() {
    // Handle scroll events for pagination if needed
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more data if available
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate refresh delay
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      _imageryResults = List.from(_mockImageryResults);
      _applyFiltersAndSearch();
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Résultats d\'imagerie actualisés'),
        duration: Duration(seconds: 2),
      ),
    );
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

    if (filters['imagingTypes'] != null) {
      for (String type in (filters['imagingTypes'] as List<String>)) {
        activeFilters.add('type:${type.toLowerCase()}');
      }
    }

    if (filters['bodyRegions'] != null) {
      for (String region in (filters['bodyRegions'] as List<String>)) {
        activeFilters.add('region:$region');
      }
    }

    if (filters['status'] != null) {
      for (String status in (filters['status'] as List<String>)) {
        activeFilters.add('status:${status.toLowerCase()}');
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
        return (result['examinationType'] as String)
                .toLowerCase()
                .contains(searchLower) ||
            (result['indication'] as String)
                .toLowerCase()
                .contains(searchLower) ||
            (result['bodyRegion'] as String? ?? '')
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

    // Apply imaging type filter
    if (_currentFilters['imagingTypes'] != null &&
        (_currentFilters['imagingTypes'] as List).isNotEmpty) {
      filtered = filtered.where((result) {
        final examType = (result['examinationType'] as String).toLowerCase();
        return (_currentFilters['imagingTypes'] as List<String>)
            .any((type) => examType.contains(type.toLowerCase()));
      }).toList();
    }

    // Apply body region filter
    if (_currentFilters['bodyRegions'] != null &&
        (_currentFilters['bodyRegions'] as List).isNotEmpty) {
      filtered = filtered.where((result) {
        final region = (result['bodyRegion'] as String? ?? '').toLowerCase();
        return (_currentFilters['bodyRegions'] as List<String>)
            .any((filterRegion) => region.contains(filterRegion.toLowerCase()));
      }).toList();
    }

    // Apply status filter
    if (_currentFilters['status'] != null &&
        (_currentFilters['status'] as List).isNotEmpty) {
      filtered = filtered.where((result) {
        final status = (result['status'] as String).toLowerCase();
        return (_currentFilters['status'] as List<String>)
            .any((filterStatus) => status == filterStatus.toLowerCase());
      }).toList();
    }

    // Apply sorting
    final sortBy = _currentFilters['sortBy'] as String? ?? 'date_desc';
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'date_asc':
          return (a['examinationDate'] as String)
              .compareTo(b['examinationDate'] as String);
        case 'date_desc':
          return (b['examinationDate'] as String)
              .compareTo(a['examinationDate'] as String);
        case 'type_asc':
          return (a['examinationType'] as String)
              .compareTo(b['examinationType'] as String);
        case 'type_desc':
          return (b['examinationType'] as String)
              .compareTo(a['examinationType'] as String);
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
    List<String> imagingTypes = [];
    List<String> bodyRegions = [];
    List<String> status = [];

    for (String filter in _activeFilters) {
      if (filter.startsWith('type:')) {
        imagingTypes.add(filter.substring(5));
      } else if (filter.startsWith('region:')) {
        bodyRegions.add(filter.substring(7));
      } else if (filter.startsWith('status:')) {
        status.add(filter.substring(7));
      } else if (filter.startsWith('date:')) {
        newFilters['dateRange'] = filter.substring(5);
      }
    }

    if (imagingTypes.isNotEmpty) newFilters['imagingTypes'] = imagingTypes;
    if (bodyRegions.isNotEmpty) newFilters['bodyRegions'] = bodyRegions;
    if (status.isNotEmpty) newFilters['status'] = status;

    _currentFilters = newFilters;
  }

  void _onResultTap(Map<String, dynamic> result) {
    Navigator.pushNamed(
      context,
      '/imagery-result-detail',
      arguments: result,
    );
  }

  void _onViewImages(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture des images pour ${result["examinationType"]}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onShareWithDoctor(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage avec le médecin: ${result["examinationType"]}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onAddToFavorites(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ajouté aux favoris: ${result["examinationType"]}'),
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
            Text('Téléchargement du rapport: ${result["examinationType"]}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
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
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Imagery tab
        variant: BottomBarVariant.standard,
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
          return ImageryResultCard(
            imageryResult: result,
            onTap: () => _onResultTap(result),
            onViewImages: () => _onViewImages(result),
            onShareWithDoctor: () => _onShareWithDoctor(result),
            onAddToFavorites: () => _onAddToFavorites(result),
            onDownloadReport: () => _onDownloadReport(result),
          );
        },
      ),
    );
  }
}

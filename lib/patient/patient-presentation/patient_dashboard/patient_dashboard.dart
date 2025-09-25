import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../patient-core/core/app_export.dart';
import '../../patient-theme/theme/app_theme.dart';
import '../../patient-widgets/widgets/custom_icon_widget.dart';
import './widgets/medical_background.dart';
import './widgets/medical_category_card.dart';
import './widgets/news_card.dart';
import './widgets/patient_header.dart';
import './widgets/quick_stats_card.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard>
    with TickerProviderStateMixin {
  late PageController _newsPageController;
  late AnimationController _refreshController;
  int _currentNewsIndex = 0;
  bool _isRefreshing = false;

  // Mock patient data
  final String _patientName = "Marie Dubois";
  final String _lastLoginTime = "27/08/2025 à 14:32";

  // Mock medical categories data
  final List<Map<String, dynamic>> _medicalCategories = [
    {
      "id": "laboratory",
      "title": "Analyses de Laboratoire",
      "iconName": "science",
      "resultCount": 12,
      "lastTestDate": "25/08/2025",
      "route": "/laboratory-results-list",
    },
    {
      "id": "imagery",
      "title": "Imagerie Médicale",
      "iconName": "medical_services",
      "resultCount": 8,
      "lastTestDate": "23/08/2025",
      "route": "/imagery-results-list",
    },
    {
      "id": "prescription",
      "title": "Prescription",
      "iconName": "document_scanner",
      "resultCount": 3,
      "lastTestDate": "28/08/2025",
      "route": "/prescription-scanner",
    },
  ];

  // Mock news data
  final List<Map<String, dynamic>> _newsData = [
    {
      "id": 1,
      "title": "Nouveaux horaires d'ouverture du laboratoire",
      "description":
          "À partir du 1er septembre, le laboratoire PDMD étend ses horaires pour mieux vous servir.",
      "fullContent":
          "Le laboratoire sera désormais ouvert du lundi au vendredi de 7h00 à 19h00, et le samedi de 8h00 à 16h00. Ces nouveaux horaires permettront une meilleure prise en charge de vos analyses urgentes et une réduction des temps d'attente.",
      "image":
          "https://images.pexels.com/photos/4021775/pexels-photo-4021775.jpeg?auto=compress&cs=tinysrgb&w=800",
      "date": "28/08/2025",
    },
    {
      "id": 2,
      "title": "Nouvelle technologie d'imagerie disponible",
      "description":
          "Le centre PDMD s'équipe d'un nouvel IRM 3 Tesla pour des diagnostics plus précis.",
      "fullContent":
          "Cette nouvelle technologie permet des examens plus rapides et plus confortables pour les patients, avec une qualité d'image exceptionnelle. Les délais de rendez-vous sont également réduits grâce à cette acquisition.",
      "image":
          "https://images.pexels.com/photos/7089020/pexels-photo-7089020.jpeg?auto=compress&cs=tinysrgb&w=800",
      "date": "26/08/2025",
    },
    {
      "id": 3,
      "title": "Campagne de dépistage gratuit",
      "description":
          "Participez à notre campagne de dépistage du diabète et de l'hypertension.",
      "fullContent":
          "Du 1er au 15 septembre, bénéficiez d'un dépistage gratuit du diabète et de l'hypertension. Aucun rendez-vous nécessaire, présentez-vous directement au centre entre 9h00 et 17h00.",
      "image":
          "https://images.pexels.com/photos/4021775/pexels-photo-4021775.jpeg?auto=compress&cs=tinysrgb&w=800",
      "date": "24/08/2025",
    },
  ];

  @override
  void initState() {
    super.initState();
    _newsPageController = PageController();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _startNewsRotation();
  }

  @override
  void dispose() {
    _newsPageController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _startNewsRotation() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _newsData.isNotEmpty) {
        final nextIndex = (_currentNewsIndex + 1) % _newsData.length;
        _newsPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentNewsIndex = nextIndex;
        });
        _startNewsRotation();
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _refreshController.reverse();

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Résultats médicaux mis à jour'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleCategoryTap(Map<String, dynamic> category) {
    final route = category['route'] as String;
    Navigator.pushNamed(context, route);
  }

  void _handleCategoryLongPress(Map<String, dynamic> category) {
    _showQuickActions(category);
  }

  void _showQuickActions(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                category['title'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility',
                  color: colorScheme.primary,
                  size: 6.w,
                ),
                title: const Text('Voir les résultats récents'),
                onTap: () {
                  Navigator.pop(context);
                  _handleCategoryTap(category);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'filter_list',
                  color: colorScheme.primary,
                  size: 6.w,
                ),
                title: const Text('Filtrer par date'),
                onTap: () {
                  Navigator.pop(context);
                  _showDateFilter(category);
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showDateFilter(Map<String, dynamic> category) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    ).then((dateRange) {
      if (dateRange != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Filtre appliqué: ${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year} - ${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _handleContactCenter() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'phone',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              const Text('Contacter le Centre'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomIconWidget(
                  iconName: 'phone',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                title: const Text('Téléphone'),
                subtitle: const Text('+33 1 23 45 67 89'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appel en cours...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomIconWidget(
                  iconName: 'email',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                title: const Text('Email'),
                subtitle: const Text('contact@pdmd.fr'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ouverture de l\'application email...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'help_outline',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              const Text('Aide'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomIconWidget(
                  iconName: 'document_scanner',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                title: const Text('Scanner une prescription'),
                subtitle:
                    const Text('Comment utiliser le scanner de prescription'),
                onTap: () {
                  Navigator.pop(context);
                  _showScannerHelp();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomIconWidget(
                  iconName: 'info_outline',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                title: const Text('Guide d\'utilisation'),
                subtitle: const Text('Guide complet de l\'application'),
                onTap: () {
                  Navigator.pop(context);
                  _showUserGuide();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomIconWidget(
                  iconName: 'support_agent',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                title: const Text('Support technique'),
                subtitle: const Text('Contacter le support'),
                onTap: () {
                  Navigator.pop(context);
                  _handleContactCenter();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showScannerHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scanner une prescription'),
        content: const Text(
          '1. Appuyez sur "Prescription" dans la navigation\n'
          '2. Positionnez votre prescription dans le cadre\n'
          '3. Assurez-vous que l\'éclairage est suffisant\n'
          '4. Appuyez sur le bouton de capture\n'
          '5. Vérifiez le résultat et confirmez',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guide d\'utilisation'),
        content: const Text(
          'EDEN vous permet de:\n\n'
          '• Consulter vos résultats médicaux\n'
          '• Scanner vos prescriptions\n'
          '• Voir la disponibilité des examens\n'
          '• Prendre des rendez-vous\n'
          '• Suivre le statut de validation\n\n'
          'Pour plus d\'informations, contactez le support.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      body: MedicalBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: colorScheme.primary,
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 12.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'EDEN',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // Help Icon
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'help_outline',
                        color: colorScheme.primary,
                        size: 6.w,
                      ),
                      onPressed: () => _showHelpDialog(),
                    ),
                    // Refresh Icon
                    AnimatedBuilder(
                      animation: _refreshController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _refreshController.value * 2 * 3.14159,
                          child: IconButton(
                            icon: CustomIconWidget(
                              iconName: 'refresh',
                              color: colorScheme.primary,
                              size: 6.w,
                            ),
                            onPressed: _isRefreshing ? null : _handleRefresh,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Main Content
                SliverList(
                  delegate: SliverChildListDelegate([
                    SizedBox(height: 1.h),

                    // Patient Header
                    PatientHeader(
                      patientName: _patientName,
                      lastLoginTime: _lastLoginTime,
                    ),

                    SizedBox(height: 1.h),

                    // Quick Stats
                    QuickStatsCard(
                      totalResults: _medicalCategories.fold<int>(
                        0,
                        (sum, category) =>
                            sum + (category['resultCount'] as int),
                      ),
                      lastUpdate: "28/08/2025\n10:30",
                    ),

                    SizedBox(height: 2.h),

                    // Medical Categories Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Vos Résultats Médicaux',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Medical Category Cards
                    ...(_medicalCategories
                        .map((category) => MedicalCategoryCard(
                              title: category['title'] as String,
                              iconName: category['iconName'] as String,
                              resultCount: category['resultCount'] as int,
                              lastTestDate: category['lastTestDate'] as String,
                              onTap: () => _handleCategoryTap(category),
                              onLongPress: () =>
                                  _handleCategoryLongPress(category),
                            ))),

                    SizedBox(height: 2.h),

                    // News Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Text(
                            'Actualités du Centre',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: List.generate(_newsData.length, (index) {
                              return Container(
                                margin: EdgeInsets.only(left: 1.w),
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: _currentNewsIndex == index
                                      ? colorScheme.primary
                                      : colorScheme.outline
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(1.w),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // News Card with PageView
                    SizedBox(
                      height: 45.h,
                      child: PageView.builder(
                        controller: _newsPageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentNewsIndex = index;
                          });
                        },
                        itemCount: _newsData.length,
                        itemBuilder: (context, index) {
                          return NewsCard(
                            newsItem: _newsData[index],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 10.h), // Space for bottom navigation
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleContactCenter,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: CustomIconWidget(
          iconName: 'phone',
          color: colorScheme.onPrimary,
          size: 5.w,
        ),
        label: Text(
          'Contacter',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        currentIndex: 0,
        elevation: 8.0,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: colorScheme.primary,
              size: 6.w,
            ),
            label: 'Tableau de Bord',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'science_outlined',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Laboratoire',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'medical_services_outlined',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Imagerie',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'document_scanner_outlined',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Prescription',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            label: 'Aide',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              Navigator.pushNamed(context, '/laboratory-results-list');
              break;
            case 2:
              Navigator.pushNamed(context, '/imagery-results-list');
              break;
            case 3:
              Navigator.pushNamed(context, '/prescription-scanner');
              break;
            case 4:
              _showHelpDialog();
              break;
          }
        },
      ),
    );
  }
}

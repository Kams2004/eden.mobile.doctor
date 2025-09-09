import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/activity_statistics_grid.dart';
import './widgets/commission_summary_card.dart';
import './widgets/notification_header.dart';
import './widgets/recent_patient_card.dart';
import './widgets/news_carousel.dart'; // Add this import

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now();

  // Mock data for dashboard
  final Map<String, dynamic> _dashboardData = {
    "doctorName": "Martin Dubois",
    "monthlyCommission": {
      "totalEarnings": 4250.75,
      "pendingPayments": 1320.50,
      "currency": "fcfa"
    },
    "statistics": {
      "patientCount": 127,
      "examinationCount": 89,
      "recentTransfers": 23,
      "pendingRequests": 5
    },
    "notifications": {"count": 3},
    // Add news/actualités data with comprehensive demo content
    "newsItems": [
      {
        "id": 1,
        "title": "OCTOBRE ROSE 2025",
        "category": "campagne",
        "description": "Rejoignez notre campagne de sensibilisation au cancer du sein. Dépistage gratuit pour toutes les femmes de 40 à 70 ans.",
        "imageUrl": "https://www.ccdourdannais.com/wp-content/uploads/2021/09/Octobre-Rose.png",
        "fullContent": "Durant tout le mois d'octobre, participez à notre grande campagne de sensibilisation au cancer du sein 'OCTOBRE ROSE 2025'. Nous offrons des consultations gratuites et des mammographies de dépistage pour toutes les femmes âgées de 40 à 70 ans.\n\nCette initiative vise à encourager le dépistage précoce qui peut sauver des vies. Le cancer du sein touche 1 femme sur 8 au cours de sa vie, mais détecté tôt, il se guérit dans 9 cas sur 10.\n\nNos services offerts :\n• Consultations gratuites avec nos spécialistes\n• Mammographies de dépistage\n• Échographies mammaires\n• Accompagnement psychologique\n• Information et conseils préventifs\n\nN'hésitez pas à prendre rendez-vous dès maintenant dans l'un de nos centres partenaires. Ensemble, luttons contre le cancer du sein!"
      },
      {
        "id": 2,
        "title": "Scanner 3D Nouvelle Génération",
        "category": "information",
        "description": "Installation de notre nouveau scanner CT 3D haute définition. Examens plus rapides et plus précis pour tous nos patients.",
        "imageUrl": "https://pdmdsante.com/wp-content/uploads/2025/06/Im.jpg",
        "fullContent": "Nous sommes fiers d'annoncer l'installation de notre nouveau scanner CT 3D de dernière génération dans notre centre d'imagerie médicale.\n\nAvantages de cette nouvelle technologie :\n• Temps d'examen réduit de 50%\n• Qualité d'image exceptionnelle en 3D\n• Dose de radiation diminuée de 30%\n• Confort amélioré pour les patients\n• Diagnostics plus précis et rapides\n\nCette acquisition s'inscrit dans notre démarche d'amélioration continue de la qualité des soins. Elle nous permet de réaliser des examens encore plus performants pour le diagnostic de pathologies thoraciques, abdominales et orthopédiques.\n\nPrise de rendez-vous disponible dès le 15 septembre 2025."
      },
      {
        "id": 3,
        "title": "Journée Mondiale du Diabète",
        "category": "santé",
        "description": "Le 14 novembre, participez à notre journée de dépistage gratuit du diabète. Tests glycémiques et conseils nutritionnels.",
        "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFS0kblGykEMjM0MZHSVi4LqT0aP1QPYBhGalP0r28TqIUNTQpOLnnR_t3S-BghWs8oTg&usqp=CAU",
        "fullContent": "À l'occasion de la Journée Mondiale du Diabète le 14 novembre 2025, notre centre organise une grande journée de sensibilisation et de dépistage gratuit.\n\nLe diabète en chiffres :\n• 422 millions de personnes touchées dans le monde\n• 1 personne sur 11 est diabétique\n• 50% des diabétiques ignorent leur maladie\n\nProgramme de la journée (9h-17h) :\n• Dépistage gratuit de la glycémie\n• Consultations avec nos endocrinologues\n• Ateliers nutrition et cuisine équilibrée\n• Tests de l'hémoglobine glyquée (HbA1c)\n• Conseils pour l'activité physique adaptée\n• Remise de guides pratiques\n\nCette journée s'adresse à tous, particulièrement aux personnes à risque (surpoids, antécédents familiaux, sédentarité). Venez nombreux, c'est gratuit et sans rendez-vous!"
      },
      {
        "id": 4,
        "title": "URGENT: Rappel Vaccin Méningite",
        "category": "urgent",
        "description": "Suite à plusieurs cas de méningite dans la région, vaccination recommandée pour les 11-24 ans. Stocks disponibles.",
        "imageUrl": "https://pdmdsante.com/wp-content/uploads/2025/06/pediatrie.avif",
        "fullContent": "ALERTE SANITAIRE - VACCINATION MÉNINGITE\n\nSuite à l'identification de plusieurs cas de méningite à méningocoque dans notre région, les autorités sanitaires recommandent une vaccination préventive pour les populations à risque.\n\nPopulations concernées :\n• Jeunes de 11 à 24 ans\n• Personnel de santé\n• Étudiants en internat\n• Militaires\n• Voyageurs en zone d'endémie\n\nSymptômes à surveiller :\n• Fièvre élevée soudaine\n• Maux de tête intenses\n• Raideur de la nuque\n• Éruption cutanée\n• Vomissements\n\nEn cas de symptômes, consultez immédiatement aux urgences.\n\nNotre centre dispose de stocks suffisants de vaccins. Vaccination possible sans rendez-vous du lundi au vendredi de 8h à 18h, et le samedi de 9h à 16h.\n\nTarif : 45 FCFA (remboursé par l'assurance maladie)"
      },
      {
        "id": 5,
        "title": "Congrès International Cardiologie",
        "category": "événement",
        "description": "Notre centre accueille le 15e Congrès Africain de Cardiologie du 20 au 22 octobre. Inscriptions ouvertes.",
        "imageUrl": "https://www.horizons.dz/wp-content/uploads/2024/11/Annaba-louverture-du-Congres-International-de-Cardiologie-avec-la-participation-de-300-specialistes.jpg",
        "fullContent": "15e CONGRÈS AFRICAIN DE CARDIOLOGIE\nYaoundé - 20, 21 et 22 Octobre 2025\n\nNotre centre d'excellence cardiologique a l'honneur d'accueillir ce prestigieux événement médical qui réuniera plus de 500 spécialistes africains and internationaux.\n\nThèmes principaux :\n• Innovations en chirurgie cardiaque\n• Prévention des maladies cardiovasculaires\n• Télémédecine et cardiologie\n• Cardiologie interventionnelle\n• Hypertension artérielle en Afrique\n• Formation et recherche\n\nIntervenants de renom :\n• Pr. Sarah Mbeki (Université du Cap)\n• Dr. James Wilson (Harvard Medical School)\n• Pr. Ahmed Hassan (Université du Caire)\n• Dr. Marie Dupont (CHU de Lyon)\n\nInformations pratiques :\n• Lieu : Palais des Congrès de Yaoundé\n• Frais d'inscription : 150€ (médecins), 75€ (étudiants)\n• Crédits de formation continue validés\n• Traduction simultanée français/anglais\n\nInscriptions sur : www.congres-cardiologie-afrique.org"
      }

    ],
    "recentPatients": [
      {
        "id": 1,
        "name": "Marie Lefevre",
        "examinationDate": "28/08/2025",
        "commissionAmount": 125.50,
        "paymentStatus": "paid"
      },
      {
        "id": 2,
        "name": "Jean-Pierre Moreau",
        "examinationDate": "27/08/2025",
        "commissionAmount": 98.75,
        "paymentStatus": "pending"
      },
      {
        "id": 3,
        "name": "Sophie Bernard",
        "examinationDate": "26/08/2025",
        "commissionAmount": 156.25,
        "paymentStatus": "paid"
      },
      {
        "id": 4,
        "name": "Pierre Rousseau",
        "examinationDate": "25/08/2025",
        "commissionAmount": 87.50,
        "paymentStatus": "overdue"
      },
      {
        "id": 5,
        "name": "Catherine Blanc",
        "examinationDate": "24/08/2025",
        "commissionAmount": 142.00,
        "paymentStatus": "pending"
      },
      {
        "id": 6,
        "name": "Michel Garnier",
        "examinationDate": "23/08/2025",
        "commissionAmount": 113.75,
        "paymentStatus": "paid"
      }
    ]
  };

  void _navigateToSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Title
            Text(
              'Support & Assistance',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),

            // Support options
            _buildSupportOption(
              icon: Icons.help_outline,
              title: 'Service d\'aide',
              description: 'Obtenez de l\'aide pour vos problèmes techniques',
              onTap: () {
                Navigator.pop(context);
                _showHelpService();
              },
            ),
            SizedBox(height: 2.h),

            _buildSupportOption(
              icon: Icons.request_page,
              title: 'Faire une requête',
              description: 'Soumettre une demande ou une suggestion',
              onTap: () {
                Navigator.pop(context);
                _showRequestForm();
              },
            ),
            SizedBox(height: 2.h),

            _buildSupportOption(
              icon: Icons.menu_book,
              title: 'Guide d\'utilisation',
              description: 'Consulter le manuel d\'utilisation de l\'application',
              onTap: () {
                Navigator.pop(context);
                _showUserGuide();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Service d\'aide'),
        content: Text('Service d\'aide technique sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showRequestForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Faire une requête'),
        content: Text('Formulaire de requête sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Guide d\'utilisation'),
        content: Text('Le guide d\'utilisation sera bientôt disponible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with notifications
                    NotificationHeader(
                      doctorName: (_dashboardData["doctorName"] as String?) ??
                          "Docteur",
                      notificationCount: ((_dashboardData["notifications"]
                      as Map<String, dynamic>?)?["count"] as int?) ??
                          0,
                      onNotificationTap: _handleNotificationTap,
                    ),

                    // Monthly commission summary
                    // CommissionSummaryCard(
                    //   totalEarnings: ((_dashboardData["monthlyCommission"]
                    //   as Map<String, dynamic>?)?[
                    //   "totalEarnings"] as num?)
                    //       ?.toDouble() ??
                    //       0.0,
                    //   pendingPayments: ((_dashboardData["monthlyCommission"]
                    //   as Map<String, dynamic>?)?[
                    //   "pendingPayments"] as num?)
                    //       ?.toDouble() ??
                    //       0.0,
                    //   currency: ((_dashboardData["monthlyCommission"]
                    //   as Map<String, dynamic>?)?["currency"]
                    //   as String?) ??
                    //       "fcfa",
                    // ),

                    SizedBox(height: 2.h),

                    // Activity statistics grid
                    ActivityStatisticsGrid(
                      patientCount: ((_dashboardData["statistics"]
                      as Map<String, dynamic>?)?["patientCount"]
                      as int?) ??
                          0,
                      examinationCount: ((_dashboardData["statistics"]
                      as Map<String, dynamic>?)?["examinationCount"]
                      as int?) ??
                          0,
                      recentTransfers: ((_dashboardData["statistics"]
                      as Map<String, dynamic>?)?["recentTransfers"]
                      as int?) ??
                          0,
                      pendingRequests: ((_dashboardData["statistics"]
                      as Map<String, dynamic>?)?["pendingRequests"]
                      as int?) ??
                          0,
                    ),

                    // NEWS/ACTUALITÉS CAROUSEL - NEW ADDITION
                    // Section header for Actualités
                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                      child: Text(
                        'Actualités',
                        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // News carousel
                    NewsCarousel(
                      newsItems: ((_dashboardData["newsItems"] as List?)
                          ?.cast<Map<String, dynamic>>()) ??
                          [],
                    ),

                    SizedBox(height: 2.h),

                    // Recent patients section header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Patients récents',
                            style: AppTheme.lightTheme.textTheme.headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToPatientList,
                            child: Text(
                              'Voir tout',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),
                  ],
                ),
              ),

              // Recent patients list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final patients =
                        (_dashboardData["recentPatients"] as List?) ?? [];
                    if (index >= patients.length) return null;

                    final patient = patients[index] as Map<String, dynamic>;
                    return RecentPatientCard(
                      patient: patient,
                      onTap: () => _navigateToPatientDetail(patient),
                      onCommissionView: () => _showCommissionDetails(patient),
                      onPatientDetails: () => _navigateToPatientDetail(patient),
                    );
                  },
                  childCount:
                  ((_dashboardData["recentPatients"] as List?)?.length ??
                      0),
                ),
              ),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSupport,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const CustomIconWidget(
          iconName: 'support_agent',
          color: Colors.white,
          size: 24,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
      unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      currentIndex: 0,
      onTap: _handleBottomNavTap,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          label: 'Tableau de bord',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'people',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Patients',
        ),
        // BottomNavigationBarItem(
        //   icon: CustomIconWidget(
        //     iconName: 'account_balance_wallet',
        //     color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        //     size: 24,
        //   ),
        //   label: 'Commissions',
        // ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Resultat',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Profil',
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Données mises à jour avec succès',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleNotificationTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            // ListTile(
            //   leading: CustomIconWidget(
            //     iconName: 'payment',
            //     color: AppTheme.successLight,
            //   ),
            //   title: Text('Paiement reçu'),
            //   subtitle: Text('Commission de Marie Lefevre - 125,50 FCFA'),
            //   trailing: Text('Il y a 2h'),
            // ),
            // ListTile(
            //   leading: CustomIconWidget(
            //     iconName: 'schedule',
            //     color: AppTheme.warningLight,
            //   ),
            //   title: Text('Paiement en attente'),
            //   subtitle: Text('Commission de Jean-Pierre Moreau'),
            //   trailing: Text('Il y a 1j'),
            // ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person_add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Nouveau patient'),
              subtitle: Text('Sophie Bernard a été ajoutée'),
              trailing: Text('Il y a 2j'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
      // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/patient-list');
        break;
      case 2:
      // Navigator.pushNamed(context, '/commission-analytics');
        break;
      case 3:
      // Navigate to analytics screen
        break;
      case 4:
      // Navigate to profile screen
        break;
    }
  }

  void _navigateToPatientList() {
    Navigator.pushNamed(context, '/patient-list');
  }

  void _navigateToPatientDetail(Map<String, dynamic> patient) {
    Navigator.pushNamed(
      context,
      '/patient-detail',
      arguments: patient,
    );
  }

  void _showCommissionDetails(Map<String, dynamic> patient) {
    final String patientName = patient['name'] ?? 'Patient Inconnu';
    final double commissionAmount =
        (patient['commissionAmount'] as num?)?.toDouble() ?? 0.0;
    final String paymentStatus = patient['paymentStatus'] ?? 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Détails Commission',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient: $patientName',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            SizedBox(height: 1.h),
            Text(
              'Montant: ${commissionAmount.toStringAsFixed(2).replaceAll('.', ',')} FCFA',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Statut: ${_getStatusText(paymentStatus)}',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: _getStatusColor(paymentStatus),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fermer',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payé':
        return AppTheme.successLight;
      case 'pending':
      case 'en attente':
        return AppTheme.warningLight;
      case 'overdue':
      case 'en retard':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Payé';
      case 'pending':
        return 'En attente';
      case 'overdue':
        return 'En retard';
      default:
        return 'Inconnu';
    }
  }
}

// CustomIconWidget remains the same as in your original code
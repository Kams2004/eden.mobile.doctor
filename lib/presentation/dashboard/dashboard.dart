import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/request_model.dart';
import './widgets/activity_statistics_grid.dart';
import './widgets/commission_summary_card.dart';
import './widgets/notification_header.dart';
import './widgets/recent_patient_card.dart';
import './widgets/news_carousel.dart';
import '../../presentation/request_page/request_page.dart';
import '../../presentation/notification_page/notification_page.dart';
import '../../presentation/results_page/results_page.dart';
import '../../presentation/login_screen/login_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now();
  List<Map<String, dynamic>> _recentPatients = [];
  bool _isLoadingPatients = true;
  Map<String, int> _statistics = {
    'todayPatients': 0,
    'todayExams': 0,
    'totalPatients': 0,
    'totalExams': 0,
  };
  bool _isLoadingStats = true;

  // Mock data for dashboard
  final Map<String, dynamic> _dashboardData = {
    "doctorName": "Martin Dubois",
    "monthlyCommission": {
      "totalEarnings": 4250.75,
      "pendingPayments": 1320.50,
      "currency": "fcfa"
    },
    "notifications": {"count": 3},
    "newsItems": [
      {
        "id": 1,
        "title": "OCTOBRE ROSE 2025",
        "category": "campagne",
        "description": "Rejoignez notre campagne de sensibilisation au cancer du sein. Dépistage gratuit pour toutes les femmes de 40 à 70 ans.",
        "imageUrl": "https://www.ccdourdannais.com/wp-content/uploads/2021/09/Octobre-Rose.png",
        "fullContent": "Durant tout le mois d'octobre, participez à notre grande campagne de sensibilisation au cancer du sein 'OCTOBRE ROSE 2025'. Nous offrons des consultations gratuites et des mammographies de dépistage pour toutes les femmes âgées de 40 à 70 ans.\\n\\nCette initiative vise à encourager le dépistage précoce qui peut sauver des vies. Le cancer du sein touche 1 femme sur 8 au cours de sa vie, mais détecté tôt, il se guérit dans 9 cas sur 10.\\n\\nNos services offerts :\\n• Consultations gratuites avec nos spécialistes\\n• Mammographies de dépistage\\n• Échographies mammaires\\n• Accompagnement psychologique\\n• Information et conseils préventifs\\n\\nN'hésitez pas à prendre rendez-vous dès maintenant dans l'un de nos centres partenaires. Ensemble, luttons contre le cancer du sein!"
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadRecentPatients();
    _loadStatistics();
  }

  Future<void> _loadRecentPatients() async {
    try {
      setState(() {
        _isLoadingPatients = true;
      });
      
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken != null && doctorId != null) {
        final authService = AuthService();
        
        // Load doctor profile to get name
        try {
          final doctorProfile = await authService.getDoctorProfile(doctorId, accessToken);
          StorageService.setDoctorInfo(doctorProfile.doctorName, doctorProfile.doctorLastname);
        } catch (e) {
          print('Error loading doctor profile: $e');
        }
        
        final response = await authService.getDoctorPatients(doctorId, accessToken);
        
        if (response.dataPatients.isNotEmpty) {
          final uniquePatients = <Map<String, dynamic>>[];
          final seenNames = <String>{};
          
          final sortedPatients = response.dataPatients.toList();
          sortedPatients.sort((a, b) => b.date.compareTo(a.date));
          
          for (final patient in sortedPatients) {
            if (!seenNames.contains(patient.patientName) && uniquePatients.length < 6) {
              seenNames.add(patient.patientName);
              uniquePatients.add({
                'patientName': patient.patientName,
                'date': patient.date,
                'examType': patient.examType,
                'amount': patient.amount,
              });
            }
          }
          
          setState(() {
            _recentPatients = uniquePatients;
            _isLoadingPatients = false;
          });
        } else {
          setState(() {
            _recentPatients = [];
            _isLoadingPatients = false;
          });
        }
      } else {
        setState(() {
          _recentPatients = [];
          _isLoadingPatients = false;
        });
      }
    } catch (e) {
      print('Error loading recent patients: $e');
      setState(() {
        _recentPatients = [];
        _isLoadingPatients = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoadingStats = true;
      });
      
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken != null && doctorId != null) {
        final authService = AuthService();
        final response = await authService.getDoctorPatients(doctorId, accessToken);
        
        if (response.dataPatients.isNotEmpty) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          final currentMonth21 = DateTime(now.year, now.month, 21);
          final previousMonth21 = DateTime(now.year, now.month - 1, 21);
          
          final DateTime periodStart;
          final DateTime periodEnd;
          
          if (now.day >= 21) {
            periodStart = currentMonth21;
            periodEnd = DateTime(now.year, now.month + 1, 21);
          } else {
            periodStart = previousMonth21;
            periodEnd = currentMonth21;
          }
          
          int todayPatients = 0;
          int todayExams = 0;
          int totalPatients = 0;
          int totalExams = 0;
          
          final Set<String> uniquePatientsToday = {};
          final Set<String> uniquePatientsTotal = {};
          
          for (final patient in response.dataPatients) {
            try {
              DateTime examDate;
              if (patient.date.contains('/')) {
                final parts = patient.date.split(' ')[0].split('/');
                examDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
              } else {
                examDate = DateTime.parse(patient.date);
              }
              
              if (examDate.year == today.year && examDate.month == today.month && examDate.day == today.day) {
                uniquePatientsToday.add(patient.patientName);
                todayExams++;
              }
              
              if (examDate.isAfter(periodStart.subtract(Duration(days: 1))) && examDate.isBefore(periodEnd)) {
                uniquePatientsTotal.add(patient.patientName);
                totalExams++;
              }
            } catch (e) {
              print('Error parsing date: ${patient.date}, Error: $e');
            }
          }
          
          todayPatients = uniquePatientsToday.length;
          totalPatients = uniquePatientsTotal.length;
          
          setState(() {
            _statistics = {
              'todayPatients': todayPatients,
              'todayExams': todayExams,
              'totalPatients': totalPatients,
              'totalExams': totalExams,
            };
            _isLoadingStats = false;
          });
        } else {
          setState(() {
            _statistics = {
              'todayPatients': 0,
              'todayExams': 0,
              'totalPatients': 0,
              'totalExams': 0,
            };
            _isLoadingStats = false;
          });
        }
      } else {
        setState(() {
          _statistics = {
            'todayPatients': 0,
            'todayExams': 0,
            'totalPatients': 0,
            'totalExams': 0,
          };
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _statistics = {
          'todayPatients': 0,
          'todayExams': 0,
          'totalPatients': 0,
          'totalExams': 0,
        };
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage("assets/images/overlay2.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // White overlay for readability
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white.withOpacity(.60),
          ),
          SafeArea(
            child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationHeader(
                      notificationCount: ((_dashboardData["notifications"] as Map<String, dynamic>?)?["count"] as int?) ?? 0,
                      onNotificationTap: _handleNotificationTap,
                      onLogoutTap: _showLogoutDialog,
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0),
                      child: Text(
                        'Consultez vos statistiques d\'activité en temps réel.\nSuivez le nombre de patients et d\'examens effectués.',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    _isLoadingStats
                        ? Container(
                            height: 20.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          )
                        : ActivityStatisticsGrid(
                            todayPatients: _statistics['todayPatients'] ?? 0,
                            todayExams: _statistics['todayExams'] ?? 0,
                            totalPatients: _statistics['totalPatients'] ?? 0,
                            totalExams: _statistics['totalExams'] ?? 0,
                          ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actualités',
                            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Découvrez les dernières informations médicales et actualités importantes.\nCampagnes de santé, nouveaux équipements et événements à ne pas manquer.',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    NewsCarousel(
                      newsItems: ((_dashboardData["newsItems"] as List?)?.cast<Map<String, dynamic>>()) ?? [],
                    ),

                    SizedBox(height: 2.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Patients récents',
                                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToPatientList,
                                child: Text(
                                  'Voir tout',
                                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Retrouvez rapidement vos 6 derniers patients examinés.\nAccédez facilement à leurs informations et dates de consultation.',
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 1.h),
                  ],
                ),
              ),

              _isLoadingPatients
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 20.h,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : _recentPatients.isEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                            height: 15.h,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 48,
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Aucun patient récent',
                                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= _recentPatients.length) return null;
                              final patient = _recentPatients[index];
                              return RecentPatientCard(
                                patient: patient,
                                onTap: () => _navigateToPatientDetail(patient),
                                onCommissionView: () => _showCommissionDetails(patient),
                                onPatientDetails: () => _navigateToPatientDetail(patient),
                              );
                            },
                            childCount: _recentPatients.length,
                          ),
                        ),

              SliverToBoxAdapter(
                child: SizedBox(height: 10.h),
              ),
            ],
          ),
        ),)
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w,vertical: 1.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard, 'Accueil', 0, true),
              _buildNavItem(Icons.people, 'Patients', 1, false),
              _buildNavItem(Icons.assignment, 'Résultats', 2, false),
              _buildNavItem(Icons.request_page, 'Requête', 3, false),
              _buildNavItem(Icons.person, 'Profil', 4, false),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildNavItem(IconData icon, String label, int index, bool isSelected) {
  return Flexible( // Use Flexible instead of Expanded
    child: GestureDetector(
      onTap: () => _handleBottomNavTap(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF3B82F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Color(0xFF64748B),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.wait([
      _loadRecentPatients(),
      _loadStatistics(),
    ]);

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPage(),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/patient-list');
        break;
      case 2:
        Navigator.pushNamed(context, '/results');
        break;
      case 3:
        Navigator.pushNamed(context, '/request-page');
        break;
      case 4:
        Navigator.pushNamed(context, '/doctor-profile');
        break;
    }
  }

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
            Text(
              'Support & Assistance',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Service d\'aide',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 3.h),
            _buildContactCard(
              'Relations publiques',
              '+237 696134160',
              Icons.public,
              Color(0xFF3B82F6),
            ),
            SizedBox(height: 1.h),
            _buildContactCard(
              'Service technique',
              '+237 695995842',
              Icons.engineering,
              Color(0xFF10B981),
            ),
            SizedBox(height: 3.h),
            Text(
              'Au service de votre santé',
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(String title, String phone, IconData icon, Color color) {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Color(0xFF25D366).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat,
                color: Color(0xFF25D366),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Déconnexion',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Déconnexion',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final accessToken = StorageService.accessToken;
      if (accessToken != null) {
        final authService = AuthService();
        await authService.logout(accessToken);
      }
    } catch (e) {
      print('Logout API error (continuing anyway): $e');
    }
    
    // Always clear data and navigate, regardless of API response
    StorageService.clearData();
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

void _showRequestForm() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RequestPage(), // Your destination screen widget
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
    final String patientName = patient['patientName'] ?? 'Patient Inconnu';
    final double commissionAmount = (patient['amount'] as num?)?.toDouble() ?? 0.0;

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
}

class _RequestFormBottomSheet extends StatefulWidget {
  @override
  _RequestFormBottomSheetState createState() => _RequestFormBottomSheetState();
}

class _RequestFormBottomSheetState extends State<_RequestFormBottomSheet> {
  String selectedRequestType = '';
  final TextEditingController detailsController = TextEditingController();
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Envoyer une Requête',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 1.h,
                        childAspectRatio: crossAxisCount == 3 ? 2.2 : 2.5,
                        children: [
                          _buildRequestTypeCard(
                            'Commission',
                            'Problèmes liés aux commissions',
                            selectedRequestType == 'commission',
                            () => setState(() => selectedRequestType = 'commission'),
                          ),
                          _buildRequestTypeCard(
                            'Connexion',
                            'Problèmes de connexion',
                            selectedRequestType == 'connection',
                            () => setState(() => selectedRequestType = 'connection'),
                          ),
                          _buildRequestTypeCard(
                            'Erreur',
                            'Signaler une erreur',
                            selectedRequestType == 'error',
                            () => setState(() => selectedRequestType = 'error'),
                          ),
                          _buildRequestTypeCard(
                            'Administration',
                            'Questions administratives',
                            selectedRequestType == 'administration',
                            () => setState(() => selectedRequestType = 'administration'),
                          ),
                          _buildRequestTypeCard(
                            'Revendication Examen',
                            'Revendication d\'examen',
                            selectedRequestType == 'revendication_examen',
                            () => setState(() => selectedRequestType = 'revendication_examen'),
                          ),
                          _buildRequestTypeCard(
                            'Suggestion',
                            'Faire une suggestion',
                            selectedRequestType == 'suggestion',
                            () => setState(() => selectedRequestType = 'suggestion'),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    'Détails de la Requête *',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: detailsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Décrivez votre requête en détail...',
                        hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(3.w),
                      ),
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedRequestType.isNotEmpty && detailsController.text.isNotEmpty && !isSubmitting
                        ? _submitRequest
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 16),
                              SizedBox(width: 1.w),
                              Text(
                                'Envoyer',
                                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTypeCard(String title, String description, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: 2,
                    ),
                    color: isSelected 
                        ? AppTheme.lightTheme.colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected 
                      ? Icon(
                          Icons.check,
                          size: 2.w,
                          color: Colors.white,
                        )
                      : null,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 8.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final accessToken = StorageService.accessToken;
      final doctorId = StorageService.doctorId;
      
      if (accessToken == null || doctorId == null) {
        throw Exception('Données d\'authentification manquantes');
      }

      final authService = AuthService();
      final doctorProfile = await authService.getDoctorProfile(doctorId, accessToken);
      
      final request = RequestModel(
        administration: selectedRequestType == 'administration',
        commission: selectedRequestType == 'commission',
        connection: selectedRequestType == 'connection',
        email: doctorProfile.doctorEmail,
        error: selectedRequestType == 'error',
        firstName: doctorProfile.doctorName,
        lastName: doctorProfile.doctorLastname,
        message: detailsController.text,
        revendicationExamen: selectedRequestType == 'revendication_examen',
        suggestion: selectedRequestType == 'suggestion',
      );

      await authService.submitRequest(request);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Requête envoyée avec succès',
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l\'envoi: $e',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }
}
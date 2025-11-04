import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../patient-presentation/laboratory_results_list/laboratory_results_list.dart';
import '../../patient-presentation/imagery_results_list/imagery_results_list.dart';
import '../../patient-presentation/shared_results_list/shared_results_list.dart';
import '../../patient-presentation/patient_requests/patient_requests_list.dart';
import '../../patient-presentation/patient_notifications/patient_notifications.dart';
import '../../patient-presentation/exploration_results_list/exploration_results_list.dart';
import '../../patient-presentation/prescription/prescription_page.dart';
import '../../patient-presentation/patient_profile/patient_profile_screen.dart';
import '../../patient-presentation/invoices/invoices_page.dart';

class PatientSidebar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onLogout;

  const PatientSidebar({
    Key? key,
    required this.currentRoute,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75.w,
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact Header
          Container(
            padding: EdgeInsets.only(top: 6.h, bottom: 2.h, left: 6.w, right: 6.w),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: Row(
              children: [
                // PDMD Logo
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/pdmd.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'PDMD',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EDEN - PDMD',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Espace Patient',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: ListView(
                children: [
                  _buildSectionHeader('TABLEAU DE BORD'),
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Accueil',
                    route: '/patient-dashboard',
                  ),
                  
                  SizedBox(height: 1.h),

                      _buildMenuItem(
                    context,
                    icon: Icons.receipt,
                    title: 'Factures',
                    route: '/patient-invoices',
                  ),
                  SizedBox(height: 1.h),

                  _buildSectionHeader('RÉSULTATS MÉDICAUX'),
                  _buildMenuItem(
                    context,
                    icon: Icons.biotech,
                    title: 'Laboratoire',
                    route: '/laboratory-results-list',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.medical_services,
                    title: 'Imagerie',
                    route: '/imagery-results-list',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.monitor_heart,
                    title: 'Exploration',
                    route: '/exploration-results',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Prescriptions',
                    route: '/prescription',
                  ),
              
                  
                  SizedBox(height: 1.h),
                  _buildSectionHeader('COMMUNICATION'),
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment,
                    title: 'Requêtes',
                    route: '/patient-requests',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.share,
                    title: 'Résultats Partagés',
                    route: '/patient-resultats-partages',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifications',
                    route: '/patient-notifications-settings',
                    hasNotification: _hasUnreadNotifications(),
                  ),
                  
                  SizedBox(height: 1.h),
                  _buildSectionHeader('COMPTE'),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Profil',
                    route: '/patient-profile',
                  ),
        
                ],
              ),
            ),
          ),
          
          // Logout Section
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(
                top: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3.w, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF991B1B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 1.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Color.fromARGB(255, 142, 155, 173),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  bool _hasUnreadNotifications() {
    // This would need to be passed from parent or fetched from storage
    // For now, return false - will be updated when notifications are loaded
    return false;
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    bool hasNotification = false,
  }) {
    final isSelected = currentRoute == route;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (!isSelected) {
              _navigateToRoute(context, route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF3B82F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : Color(0xFF334155),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? Colors.white : Color(0xFF94A3B8),
                        size: 5.w,
                      ),
                      if (hasNotification)
                        Positioned(
                          right: 0.5.w,
                          top: 0.5.w,
                          child: Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 3.w,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    switch (route) {
      case '/patient-dashboard':
        Navigator.pushReplacementNamed(context, route);
        break;
      case '/laboratory-results-list':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LaboratoryResultsList(),
          ),
        );
        break;
      case '/imagery-results-list':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageryResultsList(),
          ),
        );
        break;
      case '/patient-resultats-partages':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SharedResultsList(),
          ),
        );
        break;
      case '/patient-requests':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientRequestsList(),
          ),
        );
        break;
      case '/patient-notifications-settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientNotifications(),
          ),
        );
        break;
      case '/exploration-results':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExplorationResultsList(),
          ),
        );
        break;
      case '/prescription':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionPage(),
          ),
        );
        break;
      case '/patient-invoices':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicesPage(),
          ),
        );
        break;
      case '/patient-profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientProfileScreen(),
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('En construction'),
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 12.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Cette fonctionnalité est en cours de développement',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Déconnexion',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16.sp,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Déconnexion',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
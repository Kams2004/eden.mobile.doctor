import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
      width: 70.w,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with user info
          Container(
            padding: EdgeInsets.only(top: 8.h, bottom: 4.h, left: 4.w, right: 4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 8.w,
                  backgroundColor: Color(0xFF3B82F6),
                  child: Icon(
                    Icons.person,
                    size: 8.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Patient',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Tableau de bord',
                  route: '/patient-dashboard',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Laboratoire',
                  route: '/patient-laboratoire',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: 'Imagerie',
                  route: '/patient-Imagerie',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Prescriptions',
                  route: '/patient-prescriptions',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.cloud_outlined,
                  title: 'Exploration',
                  route: '/patient-exploration',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.flight_outlined,
                  title: 'Resultats Partages',
                  route: '/patient-resultats-partages',
                ),
            
                
                // Divider
                Container(
                  margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                  height: 1,
                  color: Colors.grey[200],
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications',
                  route: '/patient-notifications-settings',
                  hasNotification: true,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Paramètres',
                  route: '/patient-settings',
                ),
              ],
            ),
          ),
          
          // Footer with user profile and logout
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 4.w,
                    backgroundColor: Color(0xFF3B82F6),
                    child: Icon(
                      Icons.person,
                      size: 4.w,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Mon Profil',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 5.w,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/patient-profile');
                  },
                ),
                SizedBox(height: 1.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 5.w,
                  ),
                  title: Text(
                    'Déconnexion',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (!isSelected) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFF3B82F6).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Color(0xFF3B82F6) : Colors.grey[600],
                      size: 5.w,
                    ),
                    if (hasNotification)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Color(0xFF3B82F6) : Colors.grey[800],
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 1.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Déconnexion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?',
            style: TextStyle(
              color: Colors.grey[600],
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
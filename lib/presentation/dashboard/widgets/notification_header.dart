import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/storage_service.dart';

class NotificationHeader extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogoutTap;

  const NotificationHeader({
    Key? key,
    required this.notificationCount,
    this.onNotificationTap,
    this.onLogoutTap,
  }) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour,';
    } else if (hour < 17) {
      return 'Bon après-midi,';
    } else {
      return 'Bonsoir,';
    }
  }

  String _getDoctorName() {
    final firstName = StorageService.doctorName ?? '';
    final lastName = StorageService.doctorLastname ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return 'Docteur';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getDoctorName(),
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Language Icon
              Container(
                padding: EdgeInsets.all(1.w),
    
                child: Icon(
                  Icons.language,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
              // Theme Toggle Icon
              Container(
                padding: EdgeInsets.all(1.w),
        
                child: Icon(
                  Icons.light_mode,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
              // Notification Icon
              GestureDetector(
                onTap: onNotificationTap,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  child: Stack(
                    children: [
                      CustomIconWidget(
                        iconName: 'notifications',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.errorLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              notificationCount > 99
                                  ? '99+'
                                  : notificationCount.toString(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 8.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Logout Icon
            GestureDetector(
  onTap: onLogoutTap,
  child: Container(
    width: 10.w, // Control width
    height:10.w, // Control height (same as width for perfect circle)
    padding: EdgeInsets.all(3.w),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 12, 114, 247),
  borderRadius: BorderRadius.circular(8),      
    ),
    child: Icon(
      Icons.logout,
      color: Colors.white,
      size: 20,
    ),
  ),
),
            ],
          ),
        ],
      ),
    );
  }
}

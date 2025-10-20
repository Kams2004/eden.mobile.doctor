import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_empty_state.dart';

class PatientNotifications extends StatefulWidget {
  const PatientNotifications({super.key});

  @override
  State<PatientNotifications> createState() => _PatientNotificationsState();
}

class _PatientNotificationsState extends State<PatientNotifications> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final userId = StorageService.userId;
      
      if (accessToken == null || userId == null) {
        throw Exception('Données d\'authentification manquantes');
      }
      
      final notifications = await authService.getUserNotifications(userId, accessToken);
      
      // Enrich notifications with type information
      final enrichedNotifications = <Map<String, dynamic>>[];
      for (final notification in notifications) {
        try {
          final typeInfo = await authService.getNotificationTypeById(notification['types'] ?? 0, accessToken);
          final enrichedNotification = Map<String, dynamic>.from(notification);
          enrichedNotification['type_info'] = typeInfo;
          enrichedNotifications.add(enrichedNotification);
        } catch (e) {
          // If type info fails, add notification without type info
          enrichedNotifications.add(notification);
        }
      }
      
      setState(() {
        _notifications = enrichedNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleLogout() {
    StorageService.clearData();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-notifications-settings',
          onLogout: _handleLogout,
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF3B82F6)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3B82F6)),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: Colors.red,
            ),
            SizedBox(height: 2.h),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return NotificationEmptyState(
        onRefresh: _loadNotifications,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return NotificationCard(
            notification: _notifications[index],
          );
        },
      ),
    );
  }
}
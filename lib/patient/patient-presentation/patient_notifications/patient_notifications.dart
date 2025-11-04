import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/theme_service.dart';
import '../../patient-widgets/widgets/patient_sidebar.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_empty_state.dart';
import '../imagery_results_list/widgets/imagery_skeleton_loader.dart';
import '../../patient-widgets/widgets/professional_app_bar.dart';

class PatientNotifications extends StatefulWidget {
  const PatientNotifications({super.key});

  @override
  State<PatientNotifications> createState() => _PatientNotificationsState();
}

class _PatientNotificationsState extends State<PatientNotifications> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String? _error;
  String _filterType = 'all';
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _loadNotifications();
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  int? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadMap = json.decode(decodedPayload) as Map<String, dynamic>;
      
      final sub = payloadMap['sub'];
      if (sub is int) return sub;
      if (sub is String) return int.tryParse(sub);
      return null;
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      
      if (accessToken == null) {
        throw Exception('Token d\'accès manquant');
      }
      
      final userId = _extractUserIdFromToken(accessToken);
      if (userId == null) {
        throw Exception('Impossible d\'extraire l\'ID utilisateur du token');
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

  void _onNotificationMarkRead() {
    // Refresh notifications to update unread count
    _loadNotifications();
  }

  List<Map<String, dynamic>> _getFilteredNotifications() {
    switch (_filterType) {
      case 'unread':
        return _notifications.where((n) => !(n['is_read'] ?? false)).toList();
      case 'read':
        return _notifications.where((n) => n['is_read'] ?? false).toList();
      default:
        return _notifications;
    }
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : (_themeService.isDarkMode ? Color(0xFF374151) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF3B82F6) : (_themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
          ),
        ),
      ),
    );
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
      backgroundColor: _themeService.isDarkMode ? Color(0xFF0F172A) : Colors.grey[50],
      drawer: Drawer(
        child: PatientSidebar(
          currentRoute: '/patient-notifications-settings',
          onLogout: _handleLogout,
        ),
      ),
      appBar: ProfessionalAppBar(
        title: 'Notifications',
        subtitle: 'Messages et alertes',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 5.w),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_themeService.isDarkMode)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/overlay2.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (_themeService.isDarkMode)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                  ],
                ),
              ),
            ),
          if (!_themeService.isDarkMode)
            Container(
              color: Colors.white.withOpacity(0.7),
            ),
          _buildNotificationsList(),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return ImagerySkeletonLoader(itemCount: 6);
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: _themeService.isDarkMode ? Colors.white : Colors.red,
            ),
            SizedBox(height: 2.h),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _themeService.isDarkMode ? Colors.white : Colors.red,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
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

    final filteredNotifications = _getFilteredNotifications();
    
    if (filteredNotifications.isEmpty) {
      return Column(
        children: [
          // Filter section (same as above)
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filtrer:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _themeService.isDarkMode ? Colors.white : Colors.grey[700],
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Toutes', 'all'),
                        SizedBox(width: 2.w),
                        _buildFilterChip('Non lues', 'unread'),
                        SizedBox(width: 2.w),
                        _buildFilterChip('Lues', 'read'),
                      ],
                    ),
                  ),
                ),
                if (_notifications.where((n) => !(n['is_read'] ?? false)).isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_notifications.where((n) => !(n['is_read'] ?? false)).length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: NotificationEmptyState(
              onRefresh: _loadNotifications,
              message: _filterType == 'all' ? 'Aucune notification' : 
                      _filterType == 'unread' ? 'Aucune notification non lue' : 'Aucune notification lue',
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Filter section
        Container(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Text(
                'Filtrer:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Toutes', 'all'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Non lues', 'unread'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Lues', 'read'),
                    ],
                  ),
                ),
              ),
              if (_notifications.where((n) => !(n['is_read'] ?? false)).isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_notifications.where((n) => !(n['is_read'] ?? false)).length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Notifications list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(
                  notification: filteredNotifications[index],
                  onMarkRead: _onNotificationMarkRead,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
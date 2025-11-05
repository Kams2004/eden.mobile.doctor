import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../model/notification_model.dart';
import '../widgets/doctor_professional_app_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  List<NotificationModel> allNotifications = [];
  List<NotificationModel> filteredNotifications = [];
  Map<int, String> notificationTypes = {};
  Map<String, bool> expandedTypes = {};
  String selectedFilter = 'Toutes les notifications';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = StorageService.userId;
      final accessToken = StorageService.accessToken;
      
      print('Loading notifications for userId: $userId');
      print('Access token: ${accessToken?.substring(0, 10)}...');
      
      if (userId != null && accessToken != null) {
        final authService = AuthService();
        final notifications = await authService.getNotifications(userId, accessToken);
        
        // Load notification types for each unique type ID
        final typeIds = notifications.map((n) => n.types).toSet();
        for (final typeId in typeIds) {
          try {
            final type = await authService.getNotificationType(typeId, accessToken);
            notificationTypes[typeId] = type.name;
          } catch (e) {
            print('Error loading type $typeId: $e');
            notificationTypes[typeId] = 'Type $typeId';
          }
        }
        
        setState(() {
          allNotifications = notifications;
          filteredNotifications = notifications;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final accessToken = StorageService.accessToken;
      if (accessToken != null) {
        final authService = AuthService();
        await authService.deleteNotification(notificationId, accessToken);
        
        setState(() {
          allNotifications.removeWhere((n) => n.id == notificationId);
          filteredNotifications.removeWhere((n) => n.id == notificationId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification supprimée avec succès'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final accessToken = StorageService.accessToken;
      if (accessToken != null) {
        final authService = AuthService();
        await authService.markNotificationAsRead([notificationId], accessToken);
        
        setState(() {
          final index = allNotifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            allNotifications[index] = NotificationModel(
              id: allNotifications[index].id,
              title: allNotifications[index].title,
              message: allNotifications[index].message,
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
              createdAt: allNotifications[index].createdAt,
              updatedAt: allNotifications[index].updatedAt,
              userId: allNotifications[index].userId,
              types: allNotifications[index].types,
              allUsers: allNotifications[index].allUsers,
            );
          }
        });
        _filterNotifications();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification marquée comme lue'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du marquage: $e'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }

  void _filterNotifications() {
    setState(() {
      filteredNotifications = allNotifications.where((notification) {
        final matchesSearch = searchController.text.isEmpty ||
            notification.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
            notification.message.toLowerCase().contains(searchController.text.toLowerCase());
        
        final matchesFilter = selectedFilter == 'Toutes les notifications' ||
            (selectedFilter == 'Non lues' && !notification.isRead) ||
            (selectedFilter == 'Lues' && notification.isRead);
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = allNotifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: DoctorProfessionalAppBar(
        title: 'Toutes les notifications',
        subtitle: '${allNotifications.length} notifications au total',
        icon: Icons.notifications_active,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => _filterNotifications(),
                      decoration: InputDecoration(
                        hintText: 'Rechercher des notifications...',
                        hintStyle: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.w),
                  Row(
                    children: [
                      _buildFilterChip('Toutes les notifications', allNotifications.length),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Non lues', unreadCount),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Lues', allNotifications.length - unreadCount),
                    ],
                  ),
                ],
              ),
            ),

            // Notifications List
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF3B82F6)),
                          SizedBox(height: 3.w),
                          Text(
                            'Chargement des notifications...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.notifications_off_outlined,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              SizedBox(height: 4.w),
                              Text(
                                'Aucune notification trouvée',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 2.w),
                              Text(
                                'Vos notifications apparaîtront ici',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.all(4.w),
                          children: _buildGroupedNotifications(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
          _filterNotifications();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 3.w),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3B82F6) : Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Color(0xFF3B82F6) : Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label == 'Non lues')
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              if (label == 'Non lues') SizedBox(width: 1.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final typeName = notificationTypes[notification.types] ?? 'INFOS';
    final typeColor = _getTypeColor(typeName);
    
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Color(0xFFE2E8F0) : Color(0xFF3B82F6).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(typeName),
                            size: 14,
                            color: typeColor,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            typeName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.w),
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2.w),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 3.w),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Spacer(),
                    if (!notification.isRead)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Priorité basse',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  if (!notification.isRead)
                    GestureDetector(
                      onTap: () => _markAsRead(notification.id),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Marquer comme lue',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Déjà lue',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => _deleteNotification(notification.id),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'infos':
        return Color(0xFF3B82F6);
      case 'alert':
        return Color(0xFFF59E0B);
      case 'error':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'infos':
        return Icons.info_outline;
      case 'alert':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.replaceAll('GMT', '').trim());
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else {
        return '${difference.inDays}j';
      }
    } catch (e) {
      return '';
    }
  }

  List<Widget> _buildGroupedNotifications() {
    final groupedNotifications = <String, List<NotificationModel>>{};
    
    // Group notifications by type
    for (final notification in filteredNotifications) {
      final typeName = notificationTypes[notification.types] ?? 'INFOS';
      if (!groupedNotifications.containsKey(typeName)) {
        groupedNotifications[typeName] = [];
        expandedTypes[typeName] = true; // Default to expanded
      }
      groupedNotifications[typeName]!.add(notification);
    }
    
    final widgets = <Widget>[];
    
    groupedNotifications.forEach((typeName, notifications) {
      final typeColor = _getTypeColor(typeName);
      final isExpanded = expandedTypes[typeName] ?? true;
      
      // Type header
      widgets.add(
        Container(
          margin: EdgeInsets.only(bottom: 2.w),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: typeColor.withOpacity(0.3)),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                expandedTypes[typeName] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(typeName),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${notifications.length} notification${notifications.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.check,
                      color: typeColor,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: typeColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
      // Notifications under this type
      if (isExpanded) {
        for (final notification in notifications) {
          widgets.add(_buildSimpleNotificationCard(notification));
        }
      }
      
      widgets.add(SizedBox(height: 3.w));
    });
    
    return widgets;
  }

  Widget _buildSimpleNotificationCard(NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.w, left: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.w),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 3.w),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Priorité basse',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (!notification.isRead)
                  GestureDetector(
                    onTap: () => _markAsRead(notification.id),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Marquer comme lue',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Déjà lue',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                Spacer(),
                GestureDetector(
                  onTap: () => _deleteNotification(notification.id),
                  child: Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.replaceAll('GMT', '').trim());
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
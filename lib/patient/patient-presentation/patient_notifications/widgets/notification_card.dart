import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/theme_service.dart';

class NotificationCard extends StatefulWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onMarkRead;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onMarkRead,
  }) : super(key: key);

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isMarkingRead = false;
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        // Only mark as read when tapped to expand
        _markAsReadIfNeeded();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _markAsReadIfNeeded() async {
    final isRead = widget.notification['is_read'] ?? false;
    if (!isRead && !_isMarkingRead) {
      await _markAsRead();
    }
  }

  Future<void> _markAsRead() async {
    if (_isMarkingRead) return;
    
    setState(() {
      _isMarkingRead = true;
    });
    
    try {
      final authService = AuthService();
      final accessToken = StorageService.accessToken;
      final notificationId = widget.notification['id'];
      
      if (accessToken != null && notificationId != null) {
        await authService.markNotificationRead(notificationId, accessToken);
        widget.notification['is_read'] = true;
        widget.onMarkRead?.call();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingRead = false;
        });
      }
    }
  }

  IconData _getNotificationIcon() {
    final typeInfo = widget.notification['type_info'];
    if (typeInfo != null) {
      final typeName = typeInfo['name']?.toString().toUpperCase() ?? '';
      switch (typeName) {
        case 'INFOS':
          return Icons.info_outline;
        case 'ALERT':
          return Icons.warning_outlined;
        case 'SUCCESS':
          return Icons.check_circle_outline;
        case 'ERROR':
          return Icons.error_outline;
        default:
          return Icons.notifications_outlined;
      }
    }
    return Icons.notifications_outlined;
  }

  Color _getNotificationColor() {
    final typeInfo = widget.notification['type_info'];
    if (typeInfo != null) {
      final typeName = typeInfo['name']?.toString().toUpperCase() ?? '';
      switch (typeName) {
        case 'INFOS':
          return Color(0xFF3B82F6);
        case 'ALERT':
          return Colors.orange;
        case 'SUCCESS':
          return Colors.green;
        case 'ERROR':
          return Colors.red;
        default:
          return Color(0xFF3B82F6);
      }
    }
    return Color(0xFF3B82F6);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}j';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}min';
      } else {
        return 'Maintenant';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = widget.notification['is_read'] ?? false;
    final title = widget.notification['title'] ?? 'Notification';
    final message = widget.notification['message'] ?? '';
    final createdAt = widget.notification['created_at'];
    final typeInfo = widget.notification['type_info'];
    final typeName = typeInfo?['name'] ?? 'NOTIFICATION';
    final typeDescription = typeInfo?['description'] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isRead ? (_themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[200]!) : _getNotificationColor().withOpacity(0.3),
                width: isRead ? 1 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _themeService.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification icon
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _getNotificationColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getNotificationIcon(),
                          color: _getNotificationColor(),
                          size: 5.w,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and time on same row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                      color: _themeService.isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatDate(createdAt),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    margin: EdgeInsets.only(left: 2.w),
                                    width: 2.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      color: _getNotificationColor(),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            
                            // Type badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: _getNotificationColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                typeName,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getNotificationColor(),
                                ),
                              ),
                            ),
                            
                            // Message preview (only when expanded)
                            if (_isExpanded) ...[
                              SizedBox(height: 1.h),
                              Text(
                                message,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ],
                            SizedBox(height: 1.h),
                            
                            // Expand indicator and mark read button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (!isRead && _isExpanded)
                                  ElevatedButton(
                                    onPressed: _isMarkingRead ? null : _markAsRead,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getNotificationColor(),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                                      minimumSize: Size(0, 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    child: _isMarkingRead
                                        ? SizedBox(
                                            width: 3.w,
                                            height: 3.w,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'Marquer lu',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  )
                                else
                                  SizedBox.shrink(),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration: Duration(milliseconds: 300),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[400],
                                    size: 5.w,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Expanded content
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                    decoration: BoxDecoration(
                      color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        
                        Text(
                          'Date et Heure:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _themeService.isDarkMode ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatFullDate(createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatFullDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/theme_service.dart';

class NotificationEmptyState extends StatefulWidget {
  final VoidCallback onRefresh;
  final String? message;

  const NotificationEmptyState({
    Key? key,
    required this.onRefresh,
    this.message,
  }) : super(key: key);

  @override
  State<NotificationEmptyState> createState() => _NotificationEmptyStateState();
}

class _NotificationEmptyStateState extends State<NotificationEmptyState> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 20.w,
              color: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.message ?? 'Aucune notification',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: _themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Vous n\'avez aucune notification pour le moment.\nCliquez le bouton en bas pour actualiser.',
            style: TextStyle(
              fontSize: 14.sp,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: widget.onRefresh,
            icon: Icon(Icons.refresh),
            label: Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../services/theme_service.dart';

class DoctorProfessionalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const DoctorProfessionalAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = ThemeService();
    
    return AppBar(
      backgroundColor: themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      leading: showBackButton ? Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: themeService.isDarkMode ? Color(0xFF374151) : Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: onBackPressed ?? () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: themeService.isDarkMode ? Colors.white : Color(0xFF334155),
            size: 20,
          ),
        ),
      ) : null,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: showBackButton ? 0 : 4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon ?? Icons.assignment_outlined,
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
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: themeService.isDarkMode ? Colors.white : Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
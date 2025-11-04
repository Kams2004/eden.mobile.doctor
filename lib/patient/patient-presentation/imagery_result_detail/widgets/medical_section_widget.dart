import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../services/theme_service.dart';

class MedicalSectionWidget extends StatefulWidget {
  final String title;
  final String content;
  final String? technicalDetails;
  final bool isExpandable;
  final List<String>? keyFindings;

  const MedicalSectionWidget({
    super.key,
    required this.title,
    required this.content,
    this.technicalDetails,
    this.isExpandable = false,
    this.keyFindings,
  });

  @override
  State<MedicalSectionWidget> createState() => _MedicalSectionWidgetState();
}

class _MedicalSectionWidgetState extends State<MedicalSectionWidget> {
  bool _isExpanded = false;
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _themeService.isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                  ),
                ),
              ),
              if (widget.isExpandable && widget.technicalDetails != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: _themeService.isDarkMode ? Color(0xFF374151) : Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: CustomIconWidget(
                      iconName: _isExpanded ? 'expand_less' : 'expand_more',
                      color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            widget.content,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.black87,
              height: 1.5,
            ),
          ),
          if (widget.keyFindings != null &&
              (widget.keyFindings as List).isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _themeService.isDarkMode ? Color(0xFF374151) : Color(0xFF3B82F6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: _themeService.isDarkMode ? Color(0xFF4B5563) : Color(0xFF3B82F6).withOpacity(0.2),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Points clés',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  ...(widget.keyFindings as List).map((finding) => Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0.8.h, right: 2.w),
                              width: 1.w,
                              height: 1.w,
                              decoration: BoxDecoration(
                                color: _themeService.isDarkMode ? Colors.white : Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                finding as String,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          if (widget.isExpandable && widget.technicalDetails != null)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                margin: EdgeInsets.only(top: 2.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: _themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'science',
                          color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Détails techniques',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.technicalDetails!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
        ],
      ),
    );
  }
}

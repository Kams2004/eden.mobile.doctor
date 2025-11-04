import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/theme_service.dart';

class SharedResultsHeader extends StatefulWidget {
  final String searchQuery;
  final String selectedFilter;
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;

  const SharedResultsHeader({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  State<SharedResultsHeader> createState() => _SharedResultsHeaderState();
}

class _SharedResultsHeaderState extends State<SharedResultsHeader> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: _themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher résultats partagés...',
                hintStyle: TextStyle(
                  color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[500],
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[500],
                  size: 5.w,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tous'),
                SizedBox(width: 2.w),
                _buildFilterChip('Laboratoire'),
                SizedBox(width: 2.w),
                _buildFilterChip('Imagerie'),
                SizedBox(width: 2.w),
                _buildFilterChip('Exploration'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = widget.selectedFilter == label;
    
    return GestureDetector(
      onTap: () => widget.onFilterChanged(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : (_themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (_themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700]),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
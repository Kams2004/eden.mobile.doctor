import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../services/theme_service.dart';

class SharedResultsEmptyState extends StatefulWidget {
  final bool isSearchResult;
  final String searchQuery;
  final VoidCallback onRefresh;

  const SharedResultsEmptyState({
    super.key,
    required this.isSearchResult,
    required this.searchQuery,
    required this.onRefresh,
  });

  @override
  State<SharedResultsEmptyState> createState() => _SharedResultsEmptyStateState();
}

class _SharedResultsEmptyStateState extends State<SharedResultsEmptyState> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isSearchResult ? Icons.search_off : Icons.share_outlined,
            size: 15.w,
            color: _themeService.isDarkMode ? Color(0xFF6B7280) : Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            widget.isSearchResult 
                ? 'Aucun résultat pour "${widget.searchQuery}"'
                : 'Aucun résultat partagé',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: _themeService.isDarkMode ? Colors.white : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              widget.isSearchResult
                  ? 'Essayez de modifier votre recherche ou d\'ajuster les filtres'
                  : 'Vos résultats partagés avec les médecins apparaîtront ici',
              style: TextStyle(
                fontSize: 14.sp,
                color: _themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: widget.onRefresh,
            icon: Icon(Icons.refresh),
            label: Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
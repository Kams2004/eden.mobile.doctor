import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../patient-core/core/app_export.dart';

/// Search header widget with search functionality and filter options
class ImagerySearchHeader extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;

  const ImagerySearchHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  State<ImagerySearchHeader> createState() => _ImagerySearchHeaderState();
}

class _ImagerySearchHeaderState extends State<ImagerySearchHeader> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSearchField(colorScheme),
              ),
              SizedBox(width: 3.w),
              _buildFilterButton(colorScheme),
            ],
          ),
          SizedBox(height: 1.h),
          _buildQuickFilters(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher examens d\'imagerie...',
          hintStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 5.w,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
        ),
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildFilterButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: widget.hasActiveFilters
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.hasActiveFilters
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onFilterTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Stack(
            children: [
              CustomIconWidget(
                iconName: 'tune',
                color: widget.hasActiveFilters
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                size: 6.w,
              ),
              if (widget.hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters(ColorScheme colorScheme) {
    final quickFilters = [
      {'label': 'Aujourd\'hui', 'value': 'date:today'},
      {'label': 'Cette semaine', 'value': 'date:week'},
      {'label': 'Radiographie', 'value': 'type:xray'},
      {'label': 'IRM', 'value': 'type:mri'},
      {'label': 'Scanner', 'value': 'type:ct'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickFilters
            .map((filter) => _buildQuickFilterChip(
                  filter['label']!,
                  filter['value']!,
                  colorScheme,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuickFilterChip(
      String label, String value, ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: InkWell(
        onTap: () => _handleQuickFilter(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }

  void _handleQuickFilter(String filterValue) {
    // This would typically communicate with parent to apply the filter
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtre appliqué: $filterValue'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
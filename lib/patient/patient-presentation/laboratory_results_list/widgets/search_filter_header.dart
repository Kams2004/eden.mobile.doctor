import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../patient-core/core/app_export.dart';

class SearchFilterHeader extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final List<String> activeFilters;
  final Function(String) onRemoveFilter;

  const SearchFilterHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.activeFilters,
    required this.onRemoveFilter,
  });

  @override
  State<SearchFilterHeader> createState() => _SearchFilterHeaderState();
}

class _SearchFilterHeaderState extends State<SearchFilterHeader> {
  bool _isSearchFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSearchFocused
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.3),
                        width: _isSearchFocused ? 2 : 1,
                      ),
                      boxShadow: _isSearchFocused
                          ? [
                              BoxShadow(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: widget.searchController,
                      onChanged: widget.onSearchChanged,
                      onTap: () => setState(() => _isSearchFocused = true),
                      onTapOutside: (_) =>
                          setState(() => _isSearchFocused = false),
                      decoration: InputDecoration(
                        hintText: 'Rechercher des résultats...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'search',
                            color: _isSearchFocused
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 5.w,
                          ),
                        ),
                        suffixIcon: widget.searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  widget.searchController.clear();
                                  widget.onSearchChanged('');
                                },
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  decoration: BoxDecoration(
                    color: widget.activeFilters.isNotEmpty
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.activeFilters.isNotEmpty
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onFilterTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        child: Stack(
                          children: [
                            CustomIconWidget(
                              iconName: 'tune',
                              color: widget.activeFilters.isNotEmpty
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                              size: 6.w,
                            ),
                            if (widget.activeFilters.isNotEmpty)
                              Positioned(
                                right: -1,
                                top: -1,
                                child: Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningLight,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 4.w,
                                    minHeight: 4.w,
                                  ),
                                  child: Text(
                                    '${widget.activeFilters.length}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.activeFilters.isNotEmpty) _buildActiveFilters(colorScheme),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres actifs:',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: widget.activeFilters.map((filter) {
              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onRemoveFilter(filter),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'close',
                            color: colorScheme.primary,
                            size: 4.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

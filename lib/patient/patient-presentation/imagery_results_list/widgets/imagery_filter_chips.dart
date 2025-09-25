import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../patient-core/core/app_export.dart';
import '../../../../patient-widgets/widgets/custom_icon_widget.dart';

/// Filter chips widget for imagery results filtering
class ImageryFilterChips extends StatelessWidget {
  final List<String> activeFilters;
  final Function(String) onFilterRemoved;
  final VoidCallback onClearAll;

  const ImageryFilterChips({
    super.key,
    required this.activeFilters,
    required this.onFilterRemoved,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (activeFilters.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtres actifs',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Spacer(),
              if (activeFilters.length > 1)
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Tout effacer',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: activeFilters
                .map((filter) => _buildFilterChip(
                      filter,
                      colorScheme,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, ColorScheme colorScheme) {
    final filterData = _parseFilter(filter);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.w, top: 1.h, bottom: 1.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: filterData['icon']!,
                    color: colorScheme.primary,
                    size: 3.5.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    filterData['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => onFilterRemoved(filter),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: EdgeInsets.all(1.w),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.primary,
                  size: 3.5.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _parseFilter(String filter) {
    // Parse filter string to extract type and value
    if (filter.startsWith('type:')) {
      final type = filter.substring(5);
      return {
        'icon': _getTypeIcon(type),
        'label': _getTypeLabel(type),
      };
    } else if (filter.startsWith('date:')) {
      final dateRange = filter.substring(5);
      return {
        'icon': 'date_range',
        'label': _getDateLabel(dateRange),
      };
    } else if (filter.startsWith('region:')) {
      final region = filter.substring(7);
      return {
        'icon': 'location_on',
        'label': region,
      };
    } else if (filter.startsWith('status:')) {
      final status = filter.substring(7);
      return {
        'icon': 'info',
        'label': _getStatusLabel(status),
      };
    }

    return {
      'icon': 'filter_alt',
      'label': filter,
    };
  }

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'xray':
      case 'x-ray':
        return 'medical_services';
      case 'mri':
        return 'psychology';
      case 'ct':
      case 'scanner':
        return 'monitor_heart';
      case 'ultrasound':
      case 'echographie':
        return 'hearing';
      case 'mammography':
      case 'mammographie':
        return 'favorite';
      default:
        return 'medical_services';
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'xray':
      case 'x-ray':
        return 'Radiographie';
      case 'mri':
        return 'IRM';
      case 'ct':
      case 'scanner':
        return 'Scanner';
      case 'ultrasound':
      case 'echographie':
        return 'Échographie';
      case 'mammography':
      case 'mammographie':
        return 'Mammographie';
      default:
        return type;
    }
  }

  String _getDateLabel(String dateRange) {
    switch (dateRange.toLowerCase()) {
      case 'today':
        return "Aujourd'hui";
      case 'week':
        return 'Cette semaine';
      case 'month':
        return 'Ce mois';
      case 'year':
        return 'Cette année';
      default:
        return dateRange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      default:
        return status;
    }
  }
}
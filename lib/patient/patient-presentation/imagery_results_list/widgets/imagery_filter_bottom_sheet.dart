import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';

/// Bottom sheet widget for advanced imagery results filtering
class ImageryFilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const ImageryFilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onFiltersApplied,
  });

  @override
  State<ImageryFilterBottomSheet> createState() =>
      _ImageryFilterBottomSheetState();
}

class _ImageryFilterBottomSheetState extends State<ImageryFilterBottomSheet> {
  late Map<String, dynamic> _filters;

  final List<String> _imagingTypes = [
    'Radiographie',
    'IRM',
    'Scanner',
    'Échographie',
    'Mammographie',
    'Scintigraphie',
    'Angiographie',
  ];

  final List<String> _bodyRegions = [
    'Tête et cou',
    'Thorax',
    'Abdomen',
    'Pelvis',
    'Membres supérieurs',
    'Membres inférieurs',
    'Colonne vertébrale',
    'Système cardiovasculaire',
  ];

  final List<String> _statusOptions = [
    'Terminé',
    'En attente',
    'En cours',
  ];

  final List<String> _dateRanges = [
    'Aujourd\'hui',
    'Cette semaine',
    'Ce mois',
    'Ces 3 mois',
    'Cette année',
    'Personnalisé',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSection(colorScheme),
                  SizedBox(height: 3.h),
                  _buildImagingTypeSection(colorScheme),
                  SizedBox(height: 3.h),
                  _buildBodyRegionSection(colorScheme),
                  SizedBox(height: 3.h),
                  _buildStatusSection(colorScheme),
                  SizedBox(height: 3.h),
                  _buildSortSection(colorScheme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filtres avancés',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection(ColorScheme colorScheme) {
    return _buildSection(
      title: 'Période',
      colorScheme: colorScheme,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _dateRanges
            .map((range) => _buildFilterChip(
                  label: range,
                  isSelected: _filters['dateRange'] == range,
                  onTap: () => setState(() {
                    _filters['dateRange'] =
                        _filters['dateRange'] == range ? null : range;
                  }),
                  colorScheme: colorScheme,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildImagingTypeSection(ColorScheme colorScheme) {
    return _buildSection(
      title: 'Type d\'imagerie',
      colorScheme: colorScheme,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _imagingTypes
            .map((type) => _buildFilterChip(
                  label: type,
                  isSelected: (_filters['imagingTypes'] as List<String>? ?? [])
                      .contains(type),
                  onTap: () => _toggleListFilter('imagingTypes', type),
                  colorScheme: colorScheme,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBodyRegionSection(ColorScheme colorScheme) {
    return _buildSection(
      title: 'Région corporelle',
      colorScheme: colorScheme,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _bodyRegions
            .map((region) => _buildFilterChip(
                  label: region,
                  isSelected: (_filters['bodyRegions'] as List<String>? ?? [])
                      .contains(region),
                  onTap: () => _toggleListFilter('bodyRegions', region),
                  colorScheme: colorScheme,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildStatusSection(ColorScheme colorScheme) {
    return _buildSection(
      title: 'Statut',
      colorScheme: colorScheme,
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: _statusOptions
            .map((status) => _buildFilterChip(
                  label: status,
                  isSelected: (_filters['status'] as List<String>? ?? [])
                      .contains(status),
                  onTap: () => _toggleListFilter('status', status),
                  colorScheme: colorScheme,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSortSection(ColorScheme colorScheme) {
    final sortOptions = [
      {'label': 'Date récente', 'value': 'date_desc'},
      {'label': 'Date ancienne', 'value': 'date_asc'},
      {'label': 'Type A-Z', 'value': 'type_asc'},
      {'label': 'Type Z-A', 'value': 'type_desc'},
    ];

    return _buildSection(
      title: 'Trier par',
      colorScheme: colorScheme,
      child: Column(
        children: sortOptions
            .map((option) => RadioListTile<String>(
                  title: Text(
                    option['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: option['value']!,
                  groupValue: _filters['sortBy'] as String? ?? 'date_desc',
                  onChanged: (value) => setState(() {
                    _filters['sortBy'] = value;
                  }),
                  activeColor: colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        child,
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllFilters,
              child: Text(
                'Effacer tout',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: Text(
                'Appliquer les filtres',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleListFilter(String key, String value) {
    setState(() {
      final list = (_filters[key] as List<String>?) ?? <String>[];
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
      _filters[key] = list;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }
}
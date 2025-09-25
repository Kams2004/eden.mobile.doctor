import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../patient-core/core/app_export.dart';
import '../../../../patient-widgets/widgets/custom_icon_widget.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedCategories;
  final DateTimeRange? selectedDateRange;
  final List<String> selectedStatuses;
  final Function(List<String>, DateTimeRange?, List<String>) onApplyFilters;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategories,
    this.selectedDateRange,
    required this.selectedStatuses,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedCategories;
  late DateTimeRange? _selectedDateRange;
  late List<String> _selectedStatuses;

  final List<String> _availableCategories = [
    'BIOCHIMIE',
    'TRANSAMINASES',
    'HÉMATOLOGIE',
    'IMMUNOLOGIE',
    'MICROBIOLOGIE',
    'ENDOCRINOLOGIE',
    'CARDIOLOGIE',
    'NÉPHROLOGIE',
  ];

  final List<String> _availableStatuses = [
    'completed',
    'pending',
    'in_progress',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedDateRange = widget.selectedDateRange;
    _selectedStatuses = List.from(widget.selectedStatuses);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 80.h,
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
                  _buildCategorySection(theme),
                  SizedBox(height: 3.h),
                  _buildDateRangeSection(theme),
                  SizedBox(height: 3.h),
                  _buildStatusSection(theme),
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
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filtres',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Tout effacer',
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Catégories',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${_selectedCategories.length} sélectionnée${_selectedCategories.length > 1 ? 's' : ''}',
        style: theme.textTheme.bodySmall,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _availableCategories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
                selectedColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildDateRangeSection(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Période',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        _selectedDateRange != null
            ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
            : 'Toutes les dates',
        style: theme.textTheme.bodySmall,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              ListTile(
                title: Text('Sélectionner une période'),
                trailing: CustomIconWidget(
                  iconName: 'date_range',
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
                onTap: _selectDateRange,
              ),
              if (_selectedDateRange != null)
                ListTile(
                  title: Text('Effacer la sélection'),
                  trailing: CustomIconWidget(
                    iconName: 'clear',
                    color: theme.colorScheme.error,
                    size: 6.w,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Statut',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${_selectedStatuses.length} sélectionné${_selectedStatuses.length > 1 ? 's' : ''}',
        style: theme.textTheme.bodySmall,
      ),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: _availableStatuses.map((status) {
              final isSelected = _selectedStatuses.contains(status);
              return CheckboxListTile(
                title: Text(_getStatusDisplayName(status)),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
                activeColor: theme.colorScheme.primary,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: Text('Appliquer'),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedDateRange = null;
      _selectedStatuses.clear();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _applyFilters() {
    widget.onApplyFilters(
        _selectedCategories, _selectedDateRange, _selectedStatuses);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
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

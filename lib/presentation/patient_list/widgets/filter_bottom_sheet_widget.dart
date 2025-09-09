import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  bool _isDateRangeExpanded = false;
  bool _isStatusExpanded = false;
  bool _isExaminationTypeExpanded = false;

  final List<String> _statusOptions = [
    'Tous',
    'Confirmé',
    'En attente',
    'Annulé',
  ];

  final List<String> _examinationTypes = [
    'Tous',
    'IRM',
    'Scanner',
    'Échographie',
    'Radiographie',
    'Mammographie',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtres',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Effacer tout',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  // Date Range Section
                  _buildExpandableSection(
                    title: 'Période',
                    isExpanded: _isDateRangeExpanded,
                    onToggle: () => setState(
                        () => _isDateRangeExpanded = !_isDateRangeExpanded),
                    child: _buildDateRangeSection(),
                  ),

                  SizedBox(height: 2.h),

                  // Status Section
                  _buildExpandableSection(
                    title: 'Statut de commission',
                    isExpanded: _isStatusExpanded,
                    onToggle: () =>
                        setState(() => _isStatusExpanded = !_isStatusExpanded),
                    child: _buildStatusSection(),
                  ),

                  SizedBox(height: 2.h),

                  // Examination Type Section
                  _buildExpandableSection(
                    title: 'Type d\'examen',
                    isExpanded: _isExaminationTypeExpanded,
                    onToggle: () => setState(() => _isExaminationTypeExpanded =
                        !_isExaminationTypeExpanded),
                    child: _buildExaminationTypeSection(),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text('Appliquer les filtres'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: AppTheme.lightTheme.colorScheme.outline),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date de début',
                  suffixIcon: CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, 'startDate'),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date de fin',
                  suffixIcon: CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, 'endDate'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: _statusOptions.map((status) {
        final isSelected = (_filters['status'] as String?) == status;
        return CheckboxListTile(
          title: Text(
            status,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              _filters['status'] = value == true ? status : null;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildExaminationTypeSection() {
    return Column(
      children: _examinationTypes.map((type) {
        final isSelected = (_filters['examinationType'] as String?) == type;
        return CheckboxListTile(
          title: Text(
            type,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              _filters['examinationType'] = value == true ? type : null;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context, String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _filters[dateType] = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }
}

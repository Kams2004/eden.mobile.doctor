import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/theme_service.dart';

class PointsFilterWidget extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final DateTimeRange? selectedDateRange;
  final Function(DateTimeRange?) onDateRangeChanged;
  final ThemeService themeService;

  const PointsFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.selectedDateRange,
    required this.onDateRangeChanged,
    required this.themeService,
  }) : super(key: key);

  @override
  State<PointsFilterWidget> createState() => _PointsFilterWidgetState();
}

class _PointsFilterWidgetState extends State<PointsFilterWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: widget.themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: _selectDateRange,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: widget.selectedDateRange != null ? Color(0xFF3B82F6).withOpacity(0.1) : (widget.themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.selectedDateRange != null ? Color(0xFF3B82F6) : (widget.themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 4.w,
                        color: widget.selectedDateRange != null ? Color(0xFF3B82F6) : (widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        widget.selectedDateRange == null ? 'Période' : '${_formatDate(widget.selectedDateRange!.start)} - ${_formatDate(widget.selectedDateRange!.end)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.selectedDateRange != null ? Color(0xFF3B82F6) : (widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700]),
                        ),
                      ),
                      if (widget.selectedDateRange != null) ...[
                        SizedBox(width: 1.w),
                        GestureDetector(
                          onTap: () {
                            widget.onDateRangeChanged(null);
                          },
                          child: Icon(
                            Icons.clear,
                            size: 3.w,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          Wrap(
            spacing: 1.5.w,
            runSpacing: 1.w,
            children: [
              _buildFilterChip('Tout', 'all'),
              _buildFilterChip('Prescriptions', 'prescription'),
              _buildFilterChip('Réalisations', 'realisation'),
              _buildFilterChip('Facturés', 'validated'),
              _buildFilterChip('Non facturés', 'pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = widget.selectedFilter == value;
    return GestureDetector(
      onTap: () => widget.onFilterChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.w),
        decoration: BoxDecoration(
          color: isSelected 
              ? Color(0xFF3B82F6) 
              : (widget.themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? Color(0xFF3B82F6) 
                : (widget.themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isSelected 
                ? Colors.white 
                : (widget.themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 80.w,
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sélectionner une période',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 3.h),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: widget.selectedDateRange?.start ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  onDateChanged: (date) {
                    Navigator.pop(context);
                    _showEndDatePicker(date);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEndDatePicker(DateTime startDate) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 80.w,
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Date de fin',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 3.h),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: widget.selectedDateRange?.end ?? startDate.add(Duration(days: 7)),
                  firstDate: startDate,
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  onDateChanged: (endDate) {
                    Navigator.pop(context);
                    widget.onDateRangeChanged(DateTimeRange(start: startDate, end: endDate));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
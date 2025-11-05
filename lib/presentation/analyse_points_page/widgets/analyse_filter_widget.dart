import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/theme_service.dart';

class AnalyseFilterWidget extends StatelessWidget {
  final String selectedView;
  final int selectedYear;
  final int selectedMonth;
  final String invoiceStatus;
  final Function({String? view, int? year, int? month, String? status}) onFilterChanged;
  final ThemeService themeService;

  const AnalyseFilterWidget({
    Key? key,
    required this.selectedView,
    required this.selectedYear,
    required this.selectedMonth,
    required this.invoiceStatus,
    required this.onFilterChanged,
    required this.themeService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
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
                'Options de filtrage',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Spacer(),
              Icon(
                Icons.filter_list,
                color: Color(0xFF3B82F6),
                size: 5.w,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          
          // View Toggle
          Row(
            children: [
              Expanded(
                child: _buildViewButton('mensuelle', 'monthly'),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildViewButton('annuelle', 'yearly'),
              ),
            ],
          ),
          
          SizedBox(height: 3.h),
          
          // Year Selection
          Text(
            'Sélectionner l\'année',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              color: themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                items: List.generate(5, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: themeService.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    onFilterChanged(year: value);
                  }
                },
              ),
            ),
          ),
          
          SizedBox(height: 3.h),
          
          // Invoice Status
          Text(
            'Statut de facturation',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton('Facturé', 'invoiced'),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatusButton('Non facturé', 'Notinvoiced'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, String value) {
    final isSelected = selectedView == value;
    return GestureDetector(
      onTap: () => onFilterChanged(view: value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3B82F6) : (themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFF3B82F6) : (themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'monthly' ? Icons.calendar_view_month : Icons.bar_chart,
              color: isSelected ? Colors.white : (themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String value) {
    final isSelected = invoiceStatus == value;
    return GestureDetector(
      onTap: () => onFilterChanged(status: value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? (value == 'invoiced' ? Color(0xFF10B981) : Color(0xFFEF4444))
              : (themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? (value == 'invoiced' ? Color(0xFF10B981) : Color(0xFFEF4444))
                : (themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value == 'invoiced' ? Icons.check_circle : Icons.pending,
              color: isSelected ? Colors.white : (themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600]),
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
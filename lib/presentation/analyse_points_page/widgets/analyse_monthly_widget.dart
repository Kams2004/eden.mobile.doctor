import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/theme_service.dart';

class AnalyseMonthlyWidget extends StatelessWidget {
  final Map<String, dynamic> yearlyData;
  final bool maskAmounts;
  final ThemeService themeService;

  const AnalyseMonthlyWidget({
    Key? key,
    required this.yearlyData,
    required this.maskAmounts,
    required this.themeService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final months = _getMonthsData();
    final maxAmount = _getMaxAmount(months);

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
              Icon(
                Icons.bar_chart,
                color: Color(0xFF3B82F6),
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Répartition mensuelle',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...months.map((month) => _buildMonthBar(month, maxAmount)).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthsData() {
    final months = <Map<String, dynamic>>[];
    final monthNames = [
      'JANVIER', 'FEVRIER', 'MARS', 'AVRIL', 'MAI', 'JUIN',
      'JUILLET', 'AOUT', 'SEPTEMBRE', 'OCTOBRE', 'NOVEMBRE', 'DECEMBRE'
    ];

    for (final monthName in monthNames) {
      final monthData = yearlyData[monthName];
      if (monthData != null) {
        final amount = monthData[monthName]?.toDouble() ?? 0.0;
        months.add({
          'name': monthName,
          'amount': amount,
          'displayName': _getDisplayMonthName(monthName),
        });
      }
    }

    return months;
  }

  String _getDisplayMonthName(String monthName) {
    final monthMap = {
      'JANVIER': 'Janvier',
      'FEVRIER': 'Février',
      'MARS': 'Mars',
      'AVRIL': 'Avril',
      'MAI': 'Mai',
      'JUIN': 'Juin',
      'JUILLET': 'Juillet',
      'AOUT': 'Août',
      'SEPTEMBRE': 'Septembre',
      'OCTOBRE': 'Octobre',
      'NOVEMBRE': 'Novembre',
      'DECEMBRE': 'Décembre',
    };
    return monthMap[monthName] ?? monthName;
  }

  double _getMaxAmount(List<Map<String, dynamic>> months) {
    if (months.isEmpty) return 1.0;
    return months.map((m) => m['amount'] as double).reduce((a, b) => a > b ? a : b);
  }

  Widget _buildMonthBar(Map<String, dynamic> month, double maxAmount) {
    final amount = month['amount'] as double;
    final percentage = maxAmount > 0 ? amount / maxAmount : 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month['displayName'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                maskAmounts ? '••••••' : '${_formatAmount(amount)} points',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            height: 1.h,
            decoration: BoxDecoration(
              color: themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: amount > 0 ? Color(0xFF3B82F6) : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAll('.', ',');
  }
}
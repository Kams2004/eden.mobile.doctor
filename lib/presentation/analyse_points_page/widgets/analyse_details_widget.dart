import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/theme_service.dart';

class AnalyseDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> yearlyData;
  final bool maskAmounts;
  final ThemeService themeService;

  const AnalyseDetailsWidget({
    Key? key,
    required this.yearlyData,
    required this.maskAmounts,
    required this.themeService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthsWithData = _getMonthsWithData();

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
                Icons.calendar_month,
                color: Color(0xFF3B82F6),
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Détails mensuels',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: themeService.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (monthsWithData.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  'Aucune donnée disponible',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ...monthsWithData.map((month) => _buildMonthDetail(month)).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthsWithData() {
    final months = <Map<String, dynamic>>[];
    final monthNames = [
      'SEPTEMBRE', 'OCTOBRE', 'NOVEMBRE', 'DECEMBRE'
    ];

    for (final monthName in monthNames) {
      final monthData = yearlyData[monthName];
      if (monthData != null) {
        final amount = monthData[monthName]?.toDouble() ?? 0.0;
        if (amount > 0) {
          final prescriptionAmount = monthData['elements_prescription']?['commission']?.toDouble() ?? 0.0;
          final realisationAmount = monthData['elements_realisation']?['commission']?.toDouble() ?? 0.0;
          
          months.add({
            'name': monthName,
            'displayName': _getDisplayMonthName(monthName),
            'totalAmount': amount,
            'prescriptionAmount': prescriptionAmount,
            'realisationAmount': realisationAmount,
            'data': monthData,
          });
        }
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

  Widget _buildMonthDetail(Map<String, dynamic> month) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeService.isDarkMode ? Color(0xFF374151) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeService.isDarkMode ? Color(0xFF4B5563) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            month['displayName'],
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  'Prescription',
                  month['prescriptionAmount'],
                  Color(0xFF10B981),
                  Icons.receipt_long,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildAmountCard(
                  'Réalisation',
                  month['realisationAmount'],
                  Color(0xFF8B5CF6),
                  Icons.medical_services,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                Text(
                  maskAmounts ? '••••••••' : '${_formatAmount(month['totalAmount'])} points',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            maskAmounts ? '••••••' : '${_formatAmount(amount)} points',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: themeService.isDarkMode ? Colors.white : Colors.black87,
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
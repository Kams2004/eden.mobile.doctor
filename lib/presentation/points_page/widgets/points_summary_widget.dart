import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/theme_service.dart';

class PointsSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> pointsData;
  final ThemeService themeService;

  const PointsSummaryWidget({
    Key? key,
    required this.pointsData,
    required this.themeService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prescriptionAmount = pointsData['prescription']?['montant_prescription']?.toDouble() ?? 0.0;
    final realisationAmount = pointsData['realisation']?['montant_realisation']?.toDouble() ?? 0.0;
    final prescriptionCount = (pointsData['prescription']?['data_prescription'] as List?)?.length ?? 0;
    final realisationCount = (pointsData['realisation']?['data_realisation'] as List?)?.length ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Prescriptions',
            prescriptionAmount,
            prescriptionCount,
            Icons.receipt_long,
            Color(0xFF10B981),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildSummaryCard(
            'Réalisations',
            realisationAmount,
            realisationCount,
            Icons.medical_services,
            Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, int count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeService.isDarkMode ? Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 6.w,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: themeService.isDarkMode ? Color(0xFF94A3B8) : Colors.grey[600],
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${amount.toString()} FCFA',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: themeService.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count éléments',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
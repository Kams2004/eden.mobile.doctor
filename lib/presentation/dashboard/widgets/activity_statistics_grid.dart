import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivityStatisticsGrid extends StatelessWidget {
  final int todayPatients;
  final int todayExams;
  final int totalPatients;
  final int totalExams;

  const ActivityStatisticsGrid({
    Key? key,
    required this.todayPatients,
    required this.todayExams,
    required this.totalPatients,
    required this.totalExams,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.5.h,
        childAspectRatio: 1.6,
        children: [
          _buildStatCard(
            title: "Patients d'aujourd'hui",
            value: todayPatients.toString(),
            icon: 'person',
            color: AppTheme.lightTheme.colorScheme.primary,
            context: context,
          ),
          _buildStatCard(
            title: "Examens d'aujourd'hui",
            value: todayExams.toString(),
            icon: 'medical_services',
            color: const Color(0xFF1B5E20),
            context: context,
          ),
          _buildStatCard(
            title: 'Total Patients',
            value: totalPatients.toString(),
            icon: 'people',
            color: const Color(0xFFBF360C),
            context: context,
          ),
          _buildStatCard(
            title: 'Total Examens',
            value: totalExams.toString(),
            icon: 'assignment',
            color: const Color(0xFF4A148C),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 20,
          ),
          SizedBox(height: 0.5.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

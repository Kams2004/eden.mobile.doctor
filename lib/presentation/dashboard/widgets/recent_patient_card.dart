import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentPatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback? onTap;
  final VoidCallback? onCommissionView;
  final VoidCallback? onPatientDetails;

  const RecentPatientCard({
    Key? key,
    required this.patient,
    this.onTap,
    this.onCommissionView,
    this.onPatientDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String patientName = patient['patientName'] ?? patient['name'] ?? 'Patient Inconnu';
    final String examinationDate = patient['date'] ?? patient['examinationDate'] ?? '';
    final String examType = patient['examType'] ?? '';
    final String patientId = patient['id']?.toString() ?? '';

    return Dismissible(
      key: Key('patient_$patientId'),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'euro_symbol',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Commission',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        decoration: BoxDecoration(
          color: AppTheme.accentLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Détails',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.accentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'person',
              color: AppTheme.accentLight,
              size: 24,
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd &&
            onCommissionView != null) {
          onCommissionView!();
        } else if (direction == DismissDirection.endToStart &&
            onPatientDetails != null) {
          onPatientDetails!();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(1),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style:
                          AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _formatDate(examinationDate),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(examinationDate),
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
if (examType.isNotEmpty) ...[
  SizedBox(height: 0.5.h),
  Text(
    examType,
    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      fontSize: 9.sp,
    ),
  ),
],
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // Handle different date formats
      if (dateStr.contains('/')) {
        return dateStr; // Already formatted like "28/08/2025"
      }
      // Handle other formats if needed
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // Extract time if available, otherwise show a default time
      if (dateStr.contains(' ')) {
        final parts = dateStr.split(' ');
        if (parts.length > 1) {
          return parts[1]; // Return time part
        }
      }
      // Default time for examination
      return '09:00';
    } catch (e) {
      return '09:00';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PatientCardWidget extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback? onTap;
  final VoidCallback? onViewCommission;
  final VoidCallback? onCallPatient;
  final VoidCallback? onExportReport;
  final VoidCallback? onArchive;

  const PatientCardWidget({
    Key? key,
    required this.patient,
    this.onTap,
    this.onViewCommission,
    this.onCallPatient,
    this.onExportReport,
    this.onArchive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String patientName = (patient['name'] as String?) ?? 'Patient Inconnu';
    final String examinationDate = (patient['examinationDate'] as String?) ?? '';
    final bool isPaid = (patient['isPaid'] as bool?) ?? false;
    final String examinationType = (patient['examinationType'] as String?) ?? '';
    final double commissionAmount = (patient['commissionAmount'] as double?) ?? 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Slidable(
        key: ValueKey(patient['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onViewCommission?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.euro,
              label: 'Commission',
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              onPressed: (_) => onCallPatient?.call(),
              backgroundColor: AppTheme.successLight,
              foregroundColor: Colors.white,
              icon: Icons.phone,
              label: 'Appeler',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onArchive?.call(),
              backgroundColor: AppTheme.warningLight,
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Archiver',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            examinationDate,
                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          examinationType,
                          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${commissionAmount.toStringAsFixed(0)} FCFA',
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
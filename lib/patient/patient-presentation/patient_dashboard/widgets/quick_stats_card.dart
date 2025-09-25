import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';

class QuickStatsCard extends StatelessWidget {
  final int totalResults;
  final String lastUpdate;

  const QuickStatsCard({
    super.key,
    required this.totalResults,
    required this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Total Results
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'assessment',
                      color: colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Total Résultats',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  totalResults.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 8.h,
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),

          SizedBox(width: 4.w),

          // Last Update
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'sync',
                      color: colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Dernière MAJ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  lastUpdate,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

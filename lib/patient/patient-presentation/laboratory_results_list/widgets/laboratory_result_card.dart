import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';

class LaboratoryResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;

  const LaboratoryResultCard({
    super.key,
    required this.result,
    this.onTap,
    this.onShare,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('lab_result_${result["id"]}'),
      direction: DismissDirection.startToEnd,
      background: _buildSwipeBackground(colorScheme),
      onDismissed: (direction) {
        // Reset the card position after showing actions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Actions disponibles pour ${result["testName"]}'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme),
                  SizedBox(height: 2.h),
                  _buildTestDetails(theme),
                  SizedBox(height: 1.5.h),
                  _buildDateInfo(theme),
                  SizedBox(height: 1.5.h),
                  _buildStatusRow(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(width: 6.w),
          CustomIconWidget(
            iconName: 'visibility',
            color: colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(width: 4.w),
          CustomIconWidget(
            iconName: 'share',
            color: colorScheme.secondary,
            size: 6.w,
          ),
          SizedBox(width: 4.w),
          CustomIconWidget(
            iconName: 'favorite_border',
            color: AppTheme.warningLight,
            size: 6.w,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result["category"] as String? ?? "ANALYSE",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: _getStatusColor(result["status"] as String? ?? "completed")
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: _getStatusColor(
                      result["status"] as String? ?? "completed"),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.w),
              Text(
                _getStatusText(result["status"] as String? ?? "completed"),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(
                      result["status"] as String? ?? "completed"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result["testName"] as String? ?? "Test de laboratoire",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          "Ordre N° ${result["orderNumber"] ?? "N/A"}",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildDateItem(
            "Date Émission",
            result["emissionDate"] as String? ?? "N/A",
            theme,
            CustomIconWidget(
              iconName: 'calendar_today',
              color: theme.colorScheme.primary,
              size: 4.w,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildDateItem(
            "Date Résultat",
            result["resultDate"] as String? ?? "N/A",
            theme,
            CustomIconWidget(
              iconName: 'assignment_turned_in',
              color: AppTheme.successLight,
              size: 4.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateItem(
      String label, String date, ThemeData theme, Widget icon) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            date,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(ColorScheme colorScheme) {
    final duration = result["duration"] as String? ?? "N/A";
    final analysesCount = result["analysesCount"] as int? ?? 0;

    return Row(
      children: [
        CustomIconWidget(
          iconName: 'schedule',
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          size: 4.w,
        ),
        SizedBox(width: 1.w),
        Text(
          "Durée: $duration",
          style: TextStyle(
            fontSize: 10.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'science',
                color: colorScheme.secondary,
                size: 3.w,
              ),
              SizedBox(width: 1.w),
              Text(
                "$analysesCount analyses",
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successLight;
      case 'pending':
        return AppTheme.warningLight;
      case 'in_progress':
        return AppTheme.lightTheme.primaryColor;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      default:
        return 'Inconnu';
    }
  }
}

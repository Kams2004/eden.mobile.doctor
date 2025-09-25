import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../patient-core/core/app_export.dart';
import '../../../patient-widgets/widgets/custom_icon_widget.dart';

class ResultHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultHeaderWidget({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(colorScheme),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Text(
                  _getStatusText(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'share',
                color: colorScheme.primary,
                size: 6.w,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            (resultData['testName'] as String?) ?? 'Test de laboratoire',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Ordre N° ${(resultData['orderNumber'] as String?) ?? 'N/A'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 2.h),
          _buildMetadataRow(
            context,
            'Date d\'émission',
            (resultData['emissionDate'] as String?) ?? '28/08/2025',
            Icons.calendar_today_outlined,
          ),
          SizedBox(height: 1.h),
          _buildMetadataRow(
            context,
            'Date de résultat',
            (resultData['resultDate'] as String?) ?? '28/08/2025',
            Icons.event_available_outlined,
          ),
          SizedBox(height: 1.h),
          _buildMetadataRow(
            context,
            'Durée',
            (resultData['duration'] as String?) ?? '2 jours',
            Icons.schedule_outlined,
          ),
          SizedBox(height: 1.h),
          _buildMetadataRow(
            context,
            'Actes d\'examen',
            (resultData['examinationActs'] as String?) ??
                'Analyses sanguines complètes',
            Icons.medical_services_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CustomIconWidget(
          iconName: icon.toString().split('.').last,
          color: colorScheme.primary,
          size: 4.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    final status =
        (resultData['status'] as String?)?.toLowerCase() ?? 'completed';
    switch (status) {
      case 'completed':
        return colorScheme.primary;
      case 'pending':
        return Colors.orange;
      case 'abnormal':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  String _getStatusText() {
    final status =
        (resultData['status'] as String?)?.toLowerCase() ?? 'completed';
    switch (status) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'abnormal':
        return 'Anormal';
      default:
        return 'Terminé';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../widgets/custom_icon_widget.dart';

class StatusIndicatorWidget extends StatelessWidget {
  final String status;
  final String statusText;
  final Color statusColor;

  const StatusIndicatorWidget({
    super.key,
    required this.status,
    required this.statusText,
    required this.statusColor,
  });

  String _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return 'schedule';
      case 'validated':
        return 'check_circle';
      case 'clarification_needed':
        return 'help_outline';
      default:
        return 'info';
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Votre prescription est en cours de validation par notre équipe médicale.';
      case 'validated':
        return 'Votre prescription a été validée. Vous pouvez maintenant réserver vos examens.';
      case 'clarification_needed':
        return 'Des informations supplémentaires sont nécessaires pour valider votre prescription.';
      default:
        return 'Statut de validation inconnu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: CustomIconWidget(
              iconName: _getStatusIcon(status),
              color: statusColor,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getStatusMessage(status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

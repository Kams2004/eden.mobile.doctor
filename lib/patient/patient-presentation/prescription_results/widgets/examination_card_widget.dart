import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../widgets/custom_icon_widget.dart';

class ExaminationCardWidget extends StatelessWidget {
  final Map<String, dynamic> examination;
  final VoidCallback onBook;

  const ExaminationCardWidget({
    super.key,
    required this.examination,
    required this.onBook,
  });

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyText(String urgency) {
    switch (urgency) {
      case 'high':
        return 'Urgent';
      case 'medium':
        return 'Modéré';
      case 'low':
        return 'Non urgent';
      default:
        return 'À déterminer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: CustomIconWidget(
                    iconName: examination['icon'],
                    color: colorScheme.primary,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        examination['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(examination['urgency'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: _getUrgencyColor(examination['urgency'])
                                .withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          _getUrgencyText(examination['urgency']),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getUrgencyColor(examination['urgency']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              examination['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                _buildInfoChip(
                  icon: 'schedule',
                  text: examination['estimatedDuration'],
                  context: context,
                ),
                SizedBox(width: 2.w),
                _buildInfoChip(
                  icon: 'euro',
                  text: examination['price'],
                  context: context,
                ),
              ],
            ),
            if (examination['preparation'] !=
                'Aucune préparation spéciale') ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: Colors.blue,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Préparation: ${examination['preparation']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showExaminationDetails(context),
                    icon: CustomIconWidget(
                      iconName: 'info_outline',
                      color: colorScheme.primary,
                      size: 4.w,
                    ),
                    label: const Text('Détails'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onBook,
                    icon: CustomIconWidget(
                      iconName: 'event_available',
                      color: colorScheme.onPrimary,
                      size: 4.w,
                    ),
                    label: const Text('Réserver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String text,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 4.w,
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _showExaminationDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              examination['name'],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Description complète:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(examination['description']),
            SizedBox(height: 2.h),
            Text(
              'Informations pratiques:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text('• Durée estimée: ${examination['estimatedDuration']}'),
            Text('• Tarif: ${examination['price']}'),
            Text('• Prise en charge: ${examination['insuranceCoverage']}'),
            Text('• Préparation: ${examination['preparation']}'),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}

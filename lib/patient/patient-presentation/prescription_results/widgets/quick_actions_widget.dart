import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../widgets/custom_icon_widget.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onBookAll;
  final VoidCallback onSelectSpecific;
  final VoidCallback onContactClarification;

  const QuickActionsWidget({
    super.key,
    required this.onBookAll,
    required this.onSelectSpecific,
    required this.onContactClarification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 6.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onBookAll,
                  icon: CustomIconWidget(
                    iconName: 'event_available',
                    color: colorScheme.onPrimary,
                    size: 4.w,
                  ),
                  label: const Text('Réserver Tout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: Size(0, 6.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSelectSpecific,
                  icon: CustomIconWidget(
                    iconName: 'checklist',
                    color: colorScheme.primary,
                    size: 4.w,
                  ),
                  label: const Text('Sélectionner'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    minimumSize: Size(0, 6.h),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onContactClarification,
              icon: CustomIconWidget(
                iconName: 'support_agent',
                color: colorScheme.primary,
                size: 4.w,
              ),
              label: const Text('Demander une clarification'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                minimumSize: Size(0, 5.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MonthNavigationWidget extends StatelessWidget {
  final String currentMonth;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const MonthNavigationWidget({
    Key? key,
    required this.currentMonth,
    this.onPreviousMonth,
    this.onNextMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPreviousMonth,
            icon: CustomIconWidget(
              iconName: 'chevron_left',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 4.h,
            ),
          ),
          Expanded(
            child: Text(
              currentMonth,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: onNextMonth,
            icon: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}

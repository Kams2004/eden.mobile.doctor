import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
class CommissionSummaryCard extends StatefulWidget {
  final double totalEarnings;
  final double pendingPayments;
  final String currency;

  const CommissionSummaryCard({
    Key? key,
    required this.totalEarnings,
    required this.pendingPayments,
    required this.currency,
  }) : super(key: key);

  @override
  State<CommissionSummaryCard> createState() => _CommissionSummaryCardState();
}

class _CommissionSummaryCardState extends State<CommissionSummaryCard> {
  bool _isAmountHidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde principale',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              CustomIconWidget(
                iconName: 'wallet',
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isAmountHidden
                    ? '****** ${widget.currency}'
                    : '${widget.totalEarnings.toStringAsFixed(2).replaceAll('.', ',')} ${widget.currency}',
                style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp, // <-- Reduced from 28.sp
                ),
                overflow: TextOverflow.ellipsis, // <-- Optional: Truncate if too long
              ),



              IconButton(
                icon: Icon(
                  _isAmountHidden ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isAmountHidden = !_isAmountHidden;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 1.h),

        ],
      ),
    );
  }
}

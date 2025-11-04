import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GroupedPatientCardWidget extends StatefulWidget {
  final Map<String, dynamic> patient;
  final VoidCallback? onTap;
  final VoidCallback? onViewCommission;
  final VoidCallback? onCallPatient;
  final VoidCallback? onArchive;

  const GroupedPatientCardWidget({
    Key? key,
    required this.patient,
    this.onTap,
    this.onViewCommission,
    this.onCallPatient,
    this.onArchive,
  }) : super(key: key);

  @override
  State<GroupedPatientCardWidget> createState() => _GroupedPatientCardWidgetState();
}

class _GroupedPatientCardWidgetState extends State<GroupedPatientCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String patientName = (widget.patient['name'] as String?) ?? 'Patient Inconnu';
    final String examinationDate = (widget.patient['examinationDate'] as String?) ?? '';
    final List<dynamic> exams = (widget.patient['exams'] as List<dynamic>?) ?? [];
    final double totalAmount = (widget.patient['totalAmount'] as double?) ?? 0.0;

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
        key: ValueKey(widget.patient['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => widget.onViewCommission?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.euro,
              label: 'Commission',
              borderRadius: BorderRadius.circular(8),
            ),
            SlidableAction(
              onPressed: (_) => widget.onCallPatient?.call(),
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
              onPressed: (_) => widget.onArchive?.call(),
              backgroundColor: AppTheme.warningLight,
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Archiver',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                child: Row(
                  children: [
                    Expanded(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${exams.length} examen${exams.length > 1 ? 's' : ''}',
                            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${totalAmount.toStringAsFixed(0)} POINTS',
                          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded && exams.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
                      height: 1,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Examens effectués:',
                      style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    ...exams.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exam = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                exam['type'],
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              '${exam['amount'].toStringAsFixed(0)} POINTS',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}